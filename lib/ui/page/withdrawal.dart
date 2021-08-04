import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../db/mixin_database.dart';
import '../../service/profile/profile_manager.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/r.dart';
import '../router/mixin_routes.dart';
import '../widget/address_selection_widget.dart';
import '../widget/asset_selection_list_widget.dart';
import '../widget/avatar.dart';
import '../widget/mixin_appbar.dart';
import '../widget/mixin_bottom_sheet.dart';
import '../widget/round_container.dart';
import '../widget/symbol.dart';

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
    final assetState = useState(this.asset);
    final asset = assetState.value;

    final selectedAddress = useState<Addresse?>(null);
    final selectedUser = useState<User?>(null);
    final valueFirst = useState<double>(0);
    final valueSecond = useState<String>('0.00'.currencyFormatWithoutSymbol);
    final symbolFirst = useState<bool>(false);
    final switched = useState<bool>(false);
    final sendEnable = useState<bool>(false);

    final currency = auth!.account.fiatCurrency;

    final assetPriceUsd =
        useState<double>(double.tryParse(asset.priceUsd) ?? 1);
    final controller = useTextEditingController();
    useEffect(() {
      void notifyChanged() {
        refreshValues(controller, symbolFirst, switched, selectedAddress,
            selectedUser, sendEnable, valueFirst, valueSecond, assetPriceUsd);
      }

      controller.addListener(notifyChanged);
      return () {
        controller.removeListener(notifyChanged);
      };
    }, [controller]);

    assert(!(selectedAddress.value != null && selectedUser.value != null));

    useEffect(() {
      final addressId = selectedAddress.value?.addressId;
      if (addressId == null) {
        return null;
      }
      // to check if selected address has been deleted.
      final subscription = context.mixinDatabase.addressDao
          .addressesById(addressId)
          .watchSingleOrNull()
          .listen((event) {
        if (event == null) {
          selectedAddress.value = null;
        }
      });
      return subscription.cancel;
    }, [selectedAddress.value?.addressId]);

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
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              showMixinBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => AssetSelectionListWidget(
                  onTap: (AssetResult assetResult) {
                    context.replace(
                        withdrawalPath.toUri({'id': assetResult.assetId}));
                    assetState.value = assetResult;
                    if (selectedAddress.value?.assetId != assetResult.assetId) {
                      assetPriceUsd.value =
                          double.tryParse(assetResult.priceUsd) ?? 1;
                      selectedAddress.value = null;
                      switched.value = false;
                      refreshValues(
                          controller,
                          symbolFirst,
                          switched,
                          selectedAddress,
                          selectedUser,
                          sendEnable,
                          valueFirst,
                          valueSecond,
                          assetPriceUsd);
                    }
                  },
                  selectedAssetId: asset.assetId,
                ),
              );
            },
            child: RoundContainer(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                children: [
                  SymbolIconWithBorder(
                    symbolUrl: asset.iconUrl,
                    chainUrl: asset.chainIconUrl,
                    size: 32,
                    chainSize: 8,
                  ),
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
                            fontWeight: FontWeight.w400,
                          ),
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
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () async {
              final selected = await showAddressSelectionBottomSheet(
                context: context,
                assetId: asset.assetId,
                selectedAddress: selectedAddress.value,
              );
              if (selected is Addresse) {
                selectedAddress.value = selected;
                selectedUser.value = null;
              } else if (selected is User) {
                selectedAddress.value = null;
                selectedUser.value = selected;
              }
              refreshValues(
                  controller,
                  symbolFirst,
                  switched,
                  selectedAddress,
                  selectedUser,
                  sendEnable,
                  valueFirst,
                  valueSecond,
                  assetPriceUsd);
            },
            child: _AddressOrUserWidget(
              selectedAddress: selectedAddress.value,
              selectedUser: selectedUser.value,
            ),
          ),
          const SizedBox(height: 10),
          RoundContainer(
            height: null,
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(children: [
                        IntrinsicWidth(
                            child: TextField(
                          style: TextStyle(
                            color: context.theme.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: symbolFirst.value
                                ? ''
                                : '0.00 ${switched.value ? currency : asset.symbol}',
                            border: InputBorder.none,
                          ),
                          controller: controller,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(
                                switched.value
                                    ? r'^\d*\.?\d{0,2}'
                                    : r'^\d*\.?\d{0,8}')),
                          ],
                        )),
                        Text(
                          symbolFirst.value
                              ? (switched.value ? currency : asset.symbol)
                              : '',
                          style: TextStyle(
                            color: context.theme.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ]),
                      Text(
                        '${valueSecond.value} ${switched.value ? asset.symbol : currency}',
                        style: TextStyle(
                          color: context.theme.secondaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                        onTap: () {
                          switched.value = !switched.value;
                          refreshValues(
                              controller,
                              symbolFirst,
                              switched,
                              selectedAddress,
                              selectedUser,
                              sendEnable,
                              valueFirst,
                              valueSecond,
                              assetPriceUsd);
                        },
                        child: SvgPicture.asset(R.resourcesIcSwitchSvg))),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            child: _FeeText(asset: asset, address: selectedAddress.value),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomCenter,
            child: InkWell(
                onTap: () async {
                  final amount = switched.value
                      ? valueSecond.value
                      : controller.text.trim();
                  if (amount.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text(context.l10n.emptyAmount)));
                    return;
                  }
                  final address = selectedAddress.value;
                  final user = selectedUser.value;
                  if (address == null && user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text(context.l10n.noAddressSelected)));
                    return;
                  }
                  final traceId = const Uuid().v4();
                  final assetId = assetState.value.assetId;

                  // TODO add memo.
                  Uri? uri;
                  if (address != null) {
                    final addressId = selectedAddress.value!.addressId;
                    uri = Uri.https('mixin.one', 'withdrawal', {
                      'asset': assetId,
                      'address': addressId,
                      'amount': amount,
                      'trace': traceId,
                    });
                  } else if (user != null) {
                    uri = Uri.https('mixin.one', 'pay', {
                      'amount': amount,
                      'trace': traceId,
                      'asset': assetId,
                      'recipient': user.userId,
                    });
                  }
                  assert(uri != null);
                  if (!await canLaunch(uri.toString())) {
                    return;
                  }
                  await launch(uri.toString());
                  await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AlertDialog(
                            content: Text(context.l10n.finishVerifyPIN),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(context.l10n.cancel)),
                              TextButton(
                                  onPressed: () async {
                                    unawaited(context.appServices
                                        .updateAsset(assetId));
                                    context.pop();
                                  },
                                  child: Text(context.l10n.sure)),
                            ],
                          ));
                },
                child: Container(
                    width: 160,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: sendEnable.value
                          ? context.theme.accent
                          : const Color(0xffB2B3C7),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      vertical: 11,
                      horizontal: 22,
                    ),
                    child: Text(context.l10n.send,
                        style: TextStyle(
                          fontSize: 16,
                          color: context.theme.background,
                        )))),
          ),
          const SizedBox(height: 70),
        ]),
      ),
    );
  }

  void refreshValues(
      TextEditingController controller,
      ValueNotifier<bool> symbolFirst,
      ValueNotifier<bool> switched,
      ValueNotifier<Addresse?> addressSelected,
      ValueNotifier<User?> userSelected,
      ValueNotifier<bool> sendEnable,
      ValueNotifier<double> valueFirst,
      ValueNotifier<String> valueSecond,
      ValueNotifier<double> assetPriceUsd) {
    final s = controller.text;
    symbolFirst.value = s.isNotEmpty;
    if (switched.value) {
      valueFirst.value = double.tryParse(controller.text) ?? 0;
      valueSecond.value =
          (valueFirst.value / assetPriceUsd.value).currencyFormatCoin;
    } else {
      valueFirst.value = double.tryParse(controller.text) ?? 0;
      valueSecond.value =
          (valueFirst.value * assetPriceUsd.value).currencyFormatWithoutSymbol;
    }
    sendEnable.value = valueFirst.value > 0 &&
        (addressSelected.value != null || userSelected.value != null);
  }
}

