import 'package:flutter/foundation.dart';
import 'package:vrouter/vrouter.dart';

import '../../service/auth/auth_manager.dart';
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
final withdrawalUri = Uri(path: '/withdrawal');
const assetDetailPath = '/asset${kDebugMode ? '' : 's'}/:id';
const assetDepositPath = '/asset${kDebugMode ? '' : 's'}/:id/deposit';
const snapshotDetailPath = '/snapshots/:id';

final mixinRoutes = [
  VGuard(
    beforeEnter: (redirector) async {
      if (!isLogin) return;
      redirector.to('/');
    },
    stackedRoutes: [
      VWidget(path: '/auth', widget: const AuthPage()),
    ],
  ),
  VGuard(
      beforeEnter: (redirector) async {
        if (isLogin) return;
        redirector.to('/auth');
      },
      stackedRoutes: [
        VWidget(path: homeUri.toString(), widget: const Home()),
        VWidget(path: withdrawalUri.toString(), widget: const Withdrawal()),
        VWidget(path: assetDetailPath, widget: const AssetDetail()),
        VWidget(path: assetDepositPath, widget: const AssetDeposit()),
        VWidget(path: snapshotDetailPath, widget: const SnapshotDetail()),
        VWidget(path: notFoundUri.toString(), widget: const NotFound()),
      ]),
  VRouteRedirector(path: ':_(.+)', redirectTo: '/404'),
];
