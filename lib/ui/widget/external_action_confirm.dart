import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../util/extension/extension.dart';
import '../../util/logger.dart';

/// Return true indicator action run success.
typedef ConfirmLoopAction = Future<bool> Function();

Future<bool> showAndWaitingExternalAction({
  required BuildContext context,
  required Uri uri,
  required ConfirmLoopAction action,
  required Widget hint,
}) async {
  final uriString = uri.toString();
  if (!await canLaunch(uriString)) {
    return false;
  }
  await launch(uri.toString());
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _ExternalActionConfirmDialog(
      loopAction: action,
      key: ValueKey(uri),
      hint: hint,
    ),
  );
  return result == true;
}

class _ExternalActionConfirmDialog extends HookWidget {
  const _ExternalActionConfirmDialog({
    required Key key,
    required this.loopAction,
    this.loopInterval = const Duration(seconds: 2),
    required this.hint,
  }) : super(key: key);

  final ConfirmLoopAction loopAction;

  final Duration loopInterval;

  final Widget hint;

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      var canceled = false;
      scheduleMicrotask(() async {
        while (!canceled) {
          try {
            final succeed = await loopAction();
            if (succeed) {
              if (!canceled) {
                Navigator.of(context).pop(true);
              }
              break;
            }
          } catch (error, stack) {
            d('error: $error $stack');
            Navigator.of(context).pop();
            break;
          }
          await Future.delayed(loopInterval);
        }
      });
      return () => canceled = true;
    }, [key]);

    return Center(
      child: Material(
        color: context.theme.background,
        borderRadius: BorderRadius.circular(20),
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
              DefaultTextStyle.merge(
                style: TextStyle(
                  color: context.theme.text,
                  fontSize: 16,
                  height: 1.4,
                ),
                child: hint,
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    primary: context.theme.accent,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    minimumSize: const Size(110, 48),
                    onPrimary: Colors.white,
                    shape: const StadiumBorder()),
                child: Text(
                  context.l10n.cancel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
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
