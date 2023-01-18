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

  static String m0(value) => "添加 ${value} 地址";

  static String m1(value) => "已隐藏 ${value}";

  static String m2(value) => "已显示 ${value}";

  static String m5(count) => "${count} items";

  static String m6(value) => "删除 ${value} 地址";

  static String m7(value) => "充值到账至少需要 ${value} 个区块确认";

  static String m8(value) => "地址和 Memo(备注)同时使用才能充值 ${value} 到你的账户。";

  static String m9(value) => "首次充值至少 ${value}";

  static String m10(value) => "该充值地址仅支持 ${value}.";

  static String m11(arg0) => "错误 20124：手续费不足。请确保钱包至少有 ${arg0} 当作手续费。";

  static String m12(arg0, arg1) =>
      "错误 30102：地址格式错误。请输入正确的 ${arg0} ${arg1} 的地址！";

  static String m13(arg0) => "错误 10006：请更新 Mixin（${arg0}） 至最新版。";

  static String m14(count, arg0) =>
      "${Intl.plural(count, one: '错误 20119：PIN 不正确。你还有 ${arg0} 次机会，使用完需等待 24 小时后再次尝试。', other: '错误 20119：PIN 不正确。你还有 ${arg0} 次机会，使用完需等待 24 小时后再次尝试。')}";

  static String m15(arg0) => "服务器出错，请稍后重试：${arg0}";

  static String m16(arg0) => "错误：${arg0}";

  static String m17(arg0) => "错误：${arg0}";

  static String m18(value, value2) => "${value}/${value2} 区块确认数";

  static String m19(value) => "请求付款金额: ${value}";

  static String m20(value) => "发送给 ${value}";

  static String m21(value) => "暂不支持滑点大于 ${value} 的闪兑";

  static String m22(value) => "价值 ${value}";

  static String m23(value) => "当时价值 ${value}";

  static String m24(value) => "提现到 ${value}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "accessDenied": MessageLookupByLibrary.simpleMessage("禁止访问"),
        "addAddress": MessageLookupByLibrary.simpleMessage("添加地址"),
        "addAddressByPinTip":
            MessageLookupByLibrary.simpleMessage("请输入 PIN 来完成添加"),
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
        "addEmergencyContact": MessageLookupByLibrary.simpleMessage("添加紧急联系人"),
        "addWithdrawalAddress": m0,
        "address": MessageLookupByLibrary.simpleMessage("地址"),
        "addressSearchHint": MessageLookupByLibrary.simpleMessage("标题，地址"),
        "allAssets": MessageLookupByLibrary.simpleMessage("所有币种"),
        "allTransactions": MessageLookupByLibrary.simpleMessage("所有交易"),
        "alreadyHidden": m1,
        "alreadyShown": m2,
        "amount": MessageLookupByLibrary.simpleMessage("金额"),
        "assetAddressGeneratingTip":
            MessageLookupByLibrary.simpleMessage("资产地址正在生成中，请稍后..."),
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
        "changeEmergencyContact":
            MessageLookupByLibrary.simpleMessage("修改紧急联系人"),
        "changePhoneNumber": MessageLookupByLibrary.simpleMessage("修改手机号码"),
        "changePin": MessageLookupByLibrary.simpleMessage("修改 PIN"),
        "changePinTip": MessageLookupByLibrary.simpleMessage("请输入 6 位 PIN 来验证"),
        "clearConditions": MessageLookupByLibrary.simpleMessage("清除条件"),
        "coins": MessageLookupByLibrary.simpleMessage("代币"),
        "collectiblesReadFailed":
            MessageLookupByLibrary.simpleMessage("读取 NFT 失败"),
        "collectionItemCount": m5,
        "comingSoon": MessageLookupByLibrary.simpleMessage("即将推出"),
        "completed": MessageLookupByLibrary.simpleMessage("已完成"),
        "confirm": MessageLookupByLibrary.simpleMessage("确认"),
        "confirmPin": MessageLookupByLibrary.simpleMessage("确认 PIN"),
        "contact": MessageLookupByLibrary.simpleMessage("联系人"),
        "contactReadFailed": MessageLookupByLibrary.simpleMessage("读取联系人列表失败"),
        "contactSearchHint":
            MessageLookupByLibrary.simpleMessage("名称, Mixin ID"),
        "continueText": MessageLookupByLibrary.simpleMessage("继续"),
        "contract": MessageLookupByLibrary.simpleMessage("资产标识"),
        "copyLink": MessageLookupByLibrary.simpleMessage("复制链接"),
        "copyToClipboard": MessageLookupByLibrary.simpleMessage("已复制到剪切板"),
        "createPin": MessageLookupByLibrary.simpleMessage("创建 PIN"),
        "createPinTips":
            MessageLookupByLibrary.simpleMessage("创建 PIN 以保护您的账户安全"),
        "currency": MessageLookupByLibrary.simpleMessage("货币"),
        "customDateRange": MessageLookupByLibrary.simpleMessage("自定义日期范围"),
        "date": MessageLookupByLibrary.simpleMessage("日期"),
        "dateRange": MessageLookupByLibrary.simpleMessage("日期范围"),
        "delete": MessageLookupByLibrary.simpleMessage("删除"),
        "deleteAddress": MessageLookupByLibrary.simpleMessage("删除地址"),
        "deleteAddressByPinTip":
            MessageLookupByLibrary.simpleMessage("请输入 PIN 来完成删除"),
        "deleteEmergencyContact":
            MessageLookupByLibrary.simpleMessage("删除紧急联系人"),
        "deleteWithdrawalAddress": m6,
        "deposit": MessageLookupByLibrary.simpleMessage("充值"),
        "depositConfirmation": m7,
        "depositMemoNotice": MessageLookupByLibrary.simpleMessage(
            "提币时务必填写 Memo(备注)，否则您会丢失您的数字币"),
        "depositNotice": m8,
        "depositReserve": m9,
        "depositTip": m10,
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
        "download": MessageLookupByLibrary.simpleMessage("下载"),
        "downloadMixinMessengerHint":
            MessageLookupByLibrary.simpleMessage("还未安装 Mixin Messenger?"),
        "emergencyContact": MessageLookupByLibrary.simpleMessage("紧急联系人"),
        "emptyAmount": MessageLookupByLibrary.simpleMessage("金额不能为空"),
        "emptyLabelOrAddress":
            MessageLookupByLibrary.simpleMessage("地址和标题不能为空"),
        "eosContractAddress": MessageLookupByLibrary.simpleMessage("EOS 合约地址"),
        "errorAuthentication":
            MessageLookupByLibrary.simpleMessage("错误 401：请重新登录"),
        "errorBadData":
            MessageLookupByLibrary.simpleMessage("错误 10002：请求数据不合法"),
        "errorBlockchain":
            MessageLookupByLibrary.simpleMessage("错误 30100：区块链同步异常，请稍后重试"),
        "errorConnectionTimeout":
            MessageLookupByLibrary.simpleMessage("网络连接超时"),
        "errorFullGroup": MessageLookupByLibrary.simpleMessage("错误 20116：群组已满"),
        "errorInsufficientBalance":
            MessageLookupByLibrary.simpleMessage("错误 20117：余额不足"),
        "errorInsufficientTransactionFeeWithAmount": m11,
        "errorInvalidAddress": m12,
        "errorInvalidAddressPlain":
            MessageLookupByLibrary.simpleMessage("错误 30102：地址格式错误。"),
        "errorInvalidCodeTooFrequent":
            MessageLookupByLibrary.simpleMessage("错误 20129：发送验证码太频繁，请稍后再试"),
        "errorInvalidEmergencyContact":
            MessageLookupByLibrary.simpleMessage("错误 20130：紧急联系人不正确"),
        "errorInvalidPinFormat":
            MessageLookupByLibrary.simpleMessage("错误 20118：PIN 格式不正确"),
        "errorNetworkTaskFailed":
            MessageLookupByLibrary.simpleMessage("网络连接失败。检查或切换网络，然后重试"),
        "errorNoCamera": MessageLookupByLibrary.simpleMessage("没有相机"),
        "errorNoPinToken":
            MessageLookupByLibrary.simpleMessage("缺少凭据，请重新登录之后再尝试使用此功能。"),
        "errorNotFound":
            MessageLookupByLibrary.simpleMessage("错误 404：没有找到相应的信息"),
        "errorNotSupportedAudioFormat":
            MessageLookupByLibrary.simpleMessage("不支持的音频格式，请用其他app打开。"),
        "errorNumberReachedLimit":
            MessageLookupByLibrary.simpleMessage("错误 20132： 已达到上限"),
        "errorOldVersion": m13,
        "errorOpenLocation": MessageLookupByLibrary.simpleMessage("无法找到地图应用"),
        "errorPermission": MessageLookupByLibrary.simpleMessage("请开启相关权限"),
        "errorPhoneInvalidFormat":
            MessageLookupByLibrary.simpleMessage("错误 20110：手机号码不合法"),
        "errorPhoneSmsDelivery":
            MessageLookupByLibrary.simpleMessage("错误 10003：发送短信失败"),
        "errorPhoneVerificationCodeExpired":
            MessageLookupByLibrary.simpleMessage("错误 20114：验证码已过期"),
        "errorPhoneVerificationCodeInvalid":
            MessageLookupByLibrary.simpleMessage("错误 20113：验证码错误"),
        "errorPinCheckTooManyRequest": MessageLookupByLibrary.simpleMessage(
            "你已经尝试了超过 5 次，请等待 24 小时后再次尝试。"),
        "errorPinIncorrect":
            MessageLookupByLibrary.simpleMessage("错误 20119：PIN 不正确"),
        "errorPinIncorrectWithTimes": m14,
        "errorRecaptchaIsInvalid":
            MessageLookupByLibrary.simpleMessage("错误 10004：验证失败"),
        "errorServer5xxCode": m15,
        "errorTooManyRequest":
            MessageLookupByLibrary.simpleMessage("错误 429：请求过于频繁"),
        "errorTooManyStickers":
            MessageLookupByLibrary.simpleMessage("错误 20126：贴纸数已达上限"),
        "errorTooSmallTransferAmount":
            MessageLookupByLibrary.simpleMessage("错误 20120：转账金额太小"),
        "errorTooSmallWithdrawAmount":
            MessageLookupByLibrary.simpleMessage("错误 20127：提现金额太小"),
        "errorTranscriptForward":
            MessageLookupByLibrary.simpleMessage("请在所有附件下载完成之后再转发"),
        "errorUnableToOpenMedia":
            MessageLookupByLibrary.simpleMessage("无法找到能打开该媒体的应用"),
        "errorUnknownWithCode": m16,
        "errorUnknownWithMessage": m17,
        "errorUsedPhone":
            MessageLookupByLibrary.simpleMessage("错误 20122：电话号码已经被占用。"),
        "errorUserInvalidFormat":
            MessageLookupByLibrary.simpleMessage("用户数据不合法"),
        "errorWithdrawalMemoFormatIncorrect":
            MessageLookupByLibrary.simpleMessage("错误 20131：提现备注格式不正确"),
        "export": MessageLookupByLibrary.simpleMessage("导出"),
        "exportTransactionsData":
            MessageLookupByLibrary.simpleMessage("导出交易数据"),
        "fee": MessageLookupByLibrary.simpleMessage("手续费"),
        "filterAll": MessageLookupByLibrary.simpleMessage("全部"),
        "filterApply": MessageLookupByLibrary.simpleMessage("应用"),
        "filterBy": MessageLookupByLibrary.simpleMessage("筛选"),
        "filterTitle": MessageLookupByLibrary.simpleMessage("筛选"),
        "fourthPinConfirmHint": MessageLookupByLibrary.simpleMessage(
            "这是最后一次确认 PIN，记住：PIN 丢失将永远无法找回！"),
        "from": MessageLookupByLibrary.simpleMessage("来自"),
        "goPay": MessageLookupByLibrary.simpleMessage("去支付"),
        "gotIt": MessageLookupByLibrary.simpleMessage("知道了"),
        "hiddenAssets": MessageLookupByLibrary.simpleMessage("隐藏的资产"),
        "hide": MessageLookupByLibrary.simpleMessage("隐藏"),
        "hideSmallAssets": MessageLookupByLibrary.simpleMessage("隐藏小额资产"),
        "incomplete": MessageLookupByLibrary.simpleMessage("未完成"),
        "lastNinetyDays": MessageLookupByLibrary.simpleMessage("最近 90 天"),
        "lastSevenDays": MessageLookupByLibrary.simpleMessage("最近 7 天"),
        "lastThirtyDays": MessageLookupByLibrary.simpleMessage("最近 30 天"),
        "linkGenerated": MessageLookupByLibrary.simpleMessage("链接已生成"),
        "logs": MessageLookupByLibrary.simpleMessage("日志"),
        "memo": MessageLookupByLibrary.simpleMessage("Memo(备注)"),
        "memoHint": MessageLookupByLibrary.simpleMessage("备注（Memo）"),
        "minerFee": MessageLookupByLibrary.simpleMessage("挖矿手续费"),
        "minimumReserve": MessageLookupByLibrary.simpleMessage("最少保留数量："),
        "minimumWithdrawal": MessageLookupByLibrary.simpleMessage("最小提现数量："),
        "mixinWallet": MessageLookupByLibrary.simpleMessage("Mixin 钱包"),
        "multisigTransaction": MessageLookupByLibrary.simpleMessage("多重签名交易"),
        "networkFee": MessageLookupByLibrary.simpleMessage("网络手续费："),
        "networkFeeTip": MessageLookupByLibrary.simpleMessage(
            "由第三方服务商收取。直接支付给以太坊矿工以保证以太坊上交易完成。网络费根据即时市场状况变动。"),
        "networkType": MessageLookupByLibrary.simpleMessage("网络类型"),
        "next": MessageLookupByLibrary.simpleMessage("下一步"),
        "nfts": MessageLookupByLibrary.simpleMessage("NFTs"),
        "noAsset": MessageLookupByLibrary.simpleMessage("暂无资产"),
        "noCollectiblesFound":
            MessageLookupByLibrary.simpleMessage("No collectibles found"),
        "noCollectionFound":
            MessageLookupByLibrary.simpleMessage("No collection found"),
        "noLimit": MessageLookupByLibrary.simpleMessage("不限"),
        "noLogs": MessageLookupByLibrary.simpleMessage("暂无日志"),
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
        "pendingConfirmations": m18,
        "phoneNumberChange": MessageLookupByLibrary.simpleMessage("修改手机号码"),
        "pinChange": MessageLookupByLibrary.simpleMessage("修改 PIN"),
        "pinConfirmAgainHint":
            MessageLookupByLibrary.simpleMessage("请再次确认您的 6 位 PIN"),
        "pinConfirmHint":
            MessageLookupByLibrary.simpleMessage("确认 6 位数字 PIN 并牢记它"),
        "pinCreation": MessageLookupByLibrary.simpleMessage("创建 PIN"),
        "pinIncorrect": MessageLookupByLibrary.simpleMessage("PIN 不正确"),
        "pinLostHint": MessageLookupByLibrary.simpleMessage("如果忘记，你的钱包将无法找回。"),
        "pinNotMatch": MessageLookupByLibrary.simpleMessage("PIN 不一致, 请重新输入"),
        "pinUnsafe": MessageLookupByLibrary.simpleMessage("PIN 过于简单不安全"),
        "raw": MessageLookupByLibrary.simpleMessage("其他"),
        "rawTransaction": MessageLookupByLibrary.simpleMessage("交易原始值"),
        "reauthorize": MessageLookupByLibrary.simpleMessage("重新授权"),
        "rebate": MessageLookupByLibrary.simpleMessage("退款"),
        "receive": MessageLookupByLibrary.simpleMessage("接收"),
        "received": MessageLookupByLibrary.simpleMessage("获得"),
        "receivers": MessageLookupByLibrary.simpleMessage("接收者"),
        "recentSearches": MessageLookupByLibrary.simpleMessage("最近搜索"),
        "refund": MessageLookupByLibrary.simpleMessage("退回"),
        "removeAuthorize": MessageLookupByLibrary.simpleMessage("取消授权"),
        "requestPayment": MessageLookupByLibrary.simpleMessage("请求付款"),
        "requestPaymentAmount": m19,
        "requestPaymentGeneratedTips":
            MessageLookupByLibrary.simpleMessage("请求付款链接已生成，请发送给指定联系人。"),
        "revokeMultisigTransaction":
            MessageLookupByLibrary.simpleMessage("撤销多重签名交易"),
        "save": MessageLookupByLibrary.simpleMessage("保存"),
        "search": MessageLookupByLibrary.simpleMessage("搜索"),
        "selectContactOrAddress":
            MessageLookupByLibrary.simpleMessage("选择地址或联系人"),
        "send": MessageLookupByLibrary.simpleMessage("发送"),
        "sendLink": MessageLookupByLibrary.simpleMessage("发送链接"),
        "sendTo": m20,
        "sendToContact": MessageLookupByLibrary.simpleMessage("转账至联系人"),
        "setNewPin": MessageLookupByLibrary.simpleMessage("设置新的 PIN"),
        "setNewPinDesc": MessageLookupByLibrary.simpleMessage("设置新的 6 位数字 PIN"),
        "settings": MessageLookupByLibrary.simpleMessage("设置"),
        "show": MessageLookupByLibrary.simpleMessage("显示"),
        "signIn": MessageLookupByLibrary.simpleMessage("登录"),
        "signInDesktopApp": MessageLookupByLibrary.simpleMessage("登录桌面端"),
        "signInWithEmergencyContact":
            MessageLookupByLibrary.simpleMessage("使用紧急联系人登录"),
        "signInWithPhoneNumber":
            MessageLookupByLibrary.simpleMessage("使用手机号码登录"),
        "signTransaction": MessageLookupByLibrary.simpleMessage("签名交易"),
        "signers": MessageLookupByLibrary.simpleMessage("签名者"),
        "slippage": MessageLookupByLibrary.simpleMessage("滑点"),
        "slippageOver": m21,
        "snapshotHash": MessageLookupByLibrary.simpleMessage("Snapshot hash"),
        "sortBy": MessageLookupByLibrary.simpleMessage("排序"),
        "state": MessageLookupByLibrary.simpleMessage("State"),
        "submitTransaction": MessageLookupByLibrary.simpleMessage("提交交易"),
        "swap": MessageLookupByLibrary.simpleMessage("闪兑"),
        "swapDisclaimer":
            MessageLookupByLibrary.simpleMessage("服务由 MixSwap 提供"),
        "swapType": MessageLookupByLibrary.simpleMessage("兑换币种"),
        "symbol": MessageLookupByLibrary.simpleMessage("符号"),
        "tagHint": MessageLookupByLibrary.simpleMessage("标签（Tag）"),
        "thirdPinConfirmHint": MessageLookupByLibrary.simpleMessage(
            "很少看到第三次确认吧！所以请牢记，PIN 丢失是无法找回的。"),
        "time": MessageLookupByLibrary.simpleMessage("时间"),
        "to": MessageLookupByLibrary.simpleMessage("至"),
        "totalBalance": MessageLookupByLibrary.simpleMessage("总余额"),
        "transaction": MessageLookupByLibrary.simpleMessage("转账"),
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
        "type": MessageLookupByLibrary.simpleMessage("类型"),
        "undo": MessageLookupByLibrary.simpleMessage("撤销"),
        "unpaid": MessageLookupByLibrary.simpleMessage("未支付"),
        "verify": MessageLookupByLibrary.simpleMessage("验证"),
        "verifyOldPin": MessageLookupByLibrary.simpleMessage("验证旧的 PIN"),
        "viewEmergencyContact": MessageLookupByLibrary.simpleMessage("查看紧急联系人"),
        "waitingActionDone": MessageLookupByLibrary.simpleMessage("等待操作完成..."),
        "walletTransactionCurrentValue": m22,
        "walletTransactionThatTimeNoValue":
            MessageLookupByLibrary.simpleMessage("当时价值 暂无"),
        "walletTransactionThatTimeValue": m23,
        "warningExportInWebView": MessageLookupByLibrary.simpleMessage(
            "当前处于 WebView 中，无法导出数据。请使用浏览器打开。"),
        "wireServiceTip": MessageLookupByLibrary.simpleMessage(
            "本服务由 Wyre 提供。我们仅作为渠道，不额外收取手续费。"),
        "withdrawal": MessageLookupByLibrary.simpleMessage("提现"),
        "withdrawalMemoHint": MessageLookupByLibrary.simpleMessage("备注 (可选)"),
        "withdrawalTo": m24,
        "withdrawalWithPin": MessageLookupByLibrary.simpleMessage("用 PIN 提现"),
        "wyreServiceStatement": MessageLookupByLibrary.simpleMessage("服务声明"),
        "youPinHasBeenCreated":
            MessageLookupByLibrary.simpleMessage("你的 PIN 已创建")
      };
}
