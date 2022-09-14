import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/r.dart';
import '../../wyre/wyre_vo.dart';
import '../widget/buttons.dart';
import '../widget/mixin_appbar.dart';
import '../widget/symbol.dart';
import '../widget/transaction_info_tile.dart';

class BuySuccess extends HookWidget {
  const BuySuccess({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final queryParams = context.queryParameters;
    final assetId = queryParams['asset'];
    final fiatName = queryParams['fiat'];
    if (assetId == null || fiatName == null) {
      return const SizedBox();
    }

    final fiat = getWyreFiatByName(fiatName);
    if (fiat == null) {
      return const SizedBox();
    }

    useMemoizedFuture(() => context.appServices.updateAsset(assetId),
        keys: [assetId]);
    final asset = useMemoizedStream(
      () => context.appServices.assetResult(assetId).watchSingleOrNull(),
      keys: [assetId],
    ).data;
    if (asset == null) {
      return const SizedBox();
    }

    return Scaffold(
        backgroundColor: context.colorScheme.background,
        appBar: MixinAppBar(
          backgroundColor: context.colorScheme.background,
          title: Text(
            context.l10n.buy,
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: const MixinBackButton2(),
        ),
        body: _Body(asset: asset, fiat: fiat));
  }
}

class _Body extends StatelessWidget {
  const _Body({
    Key? key,
    required this.asset,
    required this.fiat,
  }) : super(key: key);

  final AssetResult asset;
  final WyreFiat fiat;

  @override
  Widget build(BuildContext context) {
    final queryParams = context.queryParameters;
    final sourceAmount = queryParams['sourceAmount'];
    final destAmount = queryParams['destAmount'];
    final networkFee = queryParams['networkFee'];
    final transactionFee = queryParams['transactionFee'];

    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: 16,
              color: context.colorScheme.thirdText,
            ),
            child: Text(context.l10n.buy),
          ),
          const SizedBox(height: 12),
          _AssetLayout(
            asset: asset,
            fiat: fiat,
          ),
          Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sourceAmount != null)
                  TransactionInfoTile(
                    title: Text(context.l10n.pay),
                    subtitle: SelectableText('$sourceAmount ${fiat.name}'),
                  ),
                if (destAmount != null)
                  TransactionInfoTile(
                    title: Text(context.l10n.receive),
                    subtitle: SelectableText('$destAmount ${asset.symbol}'),
                  ),
                if (networkFee != null)
                  TransactionInfoTile(
                    title: Text(context.l10n.networkFee),
                    subtitle: SelectableText('$networkFee ${fiat.name}'),
                  ),
                if (transactionFee != null)
                  TransactionInfoTile(
                    title: Text(context.l10n.transactionFee),
                    subtitle: SelectableText('$transactionFee ${fiat.name}'),
                  ),
              ]),
        ],
      ),
    ));
  }
}

class _AssetLayout extends StatelessWidget {
  const _AssetLayout({
    Key? key,
    required this.asset,
    required this.fiat,
  }) : super(key: key);

  final AssetResult asset;
  final WyreFiat fiat;

  @override
  Widget build(BuildContext context) => Row(children: [
        Image.asset(
          fiat.flag,
          width: 40,
          height: 40,
        ),
        const SizedBox(width: 10),
        DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: 16,
            color: context.colorScheme.primaryText,
          ),
          child: Text(fiat.name),
        ),
        const SizedBox(width: 16),
        SvgPicture.asset(
          R.resourcesIcDoubleArrowSvg,
          width: 12,
          height: 12,
        ),
        const SizedBox(width: 16),
        SymbolIconWithBorder(
          symbolUrl: asset.iconUrl,
          chainUrl: asset.chainIconUrl,
          size: 32,
          chainBorder: const BorderSide(color: Color(0xfff8f8f8), width: 1),
          chainSize: 8,
        ),
        const SizedBox(width: 10),
        DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: 16,
            color: context.colorScheme.primaryText,
          ),
          child: Text(asset.symbol),
        ),
      ]);
}
