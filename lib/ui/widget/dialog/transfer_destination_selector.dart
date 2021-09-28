import 'package:flutter/material.dart';

import '../../../db/mixin_database.dart';
import '../../../util/extension/extension.dart';
import '../mixin_bottom_sheet.dart';
import 'address_selection_widget.dart';
import 'contact_selection_widget.dart';

Future<dynamic> showTransferDestinationSelectorDialog({
  required BuildContext context,
  required AssetResult asset,
  dynamic initialSelected,
}) async {
  assert(initialSelected == null ||
      initialSelected is Addresse ||
      initialSelected is User);
  return showMixinBottomSheet(
    context: context,
    builder: (context) => SizedBox(
      height: MediaQuery.of(context).size.height - 70,
      child: _TransferDestinationSelectorDialog(
        asset: asset,
        initialSelected: initialSelected,
      ),
    ),
    isScrollControlled: true,
  );
}

class _TransferDestinationSelectorDialog extends StatelessWidget {
  const _TransferDestinationSelectorDialog({
    Key? key,
    required this.asset,
    required this.initialSelected,
  }) : super(key: key);

  final AssetResult asset;
  final dynamic initialSelected;

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: TabBarView(
                children: [
                  ContactSelectionBottomSheet(
                    selectedUser: initialSelected is User
                        ? initialSelected as User
                        : null,
                  ),
                  AddressSelectionWidget(
                    assetId: asset.assetId,
                    chainId: asset.chainId,
                    selectedAddress: initialSelected is Addresse
                        ? initialSelected as Addresse
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _Header extends StatelessWidget {
  const _Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 70,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TabBar(
                    indicatorColor: context.colorScheme.primaryText,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: context.colorScheme.primaryText,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 24),
                    isScrollable: true,
                    unselectedLabelColor: context.colorScheme.thirdText,
                    indicatorPadding: const EdgeInsets.only(bottom: 8),
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: [
                      _Tab(text: context.l10n.contact),
                      _Tab(text: context.l10n.address),
                    ],
                  ),
                ],
              ),
            ),
            const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: BottomSheetCloseButton(),
              ),
            ),
          ],
        ),
      );
}

class _Tab extends StatelessWidget {
  const _Tab({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12, top: 8),
        child: Text(text),
      );
}
