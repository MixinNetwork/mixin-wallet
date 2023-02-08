import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:web_qrcode/web_qrcode.dart' as impl;
import 'package:web_qrcode/web_qrcode.dart';

import '../../../ui/widget/buttons.dart';
import '../../../ui/widget/mixin_appbar.dart';

Future<List<String>> getCameras() => impl.getCameras();

class QrcodeScannerDialog extends HookWidget {
  const QrcodeScannerDialog({Key? key}) : super(key: key);

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
