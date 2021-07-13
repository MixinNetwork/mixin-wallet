// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  static String m4(value) => "充值到账至少需要 ${value} 个区块确认。";

  static String m7(value) => "该充值地址仅支持 ${value}.";

  static String m8(value) => "价值 \$${value}";

  static String m9(value) => "，当时价值 \$${value}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "assetType": MessageLookupByLibrary.simpleMessage("资产类型"),
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "deposit": MessageLookupByLibrary.simpleMessage("充值"),
        "depositConfirmation": m4,
        "depositTip": m7,
        "depositTipBtc":
            MessageLookupByLibrary.simpleMessage("该充值地址仅支持 BTC 和 Omni USDT。"),
        "depositTipEos": MessageLookupByLibrary.simpleMessage(
            "该充值地址支持所有基于 EOS 发行的代币，例如 EOS、IQ、BLACK、OCT、KARMA 等。"),
        "depositTipEth": MessageLookupByLibrary.simpleMessage(
            "该充值地址支持所有符合 ERC-20 标准的代币，例如 ETH、XIN、HT、LOOM、LEO、PRS 等。"),
        "depositTipTron": MessageLookupByLibrary.simpleMessage(
            "该充值地址支持 TRX 和所有符合 TRC-10 TRC-20 标准的代币，例如 TRX、BTT、USDT-TRON 等。"),
        "from": MessageLookupByLibrary.simpleMessage("来自"),
        "memo": MessageLookupByLibrary.simpleMessage("备注"),
        "search": MessageLookupByLibrary.simpleMessage("搜索"),
        "time": MessageLookupByLibrary.simpleMessage("时间"),
        "to": MessageLookupByLibrary.simpleMessage("至"),
        "totalBalance": MessageLookupByLibrary.simpleMessage("总余额"),
        "transactionsId": MessageLookupByLibrary.simpleMessage("交易编号"),
        "transactionsStatus": MessageLookupByLibrary.simpleMessage("交易状态"),
        "transactionsType": MessageLookupByLibrary.simpleMessage("交易类型"),
        "walletTransactionCurrentValue": m8,
        "walletTransactionThatTimeNoValue":
            MessageLookupByLibrary.simpleMessage("，当时价值 暂无"),
        "walletTransactionThatTimeValue": m9
      };
}
