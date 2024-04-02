import 'package:flutter/material.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';
import 'package:uuid/uuid.dart';

import '../../generated/r.dart';
import '../../util/extension/extension.dart';
import '../../util/logger.dart';
import '../../util/pay/external_transfer_uri_parser.dart';
import '../route.dart';
import 'action_button.dart';
import 'dialog/auth_bottom_sheet.dart';
import 'dialog/transfer_bottom_sheet.dart';
import 'toast.dart';

extension _UrlExtension on String {
  bool get isMixinCodes =>
      startsWith('mixin://codes') || startsWith('https://mixin.one/codes');
}

class ScanButton extends StatelessWidget {
  const ScanButton({super.key});

  @override
  Widget build(BuildContext context) => ActionButton(
        name: R.resourcesIcScanBlackSvg,
        size: 24,
        onTap: () async {},
      );
}

Future<void> handleUrl(BuildContext context, String url) async {
  if (url.isMixinCodes) {
    await _handleMixinCodes(context, url);
  } else {
    await _handleExternalPay(context, url);
  }
}

Future<void> _handleMixinCodes(BuildContext context, String url) async {
  final segments = Uri.tryParse(url)?.pathSegments;
  if (segments == null || segments.isEmpty) {
    e('invalid mixin codes url: $url');
    return;
  }
  final code = segments.length >= 2 ? segments[1] : segments[0];
  try {
    final response = await context.appServices.client.accountApi.code(code);
    final data = response.data;
    if (data is AuthorizationResponse) {
      await showAuthBottomSheet(
        context,
        name: data.app.name,
        scopes: data.scopes,
        number: data.app.appNumber,
        authId: data.authorizationId,
      );
    }
  } catch (error, stacktrace) {
    e('code error. $error $stacktrace');
    showErrorToast(error.toDisplayString(context));
    return;
  }
}

Future<void> _handleExternalPay(BuildContext context, String text) async {
  final loadingEntry = showLoading();
  ExternalTransfer? result;
  try {
    result = await parseExternalTransferUri(
      text,
      getAddressFee: (assetId, destination) async {
        final api = context.appServices.client.accountApi;
        final resp = await api.getExternalAddressFee(
            assetId: assetId, destination: destination);
        return resp.data;
      },
      findAssetIdByAssetKey: (assetKey) async {
        final assetId = await context.mixinDatabase.assetDao
            .findAssetIdByAssetKey(assetKey);
        return assetId;
      },
      getAssetPrecisionById: (assetId) async {
        final api = context.appServices.client.assetApi;
        final response = await api.getAssetById(assetId);
        return response.data;
      },
    );
  } on ParseExternalTransferUriException catch (e) {
    loadingEntry.dismiss();

    final String message;
    if (e is NoAssetFound) {
      message = context.l10n.externalPayNoAssetFound;
    } else {
      message = context.l10n.invalidPayUrl(text);
    }
    showErrorToast(message);
    return;
  } catch (error, stacktrace) {
    loadingEntry.dismiss();
    e('parseExternalTransferUri error. $error $stacktrace');
    showErrorToast(error.toDisplayString(context));
    return;
  }

  d('parseExternalTransferUri result. $result');

  final asset = await context.appServices.findOrSyncAsset(result.assetId);
  if (asset == null) {
    loadingEntry.dismiss();
    showErrorToast(context.l10n.noAsset);
    return;
  }
  loadingEntry.dismiss();
  final traceId = const Uuid().v4();
  final ret = await showTransferToExternalUrlBottomSheet(
    context: context,
    asset: asset,
    transfer: result,
    traceId: traceId,
  );
  if (!ret) {
    return;
  }
  // transaction success, to asset detail page.
  AssetDetailRoute(asset.assetId).go(context);
}
