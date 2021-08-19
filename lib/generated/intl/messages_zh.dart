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

  static String m0(value) => "已隐藏 ${value}";

  static String m1(value) => "已显示 ${value}";

  static String m6(value) => "充值到账至少需要 ${value} 个区块确认";

  static String m7(value) => "注意：地址和 Memo(标签)同时使用才能充值 ${value} 到 Mixin。";

  static String m8(value) => "该充值地址仅支持 ${value}.";

  static String m9(value, value2) => "${value}/${value2} 区块确认数";

  static String m10(value) => "价值 ${value}";

  static String m11(value) => "当时价值 ${value}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "addAddress": MessageLookupByLibrary.simpleMessage("添加地址"),
        "addAddressLabelHint":
            MessageLookupByLibrary.simpleMessage("地址名称，例如 OceanOne"),
        "addAddressMemo":
            MessageLookupByLibrary.simpleMessage("地址标签、数字 ID 或备注。如果没有，"),
        "addAddressMemoAction":
            MessageLookupByLibrary.simpleMessage("点击不使用标签（Memo）"),
        "addAddressNoMemo":
            MessageLookupByLibrary.simpleMessage("如果你需要填写地址标签、数字 ID 或备注，"),
        "addAddressNoMemoAction":
            MessageLookupByLibrary.simpleMessage("点击添加标签（Memo）"),
        "addAddressNoTagAction":
            MessageLookupByLibrary.simpleMessage("点击添加标签（Tag）"),
        "addAddressNotSupportTip":
            MessageLookupByLibrary.simpleMessage("Mixin 不支持提现到"),
        "addAddressTagAction":
            MessageLookupByLibrary.simpleMessage("点击不使用标签（Tag）"),
        "address": MessageLookupByLibrary.simpleMessage("地址"),
        "addressSearchHint": MessageLookupByLibrary.simpleMessage("标题，地址"),
        "allTransactions": MessageLookupByLibrary.simpleMessage("所有交易"),
        "alreadyHidden": m0,
        "alreadyShown": m1,
        "amount": MessageLookupByLibrary.simpleMessage("金额"),
        "assetTrending": MessageLookupByLibrary.simpleMessage("热门资产"),
        "assetType": MessageLookupByLibrary.simpleMessage("资产类型"),
        "assets": MessageLookupByLibrary.simpleMessage("资产"),
        "authHint": MessageLookupByLibrary.simpleMessage("只读授权无法动用你的资产，请放心使用"),
        "authSlogan": MessageLookupByLibrary.simpleMessage(
            "Mixin 钱包是一款用户友好、安全且功能强大的多链数字钱包。"),
        "authTips":
            MessageLookupByLibrary.simpleMessage("你知道吗？Mixin 是一个开源的加密钱包"),
        "authorize": MessageLookupByLibrary.simpleMessage("授权使用"),
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "chain": MessageLookupByLibrary.simpleMessage("所属公链"),
        "contact": MessageLookupByLibrary.simpleMessage("联系人"),
        "contactReadFailed": MessageLookupByLibrary.simpleMessage("读取联系人列表失败"),
        "contactSearchHint":
            MessageLookupByLibrary.simpleMessage("名称, Mixin ID"),
        "contract": MessageLookupByLibrary.simpleMessage("资产标识"),
        "copyToClipboard": MessageLookupByLibrary.simpleMessage("已复制到剪切板"),
        "delete": MessageLookupByLibrary.simpleMessage("删除"),
        "deposit": MessageLookupByLibrary.simpleMessage("充值"),
        "depositConfirmation": m6,
        "depositNotice": m7,
        "depositTip": m8,
        "depositTipBtc":
            MessageLookupByLibrary.simpleMessage("该充值地址仅支持 BTC 和 Omni USDT。"),
        "depositTipEos": MessageLookupByLibrary.simpleMessage(
            "该充值地址支持所有基于 EOS 发行的代币，例如 EOS、IQ、BLACK、OCT、KARMA 等。"),
        "depositTipEth": MessageLookupByLibrary.simpleMessage(
            "该充值地址支持所有符合 ERC-20 标准的代币，例如 ETH、XIN、HT、LOOM、LEO、PRS 等。"),
        "depositTipTron": MessageLookupByLibrary.simpleMessage(
            "该充值地址支持 TRX 和所有符合 TRC-10 TRC-20 标准的代币，例如 TRX、BTT、USDT-TRON 等。"),
        "depositing": MessageLookupByLibrary.simpleMessage("充值中"),
        "emptyAmount": MessageLookupByLibrary.simpleMessage("金额不能为空"),
        "emptyLabelOrAddress":
            MessageLookupByLibrary.simpleMessage("地址和标题不能为空"),
        "eosContractAddress": MessageLookupByLibrary.simpleMessage("EOS 合约地址"),
        "fee": MessageLookupByLibrary.simpleMessage("手续费"),
        "filterAll": MessageLookupByLibrary.simpleMessage("全部"),
        "filterApply": MessageLookupByLibrary.simpleMessage("应用"),
        "filterBy": MessageLookupByLibrary.simpleMessage("筛选"),
        "filterTitle": MessageLookupByLibrary.simpleMessage("筛选"),
        "from": MessageLookupByLibrary.simpleMessage("来自"),
        "hiddenAssets": MessageLookupByLibrary.simpleMessage("隐藏的资产"),
        "hide": MessageLookupByLibrary.simpleMessage("隐藏"),
        "hideSmallAssets": MessageLookupByLibrary.simpleMessage("隐藏小额资产"),
        "memo": MessageLookupByLibrary.simpleMessage("备注"),
        "memoHint": MessageLookupByLibrary.simpleMessage("标签（Memo）"),
        "minerFee": MessageLookupByLibrary.simpleMessage("挖矿手续费"),
        "minimumReserve": MessageLookupByLibrary.simpleMessage("最少保留数量："),
        "minimumWithdrawal": MessageLookupByLibrary.simpleMessage("最小提现数量："),
        "mixinWallet": MessageLookupByLibrary.simpleMessage("Mixin 钱包"),
        "networkFee": MessageLookupByLibrary.simpleMessage("网络手续费："),
        "noAddressSelected": MessageLookupByLibrary.simpleMessage("需要选择一个地址"),
        "noContactSelected": MessageLookupByLibrary.simpleMessage("需要选择一个联系人"),
        "noTransaction": MessageLookupByLibrary.simpleMessage("暂无转账记录"),
        "pendingConfirmations": m9,
        "raw": MessageLookupByLibrary.simpleMessage("其他"),
        "reauthorize": MessageLookupByLibrary.simpleMessage("重新授权"),
        "rebate": MessageLookupByLibrary.simpleMessage("退款"),
        "receive": MessageLookupByLibrary.simpleMessage("转入"),
        "recentSearches": MessageLookupByLibrary.simpleMessage("最近搜索"),
        "save": MessageLookupByLibrary.simpleMessage("保存"),
        "search": MessageLookupByLibrary.simpleMessage("搜索"),
        "selectFromAddressBook": MessageLookupByLibrary.simpleMessage("从地址簿选择"),
        "selectFromContacts": MessageLookupByLibrary.simpleMessage("从通讯录选择"),
        "send": MessageLookupByLibrary.simpleMessage("转出"),
        "sendTo": MessageLookupByLibrary.simpleMessage("转出至"),
        "sendToAddress": MessageLookupByLibrary.simpleMessage("转出到地址"),
        "sendToAddressDescription":
            MessageLookupByLibrary.simpleMessage("提现到交易所或钱包"),
        "sendToContact": MessageLookupByLibrary.simpleMessage("转账至联系人"),
        "sendToContactDescription":
            MessageLookupByLibrary.simpleMessage("转账至 Mixin 联系人"),
        "show": MessageLookupByLibrary.simpleMessage("显示"),
        "sortBy": MessageLookupByLibrary.simpleMessage("排序"),
        "symbol": MessageLookupByLibrary.simpleMessage("符号"),
        "tagHint": MessageLookupByLibrary.simpleMessage("标签（Tag）"),
        "time": MessageLookupByLibrary.simpleMessage("时间"),
        "to": MessageLookupByLibrary.simpleMessage("至"),
        "totalBalance": MessageLookupByLibrary.simpleMessage("总余额"),
        "transactionHash": MessageLookupByLibrary.simpleMessage("交易哈希"),
        "transactions": MessageLookupByLibrary.simpleMessage("转账记录"),
        "transactionsAssetKeyWarning":
            MessageLookupByLibrary.simpleMessage("资产标识不是充值地址！"),
        "transactionsId": MessageLookupByLibrary.simpleMessage("交易编号"),
        "transactionsStatus": MessageLookupByLibrary.simpleMessage("交易状态"),
        "transactionsType": MessageLookupByLibrary.simpleMessage("交易类型"),
        "transfer": MessageLookupByLibrary.simpleMessage("转账"),
        "undo": MessageLookupByLibrary.simpleMessage("撤销"),
        "waitingActionDone": MessageLookupByLibrary.simpleMessage("等待操作完成..."),
        "walletTransactionCurrentValue": m10,
        "walletTransactionThatTimeNoValue":
            MessageLookupByLibrary.simpleMessage("当时价值 暂无"),
        "walletTransactionThatTimeValue": m11,
        "withdrawal": MessageLookupByLibrary.simpleMessage("提现"),
        "withdrawalMemoHint": MessageLookupByLibrary.simpleMessage("备注 (可选)")
      };
}
