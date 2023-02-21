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

typedef GetAddressFeeCallback = Future<AddressFee> Function(
  String assetId,
  String destination,
);

typedef GetAssetPrecisionByIdCallback = Future<AssetPrecision> Function(
  String assetId,
);

typedef FindAssetIdByAssetKeyCallback = Future<String?> Function(
  String assetKey,
);

class ParseExternalTransferUriException implements Exception {}

class InvalidUri extends ParseExternalTransferUriException {
  InvalidUri(this.uri);

  final String uri;

  @override
  String toString() => 'InvalidUri: $uri';
}

class InvalidScheme extends ParseExternalTransferUriException {
  InvalidScheme(this.scheme);

  final String scheme;

  @override
  String toString() => 'InvalidScheme: $scheme';
}

class InvalidChainId extends ParseExternalTransferUriException {
  InvalidChainId(this.chainId);

  final int chainId;

  @override
  String toString() => 'InvalidChainId: $chainId';
}

class NoAssetFound extends ParseExternalTransferUriException {
  NoAssetFound(this.assetKey);

  final String? assetKey;

  @override
  String toString() => 'NoAssetFound: $assetKey';
}

Future<ExternalTransfer> parseExternalTransferUri(
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
    throw InvalidUri(url);
  }
  final scheme = uri.scheme;
  final assetId = externalTransferAssetIdMap[scheme];

  if (assetId == null || assetId.isEmpty) {
    throw InvalidScheme(scheme);
  }

  if (assetId == ChainId.solana) {
    final splToken = uri.queryParameters['spl-token'];
    if (splToken != null && splToken.isNotEmpty) {
      throw InvalidUri(url);
    }
  }

  var destination = uri.host;

  if (destination.isEmpty) {
    throw InvalidUri(url);
  }

  // uri.host is case insensitive, so we need to use the original string.
  final index = url.toLowerCase().indexOf(destination);
  if (index == -1) {
    e('invalid destination: $destination');
    throw InvalidUri(url);
  }
  destination = url.substring(index, index + destination.length);

  if (!destination.equalsIgnoreCase(uri.host)) {
    e('invalid destination: $destination $url');
    throw InvalidUri(url);
  }

  final addressFeeResponse = await getAddressFee(assetId, destination);
  if (addressFeeResponse.destination.toLowerCase() !=
      destination.toLowerCase()) {
    throw InvalidUri(url);
  }

  var amount = uri.queryParameters['amount'];
  amount ??= uri.queryParameters['tx_amount'];
  if (amount == null || amount.isEmpty || amount.amountWithE) {
    e('amount is empty or invalid. $amount');
    throw InvalidUri(url);
  }

  amount = amount.asDecimal.toString();
  final amountBD = Decimal.tryParse(amount);
  if (amountBD == null) {
    throw InvalidUri(url);
  }
  if (amount != amountBD.toString()) {
    throw InvalidUri(url);
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
