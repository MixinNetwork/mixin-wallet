import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;

import '../../../db/mixin_database.dart';
import '../../../util/extension/extension.dart';
import '../../../util/hook.dart';
import '../../../util/logger.dart';
import '../../../util/native_scroll.dart';
import '../../../util/transaction.dart';
import '../avatar.dart';
import '../buttons.dart';
import '../mixin_bottom_sheet.dart';
import '../toast.dart';
import '../transaction_info_tile.dart';

Future<bool?> showTransactionSubmitBottomSheet(
  BuildContext context,
  sdk.CollectibleRequest request,
  CollectibleOutputData utxo,
) =>
    showMixinBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height - 100,
        child: _TransactionSubmitBottomSheet(
          request: request,
          utxo: utxo,
        ),
      ),
    );

class _TransactionSubmitBottomSheet extends StatelessWidget {
  const _TransactionSubmitBottomSheet({
    Key? key,
    required this.request,
    required this.utxo,
  }) : super(key: key);

  final sdk.CollectibleRequest request;
  final CollectibleOutputData utxo;

  @override
  Widget build(BuildContext context) {
    final finished = request.signers.length >= utxo.receiversThreshold;
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        MixinBottomSheetTitle(title: Text(context.l10n.transaction)),
        Expanded(
          child: NativeScrollBuilder(
            builder: (context, controller) => ListView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _CollectibleInfoTile(
                  title: Text(context.l10n.transactionHash),
                  content: SelectableText(request.transactionHash),
                ),
                _CollectibleInfoTile(
                  title: Text(context.l10n.rawTransaction),
                  content: SelectableText(request.rawTransaction),
                ),
                _CollectibleInfoTile(
                  title: Text(
                      '${context.l10n.amount}(${request.tokenId})'.overflow),
                  content: Text(request.amount),
                ),
                _CollectibleInfoTile(
                  title: Text(context.l10n.receivers),
                  content: _UserAvatarRow(userIds: request.receivers),
                ),
                _CollectibleInfoTile(
                  title: Text(context.l10n.signers),
                  content: _UserAvatarRow(userIds: request.signers),
                ),
              ],
            ),
          ),
        ),
        MixinPrimaryTextButton(
          text: finished
              ? context.l10n.submitTransaction
              : context.l10n.signTransaction,
          onTap: () async {
            if (request.signers.length < utxo.receiversThreshold) {
              final succeed =
                  await showAndWaitingNftTransaction(context, request.codeId);
              if (succeed) {
                Navigator.pop(context, true);
              }
            } else {
              try {
                await computeWithLoading(() async {
                  await context.appServices
                      .sendRawTransaction(request.rawTransaction);
                });
                Navigator.pop(context, true);
              } catch (error, stacktrace) {
                e('submit transaction: $error $stacktrace');
                showErrorToast(error.toDisplayString(context));
                return;
              }
            }
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _CollectibleInfoTile extends StatelessWidget {
  const _CollectibleInfoTile({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  final Widget title;
  final Widget content;

  @override
  Widget build(BuildContext context) => TransactionInfoTile(
        title: title,
        subtitle: content,
      );
}

class _UserAvatarRow extends HookWidget {
  const _UserAvatarRow({Key? key, required this.userIds}) : super(key: key);

  final List<String> userIds;

  @override
  Widget build(BuildContext context) {
    final users = useMemoizedFuture(
          () => context.appServices.loadUsersIfNotExist(userIds),
          keys: [userIds],
        ).data ??
        const [];

    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          for (final user in users)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Avatar(
                avatarUrl: user.avatarUrl,
                userId: user.userId,
                name: user.fullName ?? '',
                size: 32,
              ),
            ),
        ],
      ),
    );
  }
}
