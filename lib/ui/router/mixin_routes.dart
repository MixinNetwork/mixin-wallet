import 'package:flutter/widgets.dart';
import 'package:vrouter/vrouter.dart';

import '../../service/profile/profile_manager.dart';
import '../../util/extension/extension.dart';
import '../../util/logger.dart';
import '../page/all_transactions.dart';
import '../page/asset_deposit.dart';
import '../page/asset_detail.dart';
import '../page/auth.dart';
import '../page/buy.dart';
import '../page/buy_success.dart';
import '../page/hidden_assets.dart';
import '../page/home.dart';
import '../page/not_found.dart';
import '../page/setting.dart';
import '../page/snapshot_detail.dart';
import '../page/swap.dart';
import '../page/transfer.dart';
import '../page/transfer_transactions.dart';
import '../page/withdrawal.dart';
import '../page/withdrawal_transactions.dart';

final homeUri = Uri(path: '/');
final authUri = Uri(path: '/auth');
final notFoundUri = Uri(path: '/404');
const withdrawalPath = '/withdrawal/:id';
const withdrawalTransactionsPath = '/withdrawal/:id/transactions';
const assetDetailPath = '/tokens/:id';
const assetDepositPath = '/tokens/:id/deposit';
const snapshotDetailPath = '/snapshots/:id';
final transactionsUri = Uri(path: '/transactions');
final hiddenAssetsUri = Uri(path: '/hiddenAssets');
const transferPath = '/transfer/:id';
const transferTransactionsPath = '/transfer/:id/transactions';
const settingPath = '/setting';
const buyPath = '/buy/:id';
const buySuccessPath = '/buySuccess';
const swapPath = '/swap';

List<VRouteElementBuilder> buildMixinRoutes(BuildContext context) => [
      VWidget(
        key: const ValueKey('Auth'),
        path: '/auth',
        widget: const AuthPage(),
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
                key: const ValueKey('Home'),
                path: homeUri.toString(),
                widget: const Home(),
                stackedRoutes: [
                  VWidget(
                      key: const ValueKey('Withdrawal'),
                      path: withdrawalPath,
                      widget: const Withdrawal(),
                      stackedRoutes: [
                        VWidget(
                          key: const ValueKey('WithdrawalTransactions'),
                          path: withdrawalTransactionsPath,
                          widget: const WithdrawalTransactions(),
                        )
                      ]),
                  VWidget(
                    key: const ValueKey('Transfer'),
                    path: transferPath,
                    widget: const Transfer(),
                    stackedRoutes: [
                      VWidget(
                        key: const ValueKey('TransferTransactions'),
                        path: transferTransactionsPath,
                        widget: const TransferTransactions(),
                      ),
                    ],
                  ),
                  VWidget(
                    key: const ValueKey('AssetDetail'),
                    path: assetDetailPath,
                    widget: const AssetDetail(),
                    stackedRoutes: [
                      VWidget(
                        key: const ValueKey('SnapshotDetail'),
                        path: snapshotDetailPath,
                        widget: const SnapshotDetail(),
                      ),
                    ],
                  ),
                  VWidget(
                    key: const ValueKey('AssetDeposit'),
                    path: assetDepositPath,
                    widget: const AssetDeposit(),
                  ),
                  VWidget(
                    key: const ValueKey('NotFound'),
                    path: notFoundUri.toString(),
                    widget: const NotFound(),
                  ),
                  VWidget(
                    key: const ValueKey('Setting'),
                    path: settingPath,
                    widget: const Setting(),
                    stackedRoutes: [
                      VWidget(
                        key: const ValueKey('Transactions'),
                        path: transactionsUri.toString(),
                        widget: const AllTransactions(),
                      ),
                      VWidget(
                        key: const ValueKey('HiddenAssets'),
                        path: hiddenAssetsUri.toString(),
                        widget: const HiddenAssets(),
                      ),
                    ],
                  ),
                  VWidget(
                    key: const ValueKey('Buy'),
                    path: buyPath,
                    widget: const Buy(),
                  ),
                  VWidget(
                    key: const ValueKey('BuySuccess'),
                    path: buySuccessPath,
                    widget: const BuySuccess(),
                  ),
                  VWidget(
                    key: const ValueKey('Swap'),
                    path: swapPath,
                    widget: const Swap(),
                  )
                ]),
          ]),
      VRouteRedirector(path: ':_(.+)', redirectTo: '/404'),
    ];
