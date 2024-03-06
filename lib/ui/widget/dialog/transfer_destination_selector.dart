import 'package:flutter/material.dart';

import '../../../db/mixin_database.dart';
import '../../../util/extension/extension.dart';
import '../mixin_bottom_sheet.dart';
import 'contact_selection_widget.dart';

Future<dynamic> showTransferDestinationSelectorDialog({
  required BuildContext context,
  required AssetResult asset,
  dynamic initialSelected,
}) async {
  assert(initialSelected == null ||
      initialSelected is Addresses ||
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
    required this.asset,
    required this.initialSelected,
  });

  final AssetResult asset;
  final dynamic initialSelected;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          SizedBox(
            height: 72,
            child: Center(
              child: Text(
                context.l10n.contact,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: ContactSelectionBottomSheet(
              selectedUser:
                  initialSelected is User ? initialSelected as User : null,
            ),
          ),
        ],
      );
}
