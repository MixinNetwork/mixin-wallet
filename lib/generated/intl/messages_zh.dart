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

  static String m8(value, value2) => "${value}/${value2} 区块确认数";

  static String m9(value) => "价值 \$${value}";

  static String m10(value) => "，当时价值 \$${value}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "addAddress": MessageLookupByLibrary.simpleMessage("添加地址"),
        "addressSearchHint": MessageLookupByLibrary.simpleMessage("标题，地址"),
        "allTransactions": MessageLookupByLibrary.simpleMessage("所有交易"),
        "amount": MessageLookupByLibrary.simpleMessage("金额"),
        "assetType": MessageLookupByLibrary.simpleMessage("资产类型"),
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "chain": MessageLookupByLibrary.simpleMessage("所属公链"),
        "contract": MessageLookupByLibrary.simpleMessage("资产标识"),
        "delete": MessageLookupByLibrary.simpleMessage("删除"),
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
        "depositing": MessageLookupByLibrary.simpleMessage("充值中"),
        "fee": MessageLookupByLibrary.simpleMessage("手续费"),
        "filterAll": MessageLookupByLibrary.simpleMessage("全部"),
        "filterApply": MessageLookupByLibrary.simpleMessage("应用"),
        "filterBy": MessageLookupByLibrary.simpleMessage("筛选"),
        "filterTitle": MessageLookupByLibrary.simpleMessage("筛选"),
        "from": MessageLookupByLibrary.simpleMessage("来自"),
        "memo": MessageLookupByLibrary.simpleMessage("备注"),
        "noTransaction": MessageLookupByLibrary.simpleMessage("暂无转账记录"),
        "pendingConfirmations": m8,
        "raw": MessageLookupByLibrary.simpleMessage("其他"),
        "rebate": MessageLookupByLibrary.simpleMessage("退款"),
        "search": MessageLookupByLibrary.simpleMessage("搜索"),
        "sortBy": MessageLookupByLibrary.simpleMessage("排序"),
        "symbol": MessageLookupByLibrary.simpleMessage("符号"),
        "time": MessageLookupByLibrary.simpleMessage("时间"),
        "to": MessageLookupByLibrary.simpleMessage("至"),
        "totalBalance": MessageLookupByLibrary.simpleMessage("总余额"),
        "transactionsAssetKeyWarning":
            MessageLookupByLibrary.simpleMessage("资产标识不是充值地址！"),
        "transactionsId": MessageLookupByLibrary.simpleMessage("交易编号"),
        "transactionsStatus": MessageLookupByLibrary.simpleMessage("交易状态"),
        "transactionsType": MessageLookupByLibrary.simpleMessage("交易类型"),
        "transfer": MessageLookupByLibrary.simpleMessage("转账"),
        "walletTransactionCurrentValue": m9,
        "walletTransactionThatTimeNoValue":
            MessageLookupByLibrary.simpleMessage("，当时价值 暂无"),
        "walletTransactionThatTimeValue": m10,
        "withdrawal": MessageLookupByLibrary.simpleMessage("提现")
      };
}
