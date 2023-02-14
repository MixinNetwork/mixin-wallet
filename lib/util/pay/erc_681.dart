import 'package:tuple/tuple.dart';

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

  factory ERC681.fromCommonEthereumURIData(CommonEthereumURIData data) =>
      ERC681()
        ..scheme = data.scheme
        ..prefix = data.prefix
        ..chainId = data.chainId
        ..function = data.function
        ..address = data.address
        ..valid = data.valid
        ..gasLimit = data.query
            .firstWhereOrNull((element) => element.item1 == 'gas')
            ?.item2
            .toBigInteger()
        ..gasPrice = data.query
            .firstWhereOrNull((element) => element.item1 == 'gasPrice')
            ?.item2
            .toBigInteger()
        ..value = data.query
            .firstWhereOrNull((element) => element.item1 == 'value')
            ?.item2
            .split('-')
            .first
            .toBigInteger()
        ..functionParams = data.query
            .where(
                (element) => element.item1 != 'gas' && element.item1 != 'value')
            .toList();

  bool valid = true;
  String? prefix;
  String? address;
  String? scheme;
  BigInt? chainId;
  BigInt? value;
  BigInt? gasPrice;
  BigInt? gasLimit;
  String? function;
  List<Tuple2<String, String>> functionParams = [];
}

extension _StringExt on String {
  BigInt toBigInteger() => BigInt.parse(this);
}
