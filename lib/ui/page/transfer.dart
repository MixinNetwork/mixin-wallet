import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:uuid/uuid.dart';

import '../../db/mixin_database.dart';
import '../../generated/r.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../router/mixin_routes.dart';
import '../widget/action_button.dart';
import '../widget/buttons.dart';
import '../widget/contact_selection_widget.dart';
import '../widget/external_action_confirm.dart';
import '../widget/mixin_appbar.dart';
import '../widget/transfer.dart';

/// Transfer to Mixin contacts page.
class Transfer extends HookWidget {
  const Transfer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var assetId = context.pathParameters['id'];
    assetId ??= bitcoin;
    final data = useMemoizedFuture(
      () => context.appServices.assetResult(assetId!).getSingleOrNull(),
      keys: [assetId],
    ).data;

    final userId = context.queryParameters['opponent'];
    final user = useMemoizedFuture(() {
      if (userId == null) {
        return Future.value(null);
      }
      return context.appServices.getUserById(userId);
    }, keys: [userId]);

    final amount = useValueNotifier('');
    final memo = useValueNotifier('');

    if (data == null || (userId != null && user.isNoneOrWaiting)) {
      return const _ScaffoldLoading();
    }

    if (userId == null || (user.isActiveOrDone && !user.hasData)) {
      return _TransferUserPreSelection(asset: data);
    }

    assert(user.hasData);
    return _TransferScaffold(
      assetId: data.assetId,
      userId: user.data!.userId,
      child: _TransferToContactBody(
        asset: data,
        user: user.data!,
        memo: memo,
        amount: amount,
      ),
    );
  }
}

class _TransferScaffold extends StatelessWidget {
  const _TransferScaffold({
    Key? key,
    required this.assetId,
    required this.userId,
    required this.child,
  }) : super(key: key);

  final String? assetId;
  final String? userId;

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.colorScheme.background,
        appBar: MixinAppBar(
          leading: const MixinBackButton2(),
          backgroundColor: context.colorScheme.background,
          title: SelectableText(
            context.l10n.sendToContact,
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            enableInteractiveSelection: false,
          ),
          actions: [
            ActionButton(
              name: R.resourcesTransactionSvg,
              size: 24,
              onTap: () {
                if (userId == null || assetId == null) return;
                context.push(
                  transferTransactionsPath.toUri({'id': assetId!}).replace(
                    queryParameters: {'opponent': userId!},
                  ),
                );
              },
            )
          ],
        ),
        body: child,
      );
}

class _ScaffoldLoading extends StatelessWidget {
  const _ScaffoldLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => _TransferScaffold(
        assetId: null,
        userId: null,
        child: Center(
          child: CircularProgressIndicator(
            color: context.colorScheme.captionIcon,
          ),
        ),
      );
}

class _TransferUserPreSelection extends HookWidget {
  const _TransferUserPreSelection({
    Key? key,
    required this.asset,
  }) : super(key: key);
  final AssetResult asset;

  @override
  Widget build(BuildContext context) {
    final user = useMemoizedFuture(() {
      final result = Completer<User?>();
      WidgetsBinding.instance!.scheduleFrameCallback((timeStamp) {
        result.complete(showContactSelectionBottomSheet(
          context: context,
          selectedUser: null,
        ));
      });
      return result.future;
    });

    useEffect(() {
      if (user.connectionState == ConnectionState.done && user.data == null) {
        scheduleMicrotask(() {
          context.pop();
        });
      }
      if (user.hasData) {
        scheduleMicrotask(() {
          context.replace(Uri.parse(context.url).replace(queryParameters: {
            'opponent': user.data!.userId,
          }));
        });
      }
    }, [user]);

    return _TransferScaffold(
      assetId: asset.assetId,
      userId: null,
      child: Center(
        child: CircularProgressIndicator(
          color: context.colorScheme.captionIcon,
        ),
      ),
    );
  }
}

class _TransferToContactBody extends StatelessWidget {
  const _TransferToContactBody({
    Key? key,
    required this.asset,
    required this.user,
    required this.amount,
    required this.memo,
  }) : super(key: key);
  final AssetResult asset;
  final User user;

  final ValueNotifier<String> amount;
  final ValueNotifier<String> memo;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 24),
            TransferAssetHeader(asset: asset),
            const SizedBox(height: 16),
            TransferContactWidget(
              user: user,
              onUserChanged: (value) {
                context
                    .replace(Uri.parse(context.url).replace(queryParameters: {
                  'opponent': value.userId,
                }));
              },
            ),
            const SizedBox(height: 10),
            TransferAmountWidget(amount: amount, asset: asset),
            const SizedBox(height: 10),
            TransferMemoWidget(
              initialValue: memo.value,
              onMemoInput: (value) => memo.value = value,
            ),
            const Spacer(),
            HookBuilder(builder: (context) {
              useListenable(amount);
              return _SendButton(
                enable: amount.value.isNotEmpty,
                onTap: () async {
                  if (amount.value.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text(context.l10n.emptyAmount)));
                    return;
                  }

                  final traceId = const Uuid().v4();

                  final uri = Uri.https('mixin.one', 'pay', {
                    'amount': amount.value,
                    'trace': traceId,
                    'asset': asset.assetId,
                    'recipient': user.userId,
                    'memo': memo.value,
                  });

                  final succeed = await showAndWaitingExternalAction(
                    context: context,
                    uri: uri,
                    action: () => context.appServices.updateSnapshotByTraceId(
                      traceId: traceId,
                    ),
                    hint: Text(context.l10n.waitingActionDone),
                  );

                  if (succeed) {
                    context.pop();
                  }
                },
              );
            }),
            const SizedBox(height: 36),
          ],
        ),
      );
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    Key? key,
    required this.onTap,
    required this.enable,
  }) : super(key: key);

  final VoidCallback onTap;
  final bool enable;

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateColor.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return context.colorScheme.primaryText.withOpacity(0.2);
            }
            return context.colorScheme.primaryText;
          }),
          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          )),
          minimumSize: MaterialStateProperty.all(const Size(110, 48)),
          foregroundColor:
              MaterialStateProperty.all(context.colorScheme.background),
          shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
        ),
        onPressed: enable ? onTap : null,
        child: SelectableText(
          context.l10n.send,
          style: TextStyle(
            fontSize: 16,
            color: context.colorScheme.background,
          ),
          onTap: enable ? onTap : null,
          enableInteractiveSelection: false,
        ),
      );
}
