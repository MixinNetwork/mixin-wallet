import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../../db/mixin_database.dart';
import '../../../util/constants.dart';
import '../../../util/extension/extension.dart';
import '../../../util/mixin_context.dart';
import '../../../util/web/web_utils.dart';
import '../buttons.dart';
import '../mixin_bottom_sheet.dart';
import '../tip_tile.dart';

Future<void> showRequestPaymentResultBottomSheet(
  BuildContext context, {
  required AssetResult asset,
  required String address,
  required String? tag,
  required String? memo,
  required String? amount,
  required String recipient,
}) async {
  final traceId = const Uuid().v4();
  final uri = Uri.https('mixin.one', 'pay', {
    'amount': amount,
    'trace': traceId,
    'asset': asset.assetId,
    'recipient': recipient,
    'memo': memo,
    'tag': tag,
    'address': address,
  });
  return showMixinBottomSheet(
    context: context,
    builder: (context) => _RequestPaymentResultBottomSheet(
      url: uri.toString(),
      formattedAmount: '$amount ${asset.symbol}',
    ),
    isScrollControlled: true,
  );
}

class _RequestPaymentResultBottomSheet extends StatelessWidget {
  const _RequestPaymentResultBottomSheet({
    required this.url,
    required this.formattedAmount,
  });

  final String url;

  final String formattedAmount;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: MediaQuery.of(context).size.height - 88,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(topRadius),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const MixinBottomSheetTitle(title: SizedBox()),
                Center(
                  child: SelectableText(
                    context.l10n.linkGenerated,
                    style: TextStyle(
                      color: context.colorScheme.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    enableInteractiveSelection: false,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SelectableText(
                    url,
                    style: TextStyle(
                      color: context.colorScheme.primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 26),
                QrImageView(
                  data: url,
                  size: 160,
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 26),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TipListLayout(
                    children: [
                      TipTile(
                        text: context.l10n.requestPaymentGeneratedTips,
                        fontWeight: FontWeight.w600,
                      ),
                      TipTile(
                        text:
                            context.l10n.requestPaymentAmount(formattedAmount),
                        highlight: formattedAmount,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(child: _CopyButton(url: url)),
                      const SizedBox(width: 15),
                      Expanded(
                        child: MixinPrimaryTextButton(
                          text: context.l10n.sendLink,
                          onTap: () {
                            final mixinContext = getMixinContext();
                            if (mixinContext.isEmpty) {
                              Share.share(url);
                            } else {
                              final dest =
                                  'mixin://send?data=${base64UrlEncode(utf8.encode(url))}&category=text';
                              launchUrl(Uri.parse(dest));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      );
}

class _CopyButton extends StatelessWidget {
  const _CopyButton({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    void copyUrl() {
      setClipboardText(url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(context.l10n.copyToClipboard),
        ),
      );
    }

    return OutlinedButton(
      onPressed: copyUrl,
      style: OutlinedButton.styleFrom(
        foregroundColor: context.colorScheme.primaryText,
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 24,
        ),
        minimumSize: const Size(110, 48),
        shape: const StadiumBorder(),
      ),
      child: SelectableText(
        context.l10n.copyLink,
        onTap: copyUrl,
        enableInteractiveSelection: false,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
