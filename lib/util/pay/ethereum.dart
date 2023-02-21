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

Future<ExternalTransfer> parseEthereum(
  String url, {
  required GetAddressFeeCallback getAddressFee,
  required FindAssetIdByAssetKeyCallback findAssetIdByAssetKey,
  required GetAssetPrecisionByIdCallback getAssetPrecisionById,
}) async {
  final erc681 = EthereumURI(url).toERC681();
  if (!erc681.valid) {
    e('invalid erc681: $url');
    throw InvalidUri(url);
  }

  final chainId = erc681.chainId?.toInt() ?? 1;
  var assetId = _ethereumChainIdMap[chainId];
  if (assetId == null || assetId.isEmpty) {
    e('invalid chainId: $chainId');
    throw InvalidChainId(chainId);
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
      throw NoAssetFound(assetKey);
    }
    assetId = await findAssetIdByAssetKey(assetKey);
    if (assetId == null || assetId.isEmpty) {
      throw NoAssetFound(assetKey);
    }
    for (final pair in erc681.functionParams) {
      if (pair.key == 'address') {
        address = pair.value;
      } else if (pair.key == 'uint256') {
        uint256Temp = Rational.tryParse(pair.value);
        if (uint256Temp == null) {
          e('invalid uint256: ${pair.value}');
          throw InvalidUri(url);
        }
        final assetPrecision = await getAssetPrecisionById(assetId);
        uint256Temp =
            uint256Temp / (Rational.fromInt(10).pow(assetPrecision.precision));
      }
    }
  }

  final destination = address;
  if (destination == null) {
    e('destination not found: $url');
    throw InvalidUri(url);
  }

  final amount = valueTemp ?? amountTemp ?? uint256Temp;
  if (amount == null) {
    e('amount not found: $url');
    throw InvalidUri(url);
  }

  // check amount is equal to valueTemp, amountTemp, uint256Temp
  if (valueTemp != null && valueTemp != amount) {
    e('valueTemp != amount: $url');
    throw InvalidUri(url);
  }
  if (amountTemp != null && amountTemp != amount) {
    e('amountTemp != amount: $url');
    throw InvalidUri(url);
  }
  if (uint256Temp != null && uint256Temp != amount) {
    e('uint256Temp != amount: $url');
    throw InvalidUri(url);
  }

  final am = amount.toDecimal(scaleOnInfinitePrecision: 10).toString();
  final addressFeeResponse = await getAddressFee(assetId, destination);
  if (!addressFeeResponse.destination.equalsIgnoreCase(address)) {
    throw InvalidUri(url);
  }
  return ExternalTransfer(
    destination: addressFeeResponse.destination,
    amount: am,
    assetId: assetId,
    fee: Rational.tryParse(addressFeeResponse.fee),
  );
}
