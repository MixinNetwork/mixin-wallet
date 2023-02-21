import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';
import 'package:rational/rational.dart';

import '../constants.dart';
import '../extension/extension.dart';
import '../logger.dart';
import 'ethereum.dart';

class ExternalTransfer with EquatableMixin {
  ExternalTransfer({
    required this.destination,
    required this.amount,
    required this.assetId,
    this.memo,
    this.fee,
  });

  final String destination;
  final String amount;
  final String assetId;
  final Rational? fee;
  final String? memo;

  @override
  List<Object?> get props => [destination, amount, assetId, fee, memo];
}

extension StringExtension on String {
  bool isEthereumURLString() => startsWith('ethereum:');

  String addSlashesIfNeeded() {
    if (contains('://')) {
      return this;
    }
    return replaceFirst(':', '://');
  }
}

const externalTransferAssetIdMap = {
  'bitcoin': ChainId.bitcoin,
  'ethereum': ChainId.ethereum,
  'litecoin': ChainId.litecoin,
  'dash': ChainId.dash,
  'dogecoin': ChainId.dogecoin,
  'monero': ChainId.monero,
  'solana': ChainId.solana,
};

typedef GetAddressFeeCallback = Future<AddressFee?> Function(
  String assetId,
  String destination,
);

typedef GetAssetPrecisionByIdCallback = Future<AssetPrecision?> Function(
  String assetId,
);

typedef FindAssetIdByAssetKeyCallback = Future<String?> Function(
  String assetKey,
);

Future<ExternalTransfer?> parseExternalTransferUri(
  String url, {
  required GetAddressFeeCallback getAddressFee,
  required FindAssetIdByAssetKeyCallback findAssetIdByAssetKey,
  required GetAssetPrecisionByIdCallback getAssetPrecisionById,
}) async {
  if (url.isEthereumURLString()) {
    return parseEthereum(
      url,
      getAddressFee: getAddressFee,
      findAssetIdByAssetKey: findAssetIdByAssetKey,
      getAssetPrecisionById: getAssetPrecisionById,
    );
  }

  final uri = Uri.tryParse(url.addSlashesIfNeeded());
  if (uri == null) {
    e('invalid uri: $url');
    return null;
  }
  final scheme = uri.scheme;
  final assetId = externalTransferAssetIdMap[scheme];

  if (assetId == null || assetId.isEmpty) {
    e('invalid scheme: $scheme');
    return null;
  }

  if (assetId == ChainId.solana) {
    final splToken = uri.queryParameters['spl-token'];
    if (splToken != null && splToken.isNotEmpty) {
      return null;
    }
  }

  var destination = uri.host;

  if (destination.isEmpty) {
    e('destination is empty. $uri');
    return null;
  }

  // uri.host is case insensitive, so we need to use the original string.
  final index = url.toLowerCase().indexOf(destination);
  if (index == -1) {
    e('invalid destination: $destination');
    return null;
  }
  destination = url.substring(index, index + destination.length);

  if (!destination.equalsIgnoreCase(uri.host)) {
    e('invalid destination: $destination $url');
    return null;
  }

  final addressFeeResponse = await getAddressFee(assetId, destination);
  if (addressFeeResponse == null ||
      addressFeeResponse.destination.toLowerCase() !=
          destination.toLowerCase()) {
    return null;
  }

  var amount = uri.queryParameters['amount'];
  amount ??= uri.queryParameters['tx_amount'];
  if (amount == null || amount.isEmpty || amount.amountWithE) {
    e('amount is empty or invalid. $amount');
    return null;
  }

  amount = amount.asDecimal.toString();
  final amountBD = Decimal.tryParse(amount);
  if (amountBD == null) {
    return null;
  }
  if (amount != amountBD.toString()) {
    return null;
  }
  var memo = uri.queryParameters['memo'];
  if (memo != null) {
    memo = Uri.decodeQueryComponent(memo);
  }

  return ExternalTransfer(
    destination: addressFeeResponse.destination,
    amount: amount,
    assetId: assetId,
    fee: Rational.tryParse(addressFeeResponse.fee),
    memo: memo,
  );
}
