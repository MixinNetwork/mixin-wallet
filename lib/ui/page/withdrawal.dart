import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:uuid/uuid.dart';

import '../../db/mixin_database.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../widget/external_action_confirm.dart';
import '../widget/mixin_appbar.dart';
import '../widget/transfer.dart';

class Withdrawal extends HookWidget {
  const Withdrawal({Key? key}) : super(key: key);

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
    return _WithdrawalPage(initialAsset: data);
  }
}

class _WithdrawalPage extends HookWidget {
  const _WithdrawalPage({
    Key? key,
    required this.initialAsset,
  }) : super(key: key);

  final AssetResult initialAsset;

  @override
  Widget build(BuildContext context) {
    final asset = useState(initialAsset);
    final address = useState<Addresse?>(null);
    final amount = useValueNotifier('');
    final memo = useValueNotifier('');

    useEffect(() {
      final addressId = address.value?.addressId;
      if (addressId == null) {
        return null;
      }
      // to check if selected address has been deleted.
      final subscription = context.mixinDatabase.addressDao
          .addressesById(addressId)
          .watchSingleOrNull()
          .listen((event) {
        if (event == null) {
          address.value = null;
        }
      });
      return subscription.cancel;
    }, [address.value?.addressId]);

    return Scaffold(
      backgroundColor: context.theme.accent,
      appBar: MixinAppBar(
        title: Text(context.l10n.sendToAddress),
        backButtonColor: Colors.white,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(topRadius)),
          color: context.theme.background,
        ),
        child: Column(children: [
          const SizedBox(height: 24),
          TransferAssetItem(
            asset: asset.value,
            onAssetChange: (value) => asset.value = value,
          ),
          const SizedBox(height: 8),
          TransferAddressWidget(
            address: address.value,
            onAddressChanged: (value) => address.value = value,
            asset: asset.value,
          ),
          const SizedBox(height: 8),
          TransferAmountWidget(amount: amount, asset: asset.value),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            child: _FeeText(asset: asset.value, address: address.value),
          ),
          const SizedBox(height: 8),
          TransferMemoWidget(onMemoInput: (value) => memo.value = value),
          const Spacer(),
          HookBuilder(builder: (context) {
            useListenable(amount);
            return _SendButton(
              enable: amount.value.isNotEmpty && address.value != null,
              onTap: () async {
                if (amount.value.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(context.l10n.emptyAmount)));
                  return;
                }
                if (address.value == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(context.l10n.noAddressSelected)));
                  return;
                }
                final traceId = const Uuid().v4();
                final assetId = asset.value.assetId;

                final uri = Uri.https('mixin.one', 'withdrawal', {
                  'asset': assetId,
                  'address': address.value!.addressId,
                  'amount': amount.value,
                  'trace': traceId,
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
          const SizedBox(height: 30),
        ]),
      ),
    );
  }
}

class _FeeText extends StatelessWidget {
  const _FeeText({Key? key, this.address, required this.asset})
      : super(key: key);

  final Addresse? address;
  final AssetResult asset;

  @override
  Widget build(BuildContext context) {
    if (address == null) {
      return const SizedBox();
    }
    final reserveVal = double.tryParse(address!.reserve);
    final dustVal = double.tryParse(address!.dust ?? '0');
    final showReserve = reserveVal != null && reserveVal > 0;
    final showDust = dustVal != null && dustVal > 0;

    return Text.rich(TextSpan(
        style: TextStyle(
          color: context.theme.secondaryText,
          fontSize: 13,
          height: 2,
        ),
        children: [
          TextSpan(text: '${context.l10n.networkFee} '),
          TextSpan(
              text: '${address!.fee} ${asset.chainSymbol}',
              style: TextStyle(
                color: context.theme.text,
                fontWeight: FontWeight.bold,
              )),
          if (showDust)
            TextSpan(text: '\n${context.l10n.minimumWithdrawal} ')
          else
            const TextSpan(),
          if (showDust)
            TextSpan(
                text: '${address!.dust} ${asset.symbol}',
                style: TextStyle(
                  color: context.theme.text,
                  fontWeight: FontWeight.bold,
                ))
          else
            const TextSpan(),
          if (showReserve)
            TextSpan(text: '\n${context.l10n.minimumReserve} ')
          else
            const TextSpan(),
          if (showReserve)
            TextSpan(
                text: '${address!.reserve} ${asset.symbol}',
                style: TextStyle(
                  color: context.theme.text,
                  fontWeight: FontWeight.bold,
                ))
          else
            const TextSpan(),
        ]));
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
