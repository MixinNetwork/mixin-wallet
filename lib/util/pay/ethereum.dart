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
  var assetId = _ethereumChainIdMap[chainId] ?? '';

  final value = erc681.value;
  String? address;
  Rational? amount;
  if (value == null) {
    var needCheckPrecision = false;
    if (erc681.function != 'transfer') return null;

    final assetKey = erc681.address?.toLowerCase() ?? '';
    assetId = await findAssetIdByAssetKey(assetKey) ?? '';
    if (assetId.isEmpty) {
      e('asset not found: $assetKey');
      return null;
    }

    var amountFound = false;
    var addressFound = false;
    for (final pair in erc681.functionParams) {
      if (amountFound && addressFound) {
        break;
      }

      if (pair.item1 == 'address') {
        address = pair.item2;
        addressFound = true;
      } else {
        if (pair.item1 == 'amount') {
          if (pair.item2.amountWithE) {
            return null;
          }
          amount = Rational.tryParse(pair.item2);
          amountFound = true;
          needCheckPrecision = false;
        } else if (!amountFound && pair.item1 == 'uint256') {
          amount = pair.item2.asRational;
          needCheckPrecision = true;
        }
      }
    }
    if (needCheckPrecision) {
      final assetPrecision = await getAssetPrecisionById(assetId);
      if (assetPrecision == null) {
        e('asset precision not found: $assetId');
        return null;
      }
      if (assetPrecision.assetId.isEmpty) return null;
      amount = (amount!) / (Decimal.fromInt(10).pow(assetPrecision.precision));
    }
  } else {
    address = erc681.address;
    amount = EtherAmount.inWei(value).getInEther;
  }
  if (address == null) {
    return null;
  }
  final am = amount?.toDecimal(scaleOnInfinitePrecision: 10).toString();
  if (am == null) {
    return null;
  }
  final addressFeeResponse = await getAddressFee(assetId, address);
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
    fee: Decimal.tryParse(addressFeeResponse.fee),
  );
}
