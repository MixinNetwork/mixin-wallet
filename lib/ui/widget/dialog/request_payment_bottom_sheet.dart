import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../db/mixin_database.dart';
import '../../../util/constants.dart';
import '../../../util/extension/extension.dart';
import '../buttons.dart';
import '../mixin_bottom_sheet.dart';
import '../transfer.dart';

class RequestPaymentBottomSheet extends HookWidget {
  const RequestPaymentBottomSheet({
    required this.address,
    required this.asset,
    super.key,
    this.tag,
  });

  final AssetResult asset;

  final String address;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final amount = useValueNotifier('');
    final memo = useValueNotifier('');
    return SizedBox(
      height: MediaQuery.of(context).size.height - 88,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(topRadius),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              MixinBottomSheetTitle(title: Text(context.l10n.requestPayment)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TransferAmountWidget(amount: amount, asset: asset),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TransferMemoWidget(
                  initialValue: memo.value,
                  onMemoInput: (value) => memo.value = value,
                ),
              ),
              const SizedBox(height: 8),
              const Spacer(),
              Center(
                child: Builder(
                    builder: (context) => MixinPrimaryTextButton(
                          onTap: () {
                            if (amount.value.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    content: Text(context.l10n.emptyAmount)),
                              );
                              return;
                            }
                            Navigator.pop(context, [amount.value, memo.value]);
                          },
                          text: context.l10n.continueText,
                        )),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
