import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/logger.dart';
import '../../util/native_scroll.dart';
import '../../util/transaction.dart';
import '../router/mixin_routes.dart';
import '../widget/buttons.dart';
import '../widget/dialog/contact_selection_widget.dart';
import '../widget/dialog/transaction_submit_bottom_sheet.dart';
import '../widget/mixin_appbar.dart';
import '../widget/mixin_bottom_sheet.dart';
import '../widget/toast.dart';

class CollectibleDetail extends HookWidget {
  const CollectibleDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tokenId = usePathParameter('id', path: collectiblePath);
    final snapshot = useMemoizedStream(
      () => context.mixinDatabase.collectibleDao
          .collectibleItemByTokenId(tokenId)
          .watchSingleOrNull(),
      keys: [tokenId],
    );
    useMemoized(() {
      context.appServices.refreshCollectiblesTokenIfNotExist([tokenId]);
    }, [tokenId]);

    if (snapshot.isNoneOrWaiting) {
      return _CollectibleDetailScaffold(
        item: null,
        child: Center(
          child: SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(
              color: context.colorScheme.surface,
            ),
          ),
        ),
      );
    }
    final collectible = snapshot.data;
    if (collectible == null) {
      return _CollectibleDetailScaffold(
        item: null,
        child: Center(
          child: SelectableText(
            context.l10n.noCollectiblesFound,
            style: TextStyle(color: context.colorScheme.primaryText),
            enableInteractiveSelection: false,
          ),
        ),
      );
    }
    return _CollectibleDetailScaffold(
      item: collectible,
      child: Align(
        alignment: Alignment.topCenter,
        child: _Body(item: collectible),
      ),
    );
  }
}

class _CollectibleDetailScaffold extends StatelessWidget {
  const _CollectibleDetailScaffold({
    Key? key,
    required this.item,
    required this.child,
  }) : super(key: key);

  final CollectibleItem? item;

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: MixinAppBar(
          leading: const MixinBackButton2(),
          title: SelectableText(
            item == null ? '' : '${item?.name} #${item?.token}',
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 18,
            ),
            maxLines: 1,
            enableInteractiveSelection: false,
          ),
          backgroundColor: context.colorScheme.background,
        ),
        backgroundColor: context.colorScheme.background,
        body: child,
      );
}

class _Body extends StatelessWidget {
  const _Body({
    Key? key,
    required this.item,
  }) : super(key: key);

  final CollectibleItem item;

  @override
  Widget build(BuildContext context) => NativeScrollBuilder(
        builder: (context, controller) => SingleChildScrollView(
          controller: controller,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.network(item.mediaUrl ?? ''),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SelectableText(
                  item.name ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.primaryText,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 6),
                SelectableText(
                  '#${item.token}',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colorScheme.thirdText,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 12),
                SelectableText(
                  item.description ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    color: context.colorScheme.secondaryText,
                  ),
                ),
                const SizedBox(height: 60),
                SendButton(
                  enable: true,
                  onTap: () async {
                    final outputs = await context.mixinDatabase.collectibleDao
                        .getOutputsByTokenId(item.tokenId);
                    if (outputs.isEmpty) {
                      e('failed to find outputs for token: ${item.tokenId}');
                      return;
                    }
                    if (isSignedToken(outputs)) {
                      final utxo = outputs.firstWhereOrNull(
                          (element) => element?.signedTx.isNotEmpty ?? false);
                      if (utxo == null) {
                        e('failed to find valid output: $outputs');
                        return;
                      }
                      try {
                        final response = await computeWithLoading(() =>
                            context.appServices.client.collectibleApi.requests(
                              sdk.CollectibleRequestAction.sign,
                              utxo.signedTx,
                            ));
                        final succeed = await showTransactionSubmitBottomSheet(
                          context,
                          response.data,
                          utxo,
                        );
                        if (succeed ?? false) {
                          await context.mixinDatabase.collectibleDao
                              .removeByTokenId(item.tokenId);
                          context.pop();
                        }
                      } catch (error, stacktrace) {
                        e('failed to sign collectible: $error $stacktrace');
                        showErrorToast(error.toDisplayString(context));
                      }
                    } else {
                      final user = await showMixinBottomSheet<User?>(
                        context: context,
                        builder: (context) => const ContactSelectionBottomSheet(
                          selectedUser: null,
                        ),
                      );
                      if (user == null) {
                        return;
                      }
                      final appServices = context.appServices;
                      final String codeId;
                      try {
                        final response = await computeWithLoading(() async {
                          final raw = await buildTransaction(
                            outputs: outputs,
                            item: item,
                            user: user,
                            client: appServices.client,
                          );
                          return appServices.client.collectibleApi
                              .requests(sdk.CollectibleRequestAction.sign, raw);
                        });
                        codeId = response.data.codeId;
                      } catch (error, stacktrace) {
                        e('failed to sign collectible: $error $stacktrace');
                        showErrorToast(error.toDisplayString(context));
                        return;
                      }
                      d('url: mixin://codes/$codeId');
                      final succeed =
                          await showAndWaitingNftTransaction(context, codeId);
                      if (succeed) {
                        context.pop();
                        await context.mixinDatabase.collectibleDao
                            .removeByTokenId(item.tokenId);
                      }
                    }
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      );
}
