// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  static String m0(value) => "已隐藏 ${value}";

  static String m1(value) => "已显示 ${value}";

  static String m4(count) => "${count} items";

  static String m5(value) => "充值到账至少需要 ${value} 个区块确认";

  static String m6(value) => "地址和 Memo(备注)同时使用才能充值 ${value} 到你的账户。";

  static String m7(value) => "首次充值至少 ${value}";

  static String m8(value) => "该充值地址仅支持 ${value}.";

  static String m9(value, value2) => "${value}/${value2} 区块确认数";

  static String m10(value) => "暂不支持滑点大于 ${value} 的闪兑";

  static String m11(value) => "价值 ${value}";

  static String m12(value) => "当时价值 ${value}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "addAddress": MessageLookupByLibrary.simpleMessage("添加地址"),
        "addAddressLabelHint":
            MessageLookupByLibrary.simpleMessage("地址名称，例如 OceanOne"),
        "addAddressMemo":
            MessageLookupByLibrary.simpleMessage("地址备注、数字 ID 或备注。如果没有，"),
        "addAddressMemoAction":
            MessageLookupByLibrary.simpleMessage("点击不使用备注（Memo）"),
        "addAddressNoMemo":
            MessageLookupByLibrary.simpleMessage("如果你需要填写地址备注、数字 ID 或备注，"),
        "addAddressNoMemoAction":
            MessageLookupByLibrary.simpleMessage("点击添加备注（Memo）"),
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
        "authorize": MessageLookupByLibrary.simpleMessage("使用 Mixin 登录"),
        "balance": MessageLookupByLibrary.simpleMessage("余额"),
        "buy": MessageLookupByLibrary.simpleMessage("购买"),
        "buyDisclaimer": MessageLookupByLibrary.simpleMessage(
            "购买服务由 https://sendwyre.com 提供"),
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "chain": MessageLookupByLibrary.simpleMessage("所属公链"),
        "coins": MessageLookupByLibrary.simpleMessage("代币"),
        "collectionItemCount": m4,
        "comingSoon": MessageLookupByLibrary.simpleMessage("即将推出"),
        "completed": MessageLookupByLibrary.simpleMessage("已完成"),
        "contact": MessageLookupByLibrary.simpleMessage("联系人"),
        "contactReadFailed": MessageLookupByLibrary.simpleMessage("读取联系人列表失败"),
        "contactSearchHint":
            MessageLookupByLibrary.simpleMessage("名称, Mixin ID"),
        "contract": MessageLookupByLibrary.simpleMessage("资产标识"),
        "copyToClipboard": MessageLookupByLibrary.simpleMessage("已复制到剪切板"),
        "delete": MessageLookupByLibrary.simpleMessage("删除"),
        "deposit": MessageLookupByLibrary.simpleMessage("充值"),
        "depositConfirmation": m5,
        "depositMemoNotice": MessageLookupByLibrary.simpleMessage(
            "提币时务必填写 Memo(备注)，否则您会丢失您的数字币"),
        "depositNotice": m6,
        "depositReserve": m7,
        "depositTip": m8,
        "depositTipBtc": MessageLookupByLibrary.simpleMessage("该充值地址仅支持 BTC。"),
        "depositTipEos":
            MessageLookupByLibrary.simpleMessage("该充值地址支持所有基于 EOS 发行的代币。"),
        "depositTipEth": MessageLookupByLibrary.simpleMessage(
            "该充值地址支持所有符合 ERC-20 的代币，例如 XIN 等。"),
        "depositTipNotSupportContract":
            MessageLookupByLibrary.simpleMessage("不支持合约充值。"),
        "depositTipTron": MessageLookupByLibrary.simpleMessage(
            "该充值地址支持 TRX 和所有符合 TRC-10 TRC-20 标准的代币。"),
        "depositing": MessageLookupByLibrary.simpleMessage("充值中"),
        "dontShowAgain": MessageLookupByLibrary.simpleMessage("不再提醒"),
        "emptyAmount": MessageLookupByLibrary.simpleMessage("金额不能为空"),
        "emptyLabelOrAddress":
            MessageLookupByLibrary.simpleMessage("地址和标题不能为空"),
        "eosContractAddress": MessageLookupByLibrary.simpleMessage("EOS 合约地址"),
        "errorNoCamera": MessageLookupByLibrary.simpleMessage("没有相机"),
        "fee": MessageLookupByLibrary.simpleMessage("手续费"),
        "filterAll": MessageLookupByLibrary.simpleMessage("全部"),
        "filterApply": MessageLookupByLibrary.simpleMessage("应用"),
        "filterBy": MessageLookupByLibrary.simpleMessage("筛选"),
        "filterTitle": MessageLookupByLibrary.simpleMessage("筛选"),
        "from": MessageLookupByLibrary.simpleMessage("来自"),
        "goPay": MessageLookupByLibrary.simpleMessage("去支付"),
        "gotIt": MessageLookupByLibrary.simpleMessage("知道了"),
        "hiddenAssets": MessageLookupByLibrary.simpleMessage("隐藏的资产"),
        "hide": MessageLookupByLibrary.simpleMessage("隐藏"),
        "hideSmallAssets": MessageLookupByLibrary.simpleMessage("隐藏小额资产"),
        "incomplete": MessageLookupByLibrary.simpleMessage("未完成"),
        "memo": MessageLookupByLibrary.simpleMessage("Memo(备注)"),
        "memoHint": MessageLookupByLibrary.simpleMessage("备注（Memo）"),
        "minerFee": MessageLookupByLibrary.simpleMessage("挖矿手续费"),
        "minimumReserve": MessageLookupByLibrary.simpleMessage("最少保留数量："),
        "minimumWithdrawal": MessageLookupByLibrary.simpleMessage("最小提现数量："),
        "mixinWallet": MessageLookupByLibrary.simpleMessage("Mixin 钱包"),
        "networkFee": MessageLookupByLibrary.simpleMessage("网络手续费："),
        "networkFeeTip": MessageLookupByLibrary.simpleMessage(
            "由第三方服务商收取。直接支付给以太坊矿工以保证以太坊上交易完成。网络费根据即时市场状况变动。"),
        "networkType": MessageLookupByLibrary.simpleMessage("网络类型"),
        "nfts": MessageLookupByLibrary.simpleMessage("NFTs"),
        "noAsset": MessageLookupByLibrary.simpleMessage("暂无资产"),
        "noCollectiblesFound":
            MessageLookupByLibrary.simpleMessage("No collectibles found"),
        "noCollectionFound":
            MessageLookupByLibrary.simpleMessage("No collection found"),
        "noResult": MessageLookupByLibrary.simpleMessage("无结果"),
        "noTransaction": MessageLookupByLibrary.simpleMessage("暂无转账记录"),
        "noWithdrawalDestinationSelected":
            MessageLookupByLibrary.simpleMessage("需要选择一个联系人或地址"),
        "none": MessageLookupByLibrary.simpleMessage("暂无价格"),
        "notMeetMinimumAmount":
            MessageLookupByLibrary.simpleMessage("未能达到最低数额"),
        "notice": MessageLookupByLibrary.simpleMessage("注意"),
        "ok": MessageLookupByLibrary.simpleMessage("好的"),
        "other": MessageLookupByLibrary.simpleMessage("其他"),
        "paid": MessageLookupByLibrary.simpleMessage("已支付"),
        "paidInMixin":
            MessageLookupByLibrary.simpleMessage("您是否已经在 Mixin 中支付？"),
        "paidInMixinWarning":
            MessageLookupByLibrary.simpleMessage("如果您已经支付成功，请耐心等待，无需再次支付"),
        "pay": MessageLookupByLibrary.simpleMessage("支付"),
        "pendingConfirmations": m9,
        "raw": MessageLookupByLibrary.simpleMessage("其他"),
        "reauthorize": MessageLookupByLibrary.simpleMessage("重新授权"),
        "rebate": MessageLookupByLibrary.simpleMessage("退款"),
        "receive": MessageLookupByLibrary.simpleMessage("转入"),
        "received": MessageLookupByLibrary.simpleMessage("获得"),
        "recentSearches": MessageLookupByLibrary.simpleMessage("最近搜索"),
        "refund": MessageLookupByLibrary.simpleMessage("退回"),
        "removeAuthorize": MessageLookupByLibrary.simpleMessage("取消授权"),
        "save": MessageLookupByLibrary.simpleMessage("保存"),
        "search": MessageLookupByLibrary.simpleMessage("搜索"),
        "selectContactOrAddress":
            MessageLookupByLibrary.simpleMessage("选择地址或联系人"),
        "send": MessageLookupByLibrary.simpleMessage("转出"),
        "sendTo": MessageLookupByLibrary.simpleMessage("转出至"),
        "sendToContact": MessageLookupByLibrary.simpleMessage("转账至联系人"),
        "settings": MessageLookupByLibrary.simpleMessage("设置"),
        "show": MessageLookupByLibrary.simpleMessage("显示"),
        "slippage": MessageLookupByLibrary.simpleMessage("滑点"),
        "slippageOver": m10,
        "sortBy": MessageLookupByLibrary.simpleMessage("排序"),
        "swap": MessageLookupByLibrary.simpleMessage("闪兑"),
        "swapDisclaimer":
            MessageLookupByLibrary.simpleMessage("服务由 MixSwap 提供"),
        "swapType": MessageLookupByLibrary.simpleMessage("兑换币种"),
        "symbol": MessageLookupByLibrary.simpleMessage("符号"),
        "tagHint": MessageLookupByLibrary.simpleMessage("标签（Tag）"),
        "time": MessageLookupByLibrary.simpleMessage("时间"),
        "to": MessageLookupByLibrary.simpleMessage("至"),
        "totalBalance": MessageLookupByLibrary.simpleMessage("总余额"),
        "transaction": MessageLookupByLibrary.simpleMessage("转账记录"),
        "transactionChecking": MessageLookupByLibrary.simpleMessage("检查中"),
        "transactionDone": MessageLookupByLibrary.simpleMessage("完成"),
        "transactionFee": MessageLookupByLibrary.simpleMessage("交易费："),
        "transactionFeeTip": MessageLookupByLibrary.simpleMessage(
            "由第三方服务商收取。美国用户按交易金额的2.9% + 30c收取，最低收费为\$5；国际用户按交易金额的3.9% + 30c收取，最低收费为\$5。"),
        "transactionHash": MessageLookupByLibrary.simpleMessage("交易哈希"),
        "transactionPhase": MessageLookupByLibrary.simpleMessage("交易进度"),
        "transactionTrading": MessageLookupByLibrary.simpleMessage("交易中"),
        "transactions": MessageLookupByLibrary.simpleMessage("转账记录"),
        "transactionsAssetKeyWarning":
            MessageLookupByLibrary.simpleMessage("资产标识不是充值地址！"),
        "transactionsId": MessageLookupByLibrary.simpleMessage("交易编号"),
        "transactionsStatus": MessageLookupByLibrary.simpleMessage("交易状态"),
        "transactionsType": MessageLookupByLibrary.simpleMessage("交易类型"),
        "transfer": MessageLookupByLibrary.simpleMessage("转账"),
        "transferDetail": MessageLookupByLibrary.simpleMessage("交易详情"),
        "undo": MessageLookupByLibrary.simpleMessage("撤销"),
        "unpaid": MessageLookupByLibrary.simpleMessage("未支付"),
        "waitingActionDone": MessageLookupByLibrary.simpleMessage("等待操作完成..."),
        "walletTransactionCurrentValue": m11,
        "walletTransactionThatTimeNoValue":
            MessageLookupByLibrary.simpleMessage("当时价值 暂无"),
        "walletTransactionThatTimeValue": m12,
        "wireServiceTip": MessageLookupByLibrary.simpleMessage(
            "本服务由 Wyre 提供。我们仅作为渠道，不额外收取手续费。"),
        "withdrawal": MessageLookupByLibrary.simpleMessage("提现"),
        "withdrawalMemoHint": MessageLookupByLibrary.simpleMessage("备注 (可选)"),
        "wyreServiceStatement": MessageLookupByLibrary.simpleMessage("服务声明")
      };
}
