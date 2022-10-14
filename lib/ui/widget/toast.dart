// ignore_for_file: use_colored_box

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:overlay_support/overlay_support.dart';

import '../../generated/r.dart';
import '../../util/extension/extension.dart';
import 'text.dart';

const _kToastDuration = Duration(milliseconds: 2000);

OverlaySupportEntry showLoading() => showOverlay(
      (context, progress) => Opacity(
        opacity: progress,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
              strokeWidth: 3,
            ),
          ),
        ),
      ),
      key: ModalKey('global_loading'),
      duration: Duration.zero,
      curve: Curves.easeIn,
    );

void showSuccessToast(String title, [String? message]) {
  _showToast(
    R.resourcesToastSucceedSvg,
    title,
    message,
  );
}

void showWarningToast(String title, [String? message]) {
  _showToast(
    R.resourcesToastWarningSvg,
    title,
    message,
  );
}

void showErrorToast(String title, [String? message]) {
  _showToast(
    R.resourcesToastErrorSvg,
    title,
    message,
  );
}

void _showToast(String assetName, String title, [String? message]) {
  showOverlay(
    (context, progress) => Opacity(
      opacity: progress,
      child: _MixinToast(
        assetName: assetName,
        title: title,
        message: message,
      ),
    ),
    key: const ValueKey('mixin_toast'),
    duration: _kToastDuration,
    curve: Curves.easeIn,
  );
}

class _MixinToast extends StatelessWidget {
  const _MixinToast({
    required this.assetName,
    required this.title,
    this.message,
  });

  final String title;
  final String? message;

  final String assetName;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 64,
                minHeight: 48,
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                minWidth: 64,
              ),
              child: Material(
                color: context.colorScheme.background,
                borderRadius: const BorderRadius.all(Radius.circular(37)),
                elevation: 5,
                shadowColor: Colors.grey.withOpacity(0.2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 16),
                    SvgPicture.asset(
                      assetName,
                      width: 38,
                      height: 38,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MixinText(
                            title,
                            style: TextStyle(
                              color: context.colorScheme.primaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          _ToastMessage(message: message)
                        ],
                      ),
                    ),
                    const SizedBox(width: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class _ToastMessage extends StatelessWidget {
  const _ToastMessage({
    required this.message,
  });

  final String? message;

  @override
  Widget build(BuildContext context) => Builder(
        builder: (context) {
          final m = message;
          if (m == null) return const SizedBox();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),
              MixinText(
                m,
                style: TextStyle(
                  color: context.colorScheme.secondaryText,
                  fontSize: 14,
                ),
              ),
            ],
          );
        },
      );
}
