// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(value) => "${value} has been hidden";

  static String m1(value) => "${value} has been shown";

  static String m2(value) => "≈ ${value} BTC";

  static String m3(value) => "≈ ${value}";

  static String m4(value) => "Average arrival time:${value}";

  static String m5(value) => "${value} BTC";

  static String m6(value) =>
      "Deposit will arrive after at least ${value} block confirmations";

  static String m7(value) =>
      "Notice: Both an Account Memo and an Account Name are required to successfully deposit your ${value} to Mixin.";

  static String m8(value) => "This address only supports ${value}.";

  static String m9(value, value2) => "${value}/${value2} confirmations";

  static String m10(value) => "value now ${value}";

  static String m11(value) => "value then ${value}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "addAddress": MessageLookupByLibrary.simpleMessage("Add address"),
        "addAddressLabelHint": MessageLookupByLibrary.simpleMessage(
            "Label (e.g. exchanges, wallets, etc.)"),
        "addAddressMemo": MessageLookupByLibrary.simpleMessage(
            "Destination Tag or ID Number or notes. If not, you can set it "),
        "addAddressMemoAction": MessageLookupByLibrary.simpleMessage("No Memo"),
        "addAddressNoMemo": MessageLookupByLibrary.simpleMessage(
            "If you are required to fill in Destination Tag or ID Number or notes, you can "),
        "addAddressNoMemoAction":
            MessageLookupByLibrary.simpleMessage("Add Memo"),
        "addAddressNoTagAction":
            MessageLookupByLibrary.simpleMessage("Add Tag"),
        "addAddressTagAction": MessageLookupByLibrary.simpleMessage("No Tag"),
        "address": MessageLookupByLibrary.simpleMessage("Address"),
        "addressSearchHint":
            MessageLookupByLibrary.simpleMessage("Label, Address"),
        "allTransactions":
            MessageLookupByLibrary.simpleMessage("All Transactions"),
        "alreadyHidden": m0,
        "alreadyShown": m1,
        "amount": MessageLookupByLibrary.simpleMessage("Amount"),
        "approxBalanceOfBtc": m2,
        "approxOf": m3,
        "assetTrending": MessageLookupByLibrary.simpleMessage("Trending"),
        "assetType": MessageLookupByLibrary.simpleMessage("Asset Type"),
        "assets": MessageLookupByLibrary.simpleMessage("Assets"),
        "authHint": MessageLookupByLibrary.simpleMessage(
            "Read-only authorization cannot use your assets, please rest assured"),
        "authSlogan": MessageLookupByLibrary.simpleMessage(
            "Mixin Wallet is a user-friendly, secure and powerful multi-chain digital wallet."),
        "authTips": MessageLookupByLibrary.simpleMessage(
            "An open source cryptocurrency wallet"),
        "authorize": MessageLookupByLibrary.simpleMessage("Authorize"),
        "averageArrival": m4,
        "balanceOfBtc": m5,
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "chain": MessageLookupByLibrary.simpleMessage("Chain"),
        "contract": MessageLookupByLibrary.simpleMessage("Asset Key"),
        "copyToClipboard":
            MessageLookupByLibrary.simpleMessage("Copy to clipboard"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deposit": MessageLookupByLibrary.simpleMessage("Deposit"),
        "depositConfirmation": m6,
        "depositNotice": m7,
        "depositTip": m8,
        "depositTipBtc": MessageLookupByLibrary.simpleMessage(
            "This address only supports BTC and Omni USDT."),
        "depositTipEos": MessageLookupByLibrary.simpleMessage(
            "This address supports all base on EOS tokens, such as EOS, IQ, BLACK, OCT, KARMA, etc."),
        "depositTipEth": MessageLookupByLibrary.simpleMessage(
            "This address supports all ERC-20 tokens, such as ETH, XIN, TUSD, HT, LOOM, LEO, etc."),
        "depositTipTron": MessageLookupByLibrary.simpleMessage(
            "This address supports all TRC-10 and TRC-20 tokens, such as TRX, BTT, USDT-TRON, etc."),
        "depositing": MessageLookupByLibrary.simpleMessage("Depositing"),
        "fee": MessageLookupByLibrary.simpleMessage("Fee"),
        "filterAll": MessageLookupByLibrary.simpleMessage("All"),
        "filterApply": MessageLookupByLibrary.simpleMessage("Apply"),
        "filterBy": MessageLookupByLibrary.simpleMessage("FILTER BY"),
        "filterTitle": MessageLookupByLibrary.simpleMessage("Filter"),
        "finishVerifyPIN":
            MessageLookupByLibrary.simpleMessage("Finished verifying PIN ?"),
        "from": MessageLookupByLibrary.simpleMessage("From"),
        "hiddenAssets": MessageLookupByLibrary.simpleMessage("Hidden Assets"),
        "hide": MessageLookupByLibrary.simpleMessage("Hide"),
        "hideSmallAssets":
            MessageLookupByLibrary.simpleMessage("Hide small assets"),
        "memo": MessageLookupByLibrary.simpleMessage("MEMO"),
        "memoHint": MessageLookupByLibrary.simpleMessage("Memo"),
        "minerFee": MessageLookupByLibrary.simpleMessage("Miner Fee"),
        "minimumReserve":
            MessageLookupByLibrary.simpleMessage("Minimum reserve:"),
        "minimumWithdrawal":
            MessageLookupByLibrary.simpleMessage("Minimum withdrawal:"),
        "mixinWallet": MessageLookupByLibrary.simpleMessage("Mixin Wallet"),
        "networkFee": MessageLookupByLibrary.simpleMessage("Network fee:"),
        "noTransaction": MessageLookupByLibrary.simpleMessage("NO TRANSACTION"),
        "none": MessageLookupByLibrary.simpleMessage("N/A"),
        "pendingConfirmations": m9,
        "raw": MessageLookupByLibrary.simpleMessage("Raw"),
        "rebate": MessageLookupByLibrary.simpleMessage("Rebate"),
        "receive": MessageLookupByLibrary.simpleMessage("Receive"),
        "recentSearches":
            MessageLookupByLibrary.simpleMessage("Recent searches"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "search": MessageLookupByLibrary.simpleMessage("Search"),
        "selectFromAddressBook":
            MessageLookupByLibrary.simpleMessage("Select from Address Book"),
        "send": MessageLookupByLibrary.simpleMessage("Send"),
        "sendToAddress":
            MessageLookupByLibrary.simpleMessage("Send to Address"),
        "show": MessageLookupByLibrary.simpleMessage("Show"),
        "sortBy": MessageLookupByLibrary.simpleMessage("SORT BY"),
        "sure": MessageLookupByLibrary.simpleMessage("Sure"),
        "symbol": MessageLookupByLibrary.simpleMessage("Symbol"),
        "tagHint": MessageLookupByLibrary.simpleMessage("Tag"),
        "time": MessageLookupByLibrary.simpleMessage("Time"),
        "to": MessageLookupByLibrary.simpleMessage("To"),
        "totalBalance": MessageLookupByLibrary.simpleMessage("Total Balance"),
        "trace": MessageLookupByLibrary.simpleMessage("Trace"),
        "transactions": MessageLookupByLibrary.simpleMessage("Transactions"),
        "transactionsAssetKeyWarning": MessageLookupByLibrary.simpleMessage(
            "Asset key is NOT a deposit address!"),
        "transactionsId":
            MessageLookupByLibrary.simpleMessage("Transaction Id"),
        "transactionsStatus": MessageLookupByLibrary.simpleMessage("Status"),
        "transactionsType":
            MessageLookupByLibrary.simpleMessage("Transaction Type"),
        "transfer": MessageLookupByLibrary.simpleMessage("Transfer"),
        "undo": MessageLookupByLibrary.simpleMessage("UNDO"),
        "walletTransactionCurrentValue": m10,
        "walletTransactionThatTimeNoValue":
            MessageLookupByLibrary.simpleMessage("value then N/A"),
        "walletTransactionThatTimeValue": m11,
        "withdrawal": MessageLookupByLibrary.simpleMessage("Withdrawal")
      };
}
