import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';

import '../constants.dart';
import '../extension/extension.dart';
import '../logger.dart';
import 'amount.dart';
import 'erc_681.dart';
import 'external_transfer_uri_parser.dart';

class EthereumURI {
  EthereumURI(this.uri);

  final String uri;

  ERC681 toERC681() => ERC681.fromEthereumURI(this);
}

const _ethereumChainIdMap = {
  1: ethereum,
};

extension StringExt on String {
  bool get amountWithE => contains('e');
}

Future<ExternalTransfer?> parseEthereum(
  String url, {
  required Future<AddressFeeResponse?> Function(String, String) getAddressFee,
  required Future<String?> Function(String) findAssetIdByAssetKey,
  required Future<AssetPrecision?> Function(String) getAssetPrecisionById,
}) async {
  final erc681 = EthereumURI(url).toERC681();
  if (!erc681.valid) {
    e('invalid erc681: $url');
    return null;
  }

  final chainId = erc681.chainId?.toInt() ?? 1;
  var assetId = _ethereumChainIdMap[chainId];
  if (assetId == null || assetId.isEmpty) {
    e('invalid chainId: $chainId');
    return null;
  }

  final value = erc681.value;
  String? address;

  final amountTemp = erc681.amount;
  Rational? uint256Temp;
  Rational? valueTemp;

  if (value != null) {
    address = erc681.address;
    valueTemp = EtherAmount.inWei(value).getInEther;
  }

  if (erc681.function != 'transfer') {
    address = erc681.address;
  } else {
    final assetKey = erc681.address?.toLowerCase();
    if (assetKey == null) {
      e('asset not found: $assetKey');
      return null;
    }
    assetId = await findAssetIdByAssetKey(assetKey);
    if (assetId == null || assetId.isEmpty) {
      e('asset not found: $assetKey');
      return null;
    }
    for (final pair in erc681.functionParams) {
      if (pair.key == 'address') {
        address = pair.value;
      } else if (pair.key == 'uint256') {
        uint256Temp = Rational.tryParse(pair.value);
        if (uint256Temp == null) {
          e('invalid uint256: ${pair.value}');
          return null;
        }
        final assetPrecision = await getAssetPrecisionById(assetId);
        if (assetPrecision == null) {
          return null;
        }
        uint256Temp =
            uint256Temp / (Rational.fromInt(10).pow(assetPrecision.precision));
      }
    }
  }

  final destination = address;
  if (destination == null) {
    e('destination not found: $url');
    return null;
  }

  final amount = valueTemp ?? amountTemp ?? uint256Temp;
  if (amount == null) {
    e('amount not found: $url');
    return null;
  }

  // check amount is equal to valueTemp, amountTemp, uint256Temp
  if (valueTemp != null && valueTemp != amount) {
    e('valueTemp != amount: $url');
    return null;
  }
  if (amountTemp != null && amountTemp != amount) {
    e('amountTemp != amount: $url');
    return null;
  }
  if (uint256Temp != null && uint256Temp != amount) {
    e('uint256Temp != amount: $url');
    return null;
  }

  final am = amount.toDecimal(scaleOnInfinitePrecision: 10).toString();
  final addressFeeResponse = await getAddressFee(assetId, destination);
  if (addressFeeResponse == null) {
    return null;
  }
  if (!addressFeeResponse.destination.equalsIgnoreCase(address)) {
    return null;
  }
  return ExternalTransfer(
    destination: addressFeeResponse.destination,
    amount: am,
    assetId: assetId,
    fee: Rational.tryParse(addressFeeResponse.fee),
  );
}
