import 'package:flutter/widgets.dart';
import 'package:vrouter/vrouter.dart';

import '../../service/account_provider.dart';
import '../../util/extension/extension.dart';
import '../../util/logger.dart';
import '../page/all_transactions.dart';
import '../page/asset_detail.dart';
import '../page/auth.dart';
import '../page/authentications.dart';
import '../page/change_pin.dart';
import '../page/collectible_detail.dart';
import '../page/collectibles_collection.dart';
import '../page/create_pin.dart';
import '../page/hidden_assets.dart';
import '../page/home.dart';
import '../page/not_found.dart';
import '../page/pin_logs.dart';
import '../page/setting.dart';
import '../page/snapshot_detail.dart';

final homeUri = Uri(path: '/');
final authUri = Uri(path: '/auth');
final notFoundUri = Uri(path: '/404');
const withdrawalPath = '/withdrawal/:id';
const withdrawalTransactionsPath = '/withdrawal/:id/transactions';
const assetDetailPath = '/tokens/:id';
const assetDepositPath = '/tokens/:id/deposit';
const snapshotDetailPath = '/snapshots/:id';
final transactionsUri = Uri(path: '/transactions');
const transactionsSnapshotDetailPath = '/transactions/snapshots/:id';
final hiddenAssetsUri = Uri(path: '/hiddenAssets');
const settingPath = '/setting';
const buyChoosePath = '/buy';
const buySuccessPath = '/buySuccess';
const swapPath = '/swap';
const swapTransactionsPath = '/swap/transactions';
const swapDetailPath = '/swap/:id/detail';
const collectiblesCollectionPath = '/collection/:id';
const collectiblePath = '/collectible/:id';

const createPinPath = '/create_pin';
const pinLogsPath = '$settingPath/pin_logs';
const changePinPath = '$settingPath/change_pin';
const authenticationsPath = '$settingPath/authentications';

List<VRouteElementBuilder> buildMixinRoutes(BuildContext context) => [
      VWidget(
        key: const ValueKey('Auth'),
        path: '/auth',
        widget: const AuthPage(),
      ),
      VWidget(
        key: const ValueKey('CreatePin'),
        path: createPinPath,
        widget: const CreatePinPage(),
      ),
      VGuard(
          beforeEnter: (redirector) async {
            final authProvider = context.read<AuthProvider>();
            i('check is login: ${authProvider.isLogin}');
            if (!authProvider.isLogin) {
              redirector.to('/auth');
              return;
            }
            await context.appServices.initServiceFuture;
            if (authProvider.isLoginByCredential) {
              final hasPin = authProvider.account!.hasPin;
              d('check has pin: $hasPin');
              if (!hasPin) {
                redirector.to(createPinPath);
                return;
              }
            }
          },
          stackedRoutes: [
            VWidget(
                key: const ValueKey('Home'),
                path: homeUri.toString(),
                widget: const Home(),
                stackedRoutes: [
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
                        stackedRoutes: [
                          VWidget(
                            key: const ValueKey('TransactionsSnapshotDetail'),
                            path: transactionsSnapshotDetailPath,
                            widget: const SnapshotDetail(),
                          ),
                        ],
                      ),
                      VWidget(
                        key: const ValueKey('HiddenAssets'),
                        path: hiddenAssetsUri.toString(),
                        widget: const HiddenAssets(),
                      ),
                      VWidget(
                        key: const ValueKey('PinLogs'),
                        path: pinLogsPath,
                        widget: const PinLogs(),
                      ),
                      VWidget(
                        key: const ValueKey('ChangePin'),
                        path: changePinPath,
                        widget: const ChangePin(),
                      ),
                      VWidget(
                        key: const ValueKey('Authentications'),
                        path: authenticationsPath,
                        widget: const Authentications(),
                      ),
                    ],
                  ),
                  VWidget(
                    path: collectiblesCollectionPath,
                    key: const ValueKey('CollectiblesGroup'),
                    widget: const CollectiblesCollection(),
                    stackedRoutes: [
                      VWidget(
                        path: collectiblePath,
                        key: const ValueKey('CollectibleDetail'),
                        widget: const CollectibleDetail(),
                      ),
                    ],
                  ),
                ]),
          ]),
      VRouteRedirector(path: ':_(.+)', redirectTo: '/404'),
    ];
