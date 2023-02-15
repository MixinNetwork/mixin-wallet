import 'package:rational/rational.dart';

import '../extension/extension.dart';
import 'common_uri.dart';
import 'erc_831.dart';
import 'ethereum.dart';

class ERC681 {
  ERC681();

  factory ERC681.fromEthereumURI(EthereumURI uri) {
    final erc831 = ERC831.fromEthereumURI(uri);
    return ERC681.fromCommonEthereumURIData(
      CommonEthereumURIData.fromERC831(erc831),
    );
  }

  factory ERC681.fromCommonEthereumURIData(CommonEthereumURIData data) {
    final query = Map.fromEntries(data.query);
    return ERC681()
      ..scheme = data.scheme
      ..prefix = data.prefix
      ..chainId = data.chainId
      ..function = data.function
      ..address = data.address
      ..valid = data.valid
      ..gasLimit = (query['gas'] ?? query['gasLimit'])?.toBigInteger()
      ..gasPrice = query['gasPrice']?.toBigInteger()
      ..value = query['value']?.split('-').first.toBigInteger()
      ..functionParams = data.query
          .where((element) => element.key != 'gas' && element.key != 'value')
          .toList()
      ..amount = query['amount']?.asRationalOrNull;
  }

  bool valid = true;
  String? prefix;
  String? address;
  String? scheme;
  BigInt? chainId;
  BigInt? value;
  BigInt? gasPrice;
  BigInt? gasLimit;
  String? function;
  List<MapEntry<String, String>> functionParams = [];

  // extra adapted field
  Rational? amount;
}

extension _StringExt on String {
  BigInt toBigInteger() => BigInt.parse(this);
}
