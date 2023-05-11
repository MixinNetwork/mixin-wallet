import 'package:rational/rational.dart';

import '../extension/extension.dart';
import 'common_uri.dart';
import 'erc_831.dart';
import 'ethereum.dart';

final _scientificNumberRegEx = RegExp(r'^\d+(\.\d+)?(e\d+)?$');

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

    final erc681 = ERC681()
      ..scheme = data.scheme
      ..prefix = data.prefix
      ..chainId = data.chainId
      ..function = data.function
      ..address = data.address
      ..valid = data.valid;

    BigInt? toBigInteger(String? value) {
      if (value == null) {
        return null;
      }
      if (!_scientificNumberRegEx.hasMatch(value)) {
        erc681.valid = false;
        return null;
      }
      if (value.contains('e')) {
        final parts = value.split('e');
        final base = parts[0].asRational;
        final exponent = BigInt.tryParse(parts[1]) ?? BigInt.one;
        return (base * (BigInt.from(10).pow(exponent.toInt()).toRational()))
            .toBigInt();
      }
      final result = BigInt.tryParse(value);
      if (result == null) {
        erc681.valid = false;
      }
      return result;
    }

    erc681
      ..gasLimit = toBigInteger(query['gas'] ?? query['gasLimit'])
      ..gasPrice = toBigInteger(query['gasPrice'])
      ..value = toBigInteger(query['value']?.split('-').first)
      ..functionParams = data.query
          .where((element) => element.key != 'gas' && element.key != 'value')
          .toList()
      ..amount = query['amount']?.asRationalOrNull;

    return erc681;
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
