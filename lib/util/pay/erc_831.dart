import 'package:flutter/widgets.dart';

import 'ethereum.dart';

enum ParseState {
  schema,
  prefix,
  payload,
}

// http://eips.ethereum.org/EIPS/eip-831
class ERC831 {
  ERC831();

  factory ERC831.fromEthereumURI(EthereumURI uri) {
    final erc831 = ERC831();
    var currentSegment = '';
    var currentState = ParseState.schema;

    void stateTransition(ParseState newState) {
      switch (currentState) {
        case ParseState.schema:
          erc831.scheme = currentSegment;
          break;
        case ParseState.prefix:
          erc831.prefix = currentSegment;
          break;
        case ParseState.payload:
          erc831.payload = currentSegment;
          break;
      }
      currentState = newState;
      currentSegment = '';
    }

    uri.uri.characters.forEach((char) {
      if (char == ':' && currentState == ParseState.schema) {
        stateTransition(
            uri.uri.hasPrefix() ? ParseState.prefix : ParseState.payload);
      } else if (char == '-' && currentState == ParseState.prefix) {
        stateTransition(ParseState.payload);
      } else {
        currentSegment += char;
      }
    });

    if (currentSegment.isNotEmpty) {
      stateTransition(ParseState.payload);
    }

    return erc831;
  }

  String? scheme;
  String? prefix;
  String? payload;

  bool isERC681() =>
      scheme == 'ethereum' && (prefix == null || prefix == 'pay');
}

extension _StringExtension on String {
  bool hasPrefix() =>
      contains('-') && (!contains('0x') || indexOf('-') < indexOf('0x'));
}
