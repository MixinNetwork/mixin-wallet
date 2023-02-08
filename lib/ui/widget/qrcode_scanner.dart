import 'dart:async';

import 'package:flutter/material.dart';

import '../../service/profile/profile_manager.dart';
import '../../util/extension/extension.dart';
import '../../util/logger.dart';
import '../../util/web/qrcode_scanner_dialog.dart';
import '../../util/web/telegram_web_app.dart';

Future<String?> scanTextFromQrcode({
  required BuildContext context,
}) async {
  if (isLoginByCredential &&
      Telegram.instance.isMobilePlatform &&
      Telegram.instance.isVersionGreaterOrEqual('6.4')) {
    // if current is telegram web app, try to use telegram native qr code scanner.
    final completer = Completer<String?>();
    Telegram.instance.showScanQrPopup('', (result) {
      completer.complete(result);
      return true;
    });
    return completer.future;
  }

  final cameras = <String>[];
  try {
    cameras.addAll(await getCameras());
  } catch (e) {
    i('get cameras failed: $e');
  }
  if (cameras.isEmpty) {
    await showDialog<void>(
        context: context, builder: (context) => const _NoCameraTips());
    return null;
  }

  return showDialog(
    context: context,
    builder: (context) => const QrcodeScannerDialog(),
  );
}

class _NoCameraTips extends StatelessWidget {
  const _NoCameraTips({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: Material(
          color: context.theme.background,
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 32,
                  ),
                  child: Text(
                    context.l10n.errorNoCamera,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.colorScheme.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4B7CDD),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      minimumSize: const Size(110, 48),
                      textStyle: TextStyle(
                        color: context.colorScheme.background,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: SelectableText(
                      context.l10n.ok,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      onTap: () => Navigator.of(context).pop(),
                      enableInteractiveSelection: false,
                    )),
                const SizedBox(height: 32)
              ],
            ),
          ),
        ),
      );
}
