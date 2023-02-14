import 'package:flutter/widgets.dart';
import 'package:tuple/tuple.dart';

import 'erc_831.dart';

enum ParseState {
  address,
  chain,
  function,
  query,
}

class CommonEthereumURIData {
  CommonEthereumURIData();

  factory CommonEthereumURIData.fromERC831(ERC831 erc831) {
    final data = CommonEthereumURIData();
    var currentSegment = '';
    var currentState = ParseState.address;

    void stateTransition(ParseState newState) {
      switch (currentState) {
        case ParseState.chain:
          data.chainId = BigInt.tryParse(currentSegment);
          break;
        case ParseState.function:
          data.function = currentSegment;
          break;
        case ParseState.address:
          data.address = currentSegment;
          break;
        case ParseState.query:
          final queryString = currentSegment;
          data.query = queryString
              .split('&')
              .where((element) => element.isNotEmpty)
              .map((e) {
            final index = e.indexOf('=');
            if (index == -1) {
              return Tuple2(e, 'true');
            } else {
              return Tuple2(e.substring(0, index), e.substring(index + 1));
            }
          }).toList();
          break;
      }
      currentState = newState;
      currentSegment = '';
    }

    erc831.payload?.characters.forEach((char) {
      if (char == '/' &&
          (currentState == ParseState.address ||
              currentState == ParseState.chain)) {
        stateTransition(ParseState.function);
      } else if (char == '?' &&
          (currentState == ParseState.address ||
              currentState == ParseState.function ||
              currentState == ParseState.chain)) {
        stateTransition(ParseState.query);
      } else if (char == '@') {
        stateTransition(ParseState.chain);
      } else {
        currentSegment += char;
      }
    });

    if (currentSegment.isNotEmpty) {
      stateTransition(ParseState.query);
    }

    data.valid = data.valid && erc831.scheme == 'ethereum';
    return data;
  }

  bool valid = true;
  String? scheme;
  String? prefix;
  BigInt? chainId;
  String? address;
  String? function;
  List<Tuple2<String, String>> query = [];
}
