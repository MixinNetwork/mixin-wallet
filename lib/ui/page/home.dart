import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../util/extension/extension.dart';
import '../../util/r.dart';
import '../router/mixin_router_delegate.dart';
import '../widget/interactable_box.dart';
import '../widget/mixin_appbar.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: const MixinAppbar(),
        body: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: _Header(),
            ),
            const SliverToBoxAdapter(
              child: _AssetHeader(),
            ),
            SliverToBoxAdapter(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      context
                          .read<MixinRouterDelegate>()
                          .pushNewUri(MixinRouterDelegate.withdrawalUri);
                    },
                    child: const Text('go withdrawal'),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.read<MixinRouterDelegate>().pushNewUri(
                              MixinRouterDelegate.assetDetailPath
                                  .toUri({'id': 'foo'}),
                            ),
                    child: const Text('go assetDetail'),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.read<MixinRouterDelegate>().pushNewUri(
                              MixinRouterDelegate.snapshotDetailPath
                                  .toUri({'id': 'foo'}),
                            ),
                    child: const Text('go snapshotDetail'),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.read<MixinRouterDelegate>().pushNewUri(
                              MixinRouterDelegate.assetDepositPath
                                  .toUri({'id': 'foo'}),
                            ),
                    child: const Text('go assetDeposit'),
                  ),
                ],
              ),
            ),
            const SliverFillRemaining(),
          ],
        ),
      );
}

class _AssetHeader extends StatelessWidget {
  const _AssetHeader({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        height: 50,
        color: context.theme.accent,
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            color: Colors.white,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 20),
                child: Text(
                  context.l10n.assets,
                  style: const TextStyle(
                    color: Color(0xff222222),
                    fontSize: 16,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: InteractableBox(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(R.assetsHamburgerMenuSvg),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _Header extends StatelessWidget {
  const _Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const symbol = r'$';
    const balance = 38834.67;
    const balanceOfBtc = 4.6173;

    return Container(
      height: 203,
      color: context.theme.accent,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            context.l10n.totalBalance,
            style: const TextStyle(
              color: Color(0xccffffff),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                symbol,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                balance.currencyFormat,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            context.l10n.balanceOfBtc(balanceOfBtc.currencyFormat00),
            style: const TextStyle(
              color: Color(0x7fffffff),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Button(
                icon: SvgPicture.asset(R.assetsSendSvg),
                text: Text(context.l10n.send),
                onTap: () {},
              ),
              const SizedBox(width: 20),
              _Button(
                icon: SvgPicture.asset(R.assetsReceiveSvg),
                text: Text(context.l10n.receive),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    Key? key,
    required this.icon,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  final Widget icon;
  final Widget text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InteractableBox(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0x19ffffff),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 32,
          ),
          child: DefaultTextStyle(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 6),
                text,
              ],
            ),
          ),
        ),
      );
}
