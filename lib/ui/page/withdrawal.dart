import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
    return _WithdrawalPage(asset: data);
  }
}

class _WithdrawalPage extends HookWidget {
  const _WithdrawalPage({
    Key? key,
    required this.asset,
  }) : super(key: key);

  final AssetResult asset;

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: context.colorScheme.background,
      appBar: MixinAppBar(
        leading: const MixinBackButton2(),
        backgroundColor: context.colorScheme.background,
        title: SelectableText(
          context.l10n.sendToAddress,
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
            enable: address.value != null,
            onTap: () {
              final addressValue = address.value;
              if (addressValue == null) {
                return;
              }
              context.push(
                withdrawalTransactionsPath.toUri({'id': asset.assetId}).replace(
                  queryParameters: {
                    'destination': addressValue.destination,
                    'tag': addressValue.tag
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          const SizedBox(height: 20),
          TransferAssetHeader(asset: asset),
          const SizedBox(height: 16),
          TransferAddressWidget(
            address: address.value,
            onAddressChanged: (value) => address.value = value,
            asset: asset,
          ),
          const SizedBox(height: 8),
          TransferAmountWidget(amount: amount, asset: asset),
          const SizedBox(height: 8),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            child: _FeeText(asset: asset, address: address.value),
          ),
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

                final uri = Uri.https('mixin.one', 'withdrawal', {
                  'asset': asset.assetId,
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
          const SizedBox(height: 36),
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
          color: context.colorScheme.thirdText,
          fontSize: 12,
          height: 2,
          fontWeight: FontWeight.w600,
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
