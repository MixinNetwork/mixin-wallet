import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';

import '../../db/mixin_database.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../widget/address_add_widget.dart';
import '../widget/external_action_confirm.dart';
import '../widget/mixin_appbar.dart';
import '../widget/mixin_bottom_sheet.dart';
import '../widget/search_header_widget.dart';

class WithdrawalAddresses extends HookWidget {
  const WithdrawalAddresses({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final assetId = context.pathParameters['id']!;

    useMemoizedFuture(
      () => context.appServices.updateAddresses(assetId),
      keys: [assetId],
    );

    final asset = useMemoizedStream(
      () => context.appServices.assetResult(assetId).watchSingleOrNull(),
      keys: [assetId],
    ).data;

    final addresses = useMemoizedStream(
          () => context.appServices.addresses(assetId).watch(),
          keys: [assetId],
        ).data ??
        const [];

    final filterKeywords = useState('');
    final filterList = useMemoized(() {
      if (filterKeywords.value.isEmpty) {
        return addresses;
      }
      return addresses
          .where(
            (e) =>
                e.label.containsIgnoreCase(filterKeywords.value) ||
                e.displayAddress().containsIgnoreCase(filterKeywords.value),
          )
          .toList();
    }, [filterKeywords.value, addresses]);

    final controller = useTextEditingController();

    return Scaffold(
        appBar: MixinAppBar(
          title: Text(context.l10n.address),
          backButtonColor: Colors.white,
        ),
        backgroundColor: context.theme.accent,
        body: Container(
          decoration: BoxDecoration(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(topRadius)),
            color: context.theme.background,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SearchHeaderWidget(
                  hintText: context.l10n.addressSearchHint,
                  onChanged: (k) {
                    filterKeywords.value = k;
                  },
                  controller: controller,
                  cancelVisible: false,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(child: _WithdrawalAddressList(addresses: filterList)),
              const SizedBox(height: 10),
              SizedBox(
                  width: 160,
                  height: 44,
                  child: TextButton(
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              const EdgeInsets.symmetric(
                                  horizontal: 22, vertical: 11)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                      side: BorderSide(
                                          color: context.theme.accent)))),
                      onPressed: () {
                        showMixinBottomSheet(
                          context: context,
                          builder: (context) => AddressAddWidget(
                              assetId: assetId, chainId: asset?.chainId),
                          isScrollControlled: true,
                        );
                      },
                      child: Text('+ ${context.l10n.addAddress}',
                          style: TextStyle(
                            fontSize: 16,
                            color: context.theme.accent,
                          )))),
              const SizedBox(height: 20),
            ],
          ),
        ));
  }
}

class _WithdrawalAddressList extends StatelessWidget {
  const _WithdrawalAddressList({
    Key? key,
    required this.addresses,
  }) : super(key: key);

  final List<Addresse> addresses;

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final item = addresses[index];
          return _SwipeToDismiss(
            key: ValueKey(item.addressId),
            child: _Item(address: item),
            onDismiss: () {
              context.appServices.mixinDatabase.addressDao.deleteAddress(item);
            },
            confirmDismiss: (direction) {
              // https: //mixin.one/address?action=delete&asset=xxx&address=xxx
              final uri = Uri.https('mixin.one', 'address', {
                'action': 'delete',
                'asset': item.assetId,
                'address': item.addressId,
              });

              return showAndWaitingExternalAction(
                  context: context,
                  uri: uri,
                  hint: Text(context.l10n.delete),
                  action: () async {
                    try {
                      await context.appServices.client.addressApi
                          .getAddressById(item.addressId);
                      return false;
                    } catch (error) {
                      if (error is DioError) {
                        final mixinError = error.error as MixinError;
                        if (mixinError.code == 404) {
                          return true;
                        }
                      }
                      rethrow;
                    }
                  });
            },
          );
        },
      );
}

class _Item extends StatelessWidget {
  const _Item({
    Key? key,
    required this.address,
  }) : super(key: key);

  final Addresse address;

  @override
  Widget build(BuildContext context) => Material(
      color: context.theme.background,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Text(
                        address.label.overflow,
                        style: TextStyle(
                            color: context.theme.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.4),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat.yMMMd().format(address.updatedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.theme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.displayAddress(),
                    softWrap: true,
                    style: TextStyle(
                      color: context.theme.secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
      ));
}

class _SwipeToDismiss extends StatelessWidget {
  const _SwipeToDismiss({
    required Key key,
    required this.child,
    required this.onDismiss,
    this.confirmDismiss,
  }) : super(key: key);

  final Widget child;
  final VoidCallback onDismiss;
  final ConfirmDismissCallback? confirmDismiss;

  @override
  Widget build(BuildContext context) {
    final Widget indicator = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Text(
        context.l10n.delete,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
    return Dismissible(
      key: ValueKey(key),
      onDismissed: (direction) => onDismiss(),
      confirmDismiss: confirmDismiss,
      background: Container(
        color: context.theme.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: indicator,
        ),
      ),
      secondaryBackground: Container(
        color: context.theme.red,
        child: Align(
          alignment: Alignment.centerRight,
          child: indicator,
        ),
      ),
      child: child,
    );
  }
}