class _AddressOrUserWidget extends StatelessWidget {
  const _AddressOrUserWidget({
    Key? key,
    this.selectedAddress,
    this.selectedUser,
  }) : super(key: key);

  final Addresse? selectedAddress;
  final User? selectedUser;

  @override
  Widget build(BuildContext context) {
    Widget? child;
    Widget? leading;
    if (selectedAddress == null && selectedUser == null) {
      child = Text(
        context.l10n.selectFromAddressBook,
        style: TextStyle(
          color: context.theme.secondaryText,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      );
    } else if (selectedAddress != null) {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          Text(
            selectedAddress!.label.overflow,
            style: TextStyle(
              color: context.theme.text,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          Text(
            selectedAddress!.displayAddress().formatAddress(),
            style: TextStyle(
              color: context.theme.secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(flex: 2),
        ],
      );
    } else if (selectedUser != null) {
      leading = Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Avatar(
            size: 32,
            avatarUrl: selectedUser!.avatarUrl,
            userId: selectedUser!.userId,
            borderWidth: 0,
            name: selectedUser!.fullName ?? '?'),
      );
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          Text(
            selectedUser!.fullName?.overflow ?? '',
            style: TextStyle(
              color: context.theme.text,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(flex: 1),
          Text(
            selectedUser!.identityNumber,
            style: TextStyle(
              color: context.theme.secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(flex: 2),
        ],
      );
    }
    assert(child != null);
    return RoundContainer(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) leading,
          Expanded(child: child ?? const SizedBox()),
          SvgPicture.asset(R.resourcesIcArrowDownSvg)
        ],
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
          showDust
              ? TextSpan(text: '\n${context.l10n.minimumWithdrawal} ')
              : const TextSpan(),
          showDust
              ? TextSpan(
                  text: '${address!.dust} ${asset.symbol}',
                  style: TextStyle(
                    color: context.theme.text,
                    fontWeight: FontWeight.bold,
                  ))
              : const TextSpan(),
          showReserve
              ? TextSpan(text: '\n${context.l10n.minimumReserve} ')
              : const TextSpan(),
          showReserve
              ? TextSpan(
                  text: '${address!.reserve} ${asset.symbol}',
                  style: TextStyle(
                    color: context.theme.text,
                    fontWeight: FontWeight.bold,
                  ))
              : const TextSpan(),
        ]));
  }
}
