import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
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

@JsonSerializable()
class AddressFeeResponse {
  AddressFeeResponse({
    required this.destination,
    required this.assetId,
    required this.fee,
    this.tag,
  });

  final String destination;
  @JsonKey(name: 'fee_asset_id')
  final String assetId;
  final String fee;
  final String? tag;
}

class AssetPrecision {
  AssetPrecision({
    required this.assetId,
    required this.chainId,
    required this.precision,
  });

  @JsonKey(name: 'asset_id')
  final String assetId;
  @JsonKey(name: 'chain_id')
  final String chainId;
  final int precision;
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

Future<ExternalTransfer?> parseExternalTransferUri(
  String url, {
  required Future<AddressFeeResponse?> Function(String, String) getAddressFee,
  required Future<String?> Function(String) findAssetIdByAssetKey,
  required Future<AssetPrecision?> Function(String) getAssetPrecisionById,
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
