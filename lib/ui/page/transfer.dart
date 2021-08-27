import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:uuid/uuid.dart';

import '../../db/mixin_database.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
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
    if (data == null) {
      return const SizedBox();
    }

    return Scaffold(
        backgroundColor: context.colorScheme.background,
        appBar: MixinAppBar(
          leading: const MixinBackButton2(),
          backgroundColor: context.colorScheme.background,
          title: Text(
            context.l10n.sendToContact,
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          // TODO user transactions.
        ),
        body: _TransferUserPreSelection(asset: data));
  }
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
    }, [user]);

    if (user.data == null) {
      return Center(
        child: CircularProgressIndicator(
          color: context.colorScheme.captionIcon,
        ),
      );
    }
    return _TransferToContactBody(
      asset: asset,
      initialUser: user.data!,
    );
  }
}

class _TransferToContactBody extends HookWidget {
  const _TransferToContactBody({
    Key? key,
    required this.asset,
    required this.initialUser,
  }) : super(key: key);
  final AssetResult asset;
  final User initialUser;

  @override
  Widget build(BuildContext context) {
    final user = useState<User>(initialUser);
    final amount = useValueNotifier('');
    final memo = useValueNotifier('');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          TransferAssetHeader(asset: asset),
          const SizedBox(height: 16),
          TransferContactWidget(
            user: user.value,
            onUserChanged: (value) => user.value = value,
          ),
          const SizedBox(height: 10),
          TransferAmountWidget(amount: amount, asset: asset),
          const SizedBox(height: 10),
          TransferMemoWidget(onMemoInput: (value) => memo.value = value),
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
                  'recipient': user.value.userId,
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
