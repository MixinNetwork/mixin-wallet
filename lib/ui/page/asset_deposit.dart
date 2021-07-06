import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../../util/r.dart';
import '../router/mixin_router_delegate.dart';
import '../widget/action_button.dart';
import '../widget/buttons.dart';
import '../widget/symbol.dart';

class AssetDeposit extends StatelessWidget {
  const AssetDeposit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => _AssetDepositLoader(key: key);
}

class _AssetDepositLoader extends HookWidget {
  const _AssetDepositLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO query assets from database
    // The asset id of CNB is: 965e5c6e-434c-3fa9-b780-c50f43cd955c
    final assetId = context.pathParameters['id'];

    useEffect(() {
      context.appServices.updateAsset(assetId!);
    }, [assetId]);

    final assetResults = context.watchCommonVariables.assetResults;
    final data = assetResults
        ?.firstWhereOrNull((element) => element?.assetId == assetId);

    final notFound = assetResults != null && data == null;

    useEffect(() {
      if (notFound) {
        context
            .read<MixinRouterDelegate>()
            .pushNewUri(MixinRouterDelegate.notFoundUri);
      }
    }, [notFound]);

    if (data == null) {
      return const SizedBox();
    }
    return _AssetDepositPage(asset: data);
  }
}

class _AssetDepositPage extends StatelessWidget {
  const _AssetDepositPage({Key? key, required this.asset}) : super(key: key);

  final AssetResult asset;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.theme.background,
        appBar: AppBar(
          backgroundColor: context.theme.background,
          title: Text(
            context.l10n.deposit,
            style: TextStyle(
              color: context.theme.text,
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
          leading: const MixinBackButton(),
          actions: <Widget>[
            ActionButton(
                name: R.resourcesIcQuestionSvg,
                color: BrightnessData.themeOf(context).icon,
                onTap: () {}),
            const SizedBox(width: 122),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: Column(children: [
            const SizedBox(height: 20),
            _Round(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                children: [
                  SymbolIcon(
                      symbolUrl: asset.iconUrl,
                      chainUrl: asset.iconUrl,
                      size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          asset.symbol.overflow,
                          style: TextStyle(
                            color: context.theme.text,
                            fontSize: 16,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${asset.balance}${asset.symbol}',
                          style: TextStyle(
                            color: context.theme.secondaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SvgPicture.asset(R.resourcesIcArrowDownSvg),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            _Item(
              title: context.l10n.address,
              desc: asset.destination ?? '',
              onCopy: () {},
              showQrCode: () {},
            ),
            const SizedBox(height: 10),
            asset.needShowMemo
                ? _Item(
                    title: context.l10n.memo,
                    desc: asset.tag ?? '',
                    onCopy: () {},
                    showQrCode: () {},
                  )
                : const SizedBox(height: 4),
            const SizedBox(height: 10),
            asset.needShowMemo
                ? _Round(
                    height: null,
                    radius: 8,
                    padding: const EdgeInsets.symmetric(
                        vertical: 13, horizontal: 16),
                    color: const Color(0xfffcf1f2),
                    child: Text(
                      context.l10n.depositNotice(asset.symbol),
                      style: TextStyle(
                        color: context.theme.red,
                        fontSize: 14,
                        fontFamily: 'SF Pro Text',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : const SizedBox(height: 1),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(context.l10n.depositOnly(asset.symbol),
                    style: TextStyle(
                      color: context.theme.text,
                      fontSize: 14,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(context.l10n.depositOnlyDesc(asset.symbol),
                    style: TextStyle(
                      color: context.theme.secondaryText,
                      fontSize: 14,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w400,
                    )),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(context.l10n.averageArrival('10 minutes'),
                  style: TextStyle(
                    color: context.theme.secondaryText,
                    fontSize: 14,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w400,
                  )),
            ),
            const SizedBox(height: 70),
          ]),
        ),
      );
}

class _Round extends StatelessWidget {
  const _Round({
    Key? key,
    required this.child,
    this.height = 56,
    this.padding = const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
    this.radius = 12,
    this.color = const Color(0xfff8f8f8),
  }) : super(key: key);

  final Widget child;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: color,
        ),
        child: child,
      );
}

class _Item extends StatelessWidget {
  const _Item({
    Key? key,
    required this.title,
    required this.desc,
    required this.onCopy,
    required this.showQrCode,
  }) : super(key: key);

  final String title;
  final String desc;
  final VoidCallback onCopy;
  final VoidCallback showQrCode;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 56,
      ),
      child: _Round(
        height: null,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        color: context.theme.secondaryText,
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      )),
                  const SizedBox(height: 4),
                  Text(desc,
                      softWrap: true,
                      style: TextStyle(
                        color: context.theme.text,
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      )),
                ],
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  children: [
                    ActionButton(
                        name: R.resourcesIcCopySvg,
                        color: BrightnessData.themeOf(context).icon,
                        onTap: () {}),
                    const SizedBox(width: 12),
                    ActionButton(
                        name: R.resourcesIcScanSvg,
                        color: BrightnessData.themeOf(context).icon,
                        onTap: () {}),
                  ],
                )),
            const SizedBox(height: 70),
          ],
        ),
      ));
}
