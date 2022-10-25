import 'dart:convert';

import 'package:decimal/decimal.dart';
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
import '../widget/external_action_confirm.dart';
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
                    var signed = Decimal.zero;
                    for (final output in outputs) {
                      if (output.state == sdk.CollectibleOutput.kStateSigned) {
                        signed += Decimal.parse(output.amount);
                      }
                    }
                    d('signed: $signed');

                    if (signed > Decimal.zero) {
                      final utxo = outputs.firstWhereOrNull(
                          (element) => element?.signedTx.isNotEmpty ?? false);
                      if (utxo == null) {
                        e('failed to find valid output: $outputs');
                        return;
                      }
                      try {
                        final response = await context
                            .appServices.client.collectibleApi
                            .requests(
                          sdk.CollectibleRequestAction.sign,
                          utxo.signedTx,
                        );
                        final request = response.data;
                        request.receivers;
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

                      final txInputs = <dynamic>[];
                      final txOutputs = <dynamic>[];

                      var inputAmount = Decimal.zero;

                      late CollectibleOutputData utxo;
                      for (final output in outputs) {
                        utxo = output;
                        inputAmount += Decimal.parse(output.amount);
                        txInputs.add({
                          'hash': output.transactionHash,
                          'index': output.outputIndex,
                        });
                        if (inputAmount >= Decimal.one) {
                          break;
                        }
                      }

                      if (inputAmount < Decimal.one) {
                        e('too much');
                        return;
                      }

                      final tx = {
                        'version': 2,
                        'asset': item.mixinId,
                        'extra': item.nfo,
                      };

                      final ghostKey = (await context
                              .appServices.client.outputApi
                              .loadGhostKeys(
                        [
                          sdk.OutputRequest(
                            receivers: [user.userId],
                            index: 0,
                          ),
                          sdk.OutputRequest(
                            receivers:
                                (jsonDecode(utxo.receivers) as List).cast(),
                            index: 1,
                          ),
                        ],
                      ))
                          .data;

                      final output = {
                        'mask': ghostKey[0].mask,
                        'keys': ghostKey[0].keys,
                        'amount': '1',
                        'script': buildThresholdScript(1),
                      };
                      txOutputs.add(output);
                      if (inputAmount > Decimal.one) {
                        final utxo = outputs.first;
                        final change = {
                          'mask': ghostKey[1].mask,
                          'keys': ghostKey[1].keys,
                          'amount': (inputAmount - Decimal.one).toString(),
                          'script':
                              buildThresholdScript(utxo.receiversThreshold),
                        };
                        txOutputs.add(change);
                      }

                      tx['inputs'] = txInputs;
                      tx['outputs'] = txOutputs;

                      d('transaction: $tx');
                      final raw = buildTransaction(tx);

                      final response = await context
                          .appServices.client.collectibleApi
                          .requests(
                        sdk.CollectibleRequestAction.sign,
                        raw,
                      );
                      final codeId = response.data.codeId;
                      await showAndWaitingExternalAction(
                        context: context,
                        uri: Uri.https('mixin.one', 'code/$codeId'),
                        action: () async {
                          final ret = context.appServices.client.accountApi
                              .code(codeId);
                          return true;
                        },
                        hint: Text(context.l10n.waitingActionDone),
                      );
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

String buildThresholdScript(int threshold) {
  var s = threshold.toRadixString(16);
  if (s.length == 1) {
    s = '0$s';
  }
  if (s.length > 2) {
    throw Exception('invalid threshold: $threshold');
  }
  return 'fffe$s';
}
