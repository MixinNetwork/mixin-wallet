import 'package:flutter/widgets.dart';
import 'package:vrouter/vrouter.dart';

import '../../service/profile/profile_manager.dart';
import '../../util/extension/extension.dart';
import '../../util/logger.dart';
import '../page/all_transactions.dart';
import '../page/asset_deposit.dart';
import '../page/asset_detail.dart';
import '../page/auth.dart';
import '../page/home.dart';
import '../page/not_found.dart';
import '../page/snapshot_detail.dart';
import '../page/withdrawal.dart';

final homeUri = Uri(path: '/');
final authUri = Uri(path: '/auth');
final notFoundUri = Uri(path: '/404');
const withdrawalPath = '/withdrawal/:id';
const assetDetailPath = '/tokens/:id';
const assetDepositPath = '/tokens/:id/deposit';
const snapshotDetailPath = '/snapshots/:id';
final transactionsUri = Uri(path: '/transactions');

List<VRouteElementBuilder> buildMixinRoutes(BuildContext context) => [
      VGuard(
        beforeEnter: (redirector) async {
          i('check is login: $isLogin');
          if (!isLogin) return;
          redirector.to('/');
        },
        stackedRoutes: [
          VWidget(
            key: const ValueKey('Auth'),
            path: '/auth',
            widget: const AuthPage(),
          ),
        ],
      ),
      VGuard(
          beforeEnter: (redirector) async {
            i('check is login: $isLogin');
            if (isLogin) {
              await context.appServices.initDbFuture;
              return;
            }
            redirector.to('/auth');
          },
          stackedRoutes: [
            VWidget(
                path: homeUri.toString(),
                widget: const Home(),
                stackedRoutes: [
                  VWidget(
                    key: const ValueKey('Withdrawal'),
                    path: withdrawalPath,
                    widget: const Withdrawal(),
                  ),
                  VWidget(
                    key: const ValueKey('AssetDetail'),
                    path: assetDetailPath,
                    widget: const AssetDetail(),
                  ),
                  VWidget(
                    key: const ValueKey('AssetDeposit'),
                    path: assetDepositPath,
                    widget: const AssetDeposit(),
                  ),
                  VWidget(
                    key: const ValueKey('SnapshotDetail'),
                    path: snapshotDetailPath,
                    widget: const SnapshotDetail(),
                  ),
                  VWidget(
                    key: const ValueKey('NotFound'),
                    path: notFoundUri.toString(),
                    widget: const NotFound(),
                  ),
                  VWidget(
                    key: const ValueKey('Transactions'),
                    path: transactionsUri.toString(),
                    widget: const AllTransactions(),
                  )
                ]),
          ]),
      VRouteRedirector(path: ':_(.+)', redirectTo: '/404'),
    ];
