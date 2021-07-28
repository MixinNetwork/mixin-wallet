import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../db/mixin_database.dart';
import '../../util/constants.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/logger.dart';
import '../widget/address_add_widget.dart';
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
              const SizedBox(height: 12),
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
                          builder: (context) =>
                              AddressAddWidget(assetId: assetId),
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
            confirmDismiss: (direction) async {
              // https: //mixin.one/address?action=delete&asset=xxx&address=xxx
              final uri = Uri.https('mixin.one', 'address', {
                'action': 'delete',
                'asset': item.assetId,
                'address': item.addressId,
              });
              if (!await canLaunch(uri.toString())) {
                return false;
              }
              await launch(uri.toString());
              final ret = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => _DeleteConfirmDialog(address: item),
              );
              return ret == true;
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
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: InkWell(
          onTap: () {},
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
      );
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

class _DeleteConfirmDialog extends HookWidget {
  const _DeleteConfirmDialog({
    Key? key,
    required this.address,
  }) : super(key: key);

  final Addresse address;

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      var canceled = false;
      scheduleMicrotask(() async {
        while (!canceled) {
          try {
            final result = await context.appServices.client.addressApi
                .getAddressById(address.addressId);
            i('result: ${result.data}');
          } catch (error, stack) {
            if (error is DioError) {
              final mixinError = error.error as MixinError;
              if (mixinError.code == 404) {}
            }
            i('failed: $error, $stack');
            if (!canceled) {
              Navigator.of(context).pop(true);
            }
            break;
          }
          await Future.delayed(const Duration(milliseconds: 2000));
        }
      });
      return () => canceled = true;
    }, [address.addressId]);

    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.theme.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SizedBox(
          width: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              CircularProgressIndicator(
                color: context.theme.text,
                strokeWidth: 2,
              ),
              const SizedBox(height: 14),
              Text(context.l10n.delete,
                  style: TextStyle(
                    color: context.theme.text,
                    fontSize: 16,
                    height: 1.4,
                  )),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                      color: context.theme.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.only(
                        top: 12, bottom: 14, left: 54, right: 55),
                    child: Center(
                      child: Text(
                        context.l10n.cancel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
