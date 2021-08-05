import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../db/mixin_database.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
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
    return _TransferToContactBody(initialAsset: data);
  }
}

class _TransferToContactBody extends HookWidget {
  const _TransferToContactBody({
    Key? key,
    required this.initialAsset,
  }) : super(key: key);
  final AssetResult initialAsset;

  @override
  Widget build(BuildContext context) {
    final asset = useState(initialAsset);
    final user = useState<User?>(null);
    final amount = useValueNotifier('');
    return Scaffold(
      backgroundColor: context.theme.accent,
      appBar: MixinAppBar(
        title: Text(context.l10n.sendToContact),
        backButtonColor: Colors.white,
      ),
      body: Material(
        color: context.theme.background,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(topRadius)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              TransferAssetItem(
                asset: asset.value,
                onAssetChange: (value) => asset.value = value,
              ),
              const SizedBox(height: 8),
              TransferContactWidget(
                user: user.value,
                onUserChanged: (value) => user.value = value,
              ),
              const SizedBox(height: 8),
              TransferAmountWidget(amount: amount, asset: asset.value),
              const Spacer(),
              HookBuilder(builder: (context) {
                useListenable(amount);
                return _SendButton(
                  enable: amount.value.isNotEmpty && user.value != null,
                  onTap: () async {
                    if (amount.value.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(context.l10n.emptyAmount)));
                      return;
                    }
                    if (user.value == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text(context.l10n.noContactSelected),
                      ));
                      return;
                    }

                    final traceId = const Uuid().v4();
                    final assetId = asset.value.assetId;

                    final uri = Uri.https('mixin.one', 'pay', {
                      'amount': amount.value,
                      'trace': traceId,
                      'asset': assetId,
                      'recipient': user.value!.userId,
                    });

                    if (!await canLaunch(uri.toString())) {
                      return;
                    }
                    await launch(uri.toString());
                    await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                        content: Text(context.l10n.finishVerifyPIN),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(context.l10n.cancel)),
                          TextButton(
                              onPressed: () async {
                                unawaited(
                                    context.appServices.updateAsset(assetId));
                                context.pop();
                              },
                              child: Text(context.l10n.sure)),
                        ],
                      ),
                    );
                  },
                );
              }),
              const SizedBox(height: 30),
            ],
          ),
        ),
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
  Widget build(BuildContext context) => Material(
        borderRadius: BorderRadius.circular(12),
        color: enable ? context.theme.accent : const Color(0xffB2B3C7),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 160,
            height: 44,
            child: Center(
              child: Text(
                context.l10n.send,
                style: TextStyle(
                  fontSize: 16,
                  color: context.theme.background,
                ),
              ),
            ),
          ),
        ),
      );
}
