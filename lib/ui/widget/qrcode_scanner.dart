import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:web_qrcode/web_qrcode.dart';

import '../../util/extension/extension.dart';
import '../../util/logger.dart';
import 'buttons.dart';
import 'mixin_appbar.dart';

Future<String?> scanTextFromQrcode({
  required BuildContext context,
}) async {
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
    builder: (context) => const _QrcodeScannerDialog(),
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

class _QrcodeScannerDialog extends HookWidget {
  const _QrcodeScannerDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final qrcodeReaderKey = useMemoized(GlobalKey<QrCodeReaderState>.new);
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: QrCodeReader(
              key: qrcodeReaderKey,
              successCallback: (text) async {
                await qrcodeReaderKey.currentState?.stopScanner();
                Navigator.pop(context, text);
              },
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: MixinAppBar(
              backgroundColor: Colors.transparent,
              leading: MixinBackButton(
                onTap: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
