import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;
import 'package:uuid/uuid.dart';

import '../../db/mixin_database.dart';
import '../../generated/r.dart';
import '../../service/account_provider.dart';
import '../../service/profile/pin_session.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/logger.dart';
import '../router/mixin_routes.dart';
import '../widget/action_button.dart';
import '../widget/avatar.dart';
import '../widget/buttons.dart';
import '../widget/dialog/transfer_bottom_sheet.dart';
import '../widget/dialog/transfer_destination_selector.dart';
import '../widget/external_action_confirm.dart';
import '../widget/mixin_appbar.dart';
import '../widget/transfer.dart';

class Withdrawal extends HookWidget {
  const Withdrawal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var assetId = usePathParameter('id', path: withdrawalPath);

    if (assetId.isEmpty) {
      assetId = bitcoin;
    }
    final data = useMemoizedFuture(
      () => context.appServices.assetResult(assetId).getSingleOrNull(),
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
    final user = useState<User?>(null);

    final amount = useValueNotifier('');
    final memo = useValueNotifier('');

    assert(address.value == null || user.value == null);

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

    final feeAsset = useMemoizedFuture<AssetResult?>(
      () async {
        if (address.value == null) {
          return null;
        }
        return context.appServices.findOrSyncAsset(address.value!.feeAssetId);
      },
      keys: [address.value],
    ).data;

    return Scaffold(
      backgroundColor: context.colorScheme.background,
      appBar: MixinAppBar(
        leading: const MixinBackButton2(),
        backgroundColor: context.colorScheme.background,
        title: SelectableText(
          '${context.l10n.send} ${asset.symbol}',
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
            enable: address.value != null || user.value != null,
            onTap: () {
              final parameter = <String, String?>{};

              if (address.value != null) {
                final addressValue = address.value!;
                parameter.addAll({
                  'destination': addressValue.destination,
                  'tag': addressValue.tag
                });
              } else if (user.value != null) {
                final userValue = user.value!;
                parameter.addAll({
                  'opponent': userValue.userId,
                });
              }

              if (parameter.isEmpty) {
                return;
              }
              final uri = withdrawalTransactionsPath.toUri(
                  {'id': asset.assetId}).replace(queryParameters: parameter);
              context.push(uri);
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
          _TransferTarget(address: address, user: user, asset: asset),
          const SizedBox(height: 8),
          TransferAmountWidget(amount: amount, asset: asset),
          const SizedBox(height: 8),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: user.value != null
                  ? TransferMemoWidget(
                      initialValue: memo.value,
                      onMemoInput: (value) => memo.value = value,
                    )
                  : const SizedBox(),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: address.value == null
                ? const SizedBox.shrink()
                : Container(
                    alignment: Alignment.centerLeft,
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    child: _FeeText(
                      asset: asset,
                      address: address.value!,
                      feeAsset: feeAsset,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          const Spacer(),
          HookBuilder(builder: (context) {
            useListenable(amount);
            return SendButton(
              enable: amount.value.isNotEmpty &&
                  ((address.value != null && feeAsset != null) ||
                      user.value != null),
              onTap: () async {
                if (amount.value.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(context.l10n.emptyAmount)));
                  return;
                }
                if (address.value == null && user.value == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        context.l10n.noWithdrawalDestinationSelected,
                      )));
                  return;
                }

                final traceId = const Uuid().v4();

                if (context.read<AuthProvider>().isLoginByCredential) {
                  final addressId = address.value?.addressId;
                  if (addressId == null) {
                    e('addressId is null');
                    return;
                  }
                  final ret = await showTransferVerifyBottomSheet(
                    context,
                    address: address.value!,
                    asset: asset,
                    feeAsset: feeAsset!,
                    amount: amount.value,
                    postVerification: (context, pin) async {
                      final api = context.appServices.client.transferApi;
                      final response =
                          await api.withdrawal(sdk.WithdrawalRequest(
                        addressId: addressId,
                        amount: amount.value,
                        pin: encryptPin(context,pin)!,
                        traceId: traceId,
                        memo: memo.value,
                      ));
                      await context.appServices.mixinDatabase.snapshotDao
                          .insertAll([response.data]);
                      Navigator.of(context).pop(true);
                    },
                  );
                  if (ret ?? false) {
                    context.pop();
                  }
                } else {
                  final Uri uri;

                  if (address.value != null) {
                    uri = Uri.https('mixin.one', 'withdrawal', {
                      'asset': asset.assetId,
                      'address': address.value!.addressId,
                      'amount': amount.value,
                      'trace': traceId,
                      'memo': memo.value,
                    });
                  } else {
                    assert(user.value != null);
                    uri = Uri.https('mixin.one', 'pay', {
                      'amount': amount.value,
                      'trace': traceId,
                      'asset': asset.assetId,
                      'recipient': user.value!.userId,
                      'memo': memo.value,
                    });
                  }

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
                }
              },
            );
          }),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

class _FeeText extends StatelessWidget {
  const _FeeText({
    Key? key,
    required this.address,
    required this.asset,
    required this.feeAsset,
  }) : super(key: key);

  final Addresse address;
  final AssetResult asset;
  final AssetResult? feeAsset;

  @override
  Widget build(BuildContext context) {
    final reserveVal = double.tryParse(address.reserve);
    final dustVal = double.tryParse(address.dust ?? '0');
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
          if (feeAsset != null) ...[
            TextSpan(text: '${context.l10n.networkFee} '),
            TextSpan(
              text: '${address.fee} ${feeAsset!.symbol}',
              style: TextStyle(
                color: context.theme.text,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (showDust) ...[
            TextSpan(text: '\n${context.l10n.minimumWithdrawal} '),
            TextSpan(
              text: '${address.dust} ${asset.symbol}',
              style: TextStyle(
                color: context.theme.text,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (showReserve) ...[
            TextSpan(text: '\n${context.l10n.minimumReserve} '),
            TextSpan(
              text: '${address.reserve} ${asset.symbol}',
              style: TextStyle(
                color: context.theme.text,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ]));
  }
}

class _TransferTarget extends StatelessWidget {
  const _TransferTarget({
    Key? key,
    required this.user,
    required this.address,
    required this.asset,
  }) : super(key: key);

  final ValueNotifier<User?> user;
  final ValueNotifier<Addresse?> address;
  final AssetResult asset;

  @override
  Widget build(BuildContext context) {
    Future<void> onTap() async {
      final result = await showTransferDestinationSelectorDialog(
        context: context,
        asset: asset,
        initialSelected: user.value ?? address.value,
      );
      if (result is Addresse) {
        address.value = result;
        user.value = null;
      } else if (result is User) {
        user.value = result;
        address.value = null;
      }
    }

    Widget content;

    if (user.value != null) {
      final user = this.user.value!;
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Avatar(
              size: 40,
              avatarUrl: user.avatarUrl,
              userId: user.userId,
              borderWidth: 0,
              name: user.fullName ?? '?'),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 3),
                SelectableText(
                  user.fullName?.overflow ?? '',
                  enableInteractiveSelection: false,
                  onTap: onTap,
                  style: TextStyle(
                    color: context.colorScheme.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(flex: 1),
                SelectableText(
                  user.identityNumber,
                  enableInteractiveSelection: false,
                  onTap: onTap,
                  style: TextStyle(
                    color: context.colorScheme.thirdText,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ],
      );
    } else if (address.value != null) {
      final address = this.address.value!;
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          SelectableText(
            address.label.overflow,
            onTap: onTap,
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            enableInteractiveSelection: false,
          ),
          const Spacer(flex: 1),
          SelectableText(
            address.displayAddress().formatAddress(),
            onTap: onTap,
            style: TextStyle(
              color: context.colorScheme.thirdText,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            enableInteractiveSelection: false,
          ),
          const Spacer(flex: 2),
        ],
      );
    } else {
      content = SelectableText(
        context.l10n.selectContactOrAddress,
        enableInteractiveSelection: false,
        onTap: onTap,
        style: TextStyle(
          fontSize: 16,
          color: context.colorScheme.thirdText,
        ),
      );
    }

    return Material(
      color: context.colorScheme.surface,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: SizedBox(
          height: 64,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 16),
              Expanded(child: content),
              SvgPicture.asset(R.resourcesIcArrowDownSvg),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }
}
