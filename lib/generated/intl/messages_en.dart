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

  static String m0(value) => "≈ ${value} BTC";

  static String m1(value) => "≈ ${value}";

  static String m2(value) => "Average arrival time:${value}";

  static String m3(value) => "${value} BTC";

  static String m4(value) =>
      "Deposit will arrive after at least ${value} block confirmations";

  static String m5(value) =>
      "Notice: Both an Account Memo and an Account Name are required to successfully deposit your ${value} to Mixin.";

  static String m6(value) =>
      "Sending coin or token other than ${value} to this address my result in the loss of your deposit.";

  static String m7(value) => "This address only supports ${value}.";

  static String m8(value, value2) => "${value}/${value2} confirmations";

  static String m9(value) => "value now ${value}";

  static String m10(value) => ",value then ${value}";

  static String m11(value1, value2) =>
      "A transaction fee of ${value1} is required for withdrawing ${value2}";

  static String m12(value1, value2, value3, value4, value5) =>
      "A transaction fee of ${value1} is required for withdrawing ${value2}. ${value3} has a minimum ${value4} ${value5} reserve requirement.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "addAddress": MessageLookupByLibrary.simpleMessage("Add address"),
        "addAddressLabelHint": MessageLookupByLibrary.simpleMessage(
            "Label (e.g. exchanges, wallets, etc.)"),
        "address": MessageLookupByLibrary.simpleMessage("Address"),
        "addressSearchHint":
            MessageLookupByLibrary.simpleMessage("Label, Address"),
        "allTransactions":
            MessageLookupByLibrary.simpleMessage("All Transactions"),
        "amount": MessageLookupByLibrary.simpleMessage("Amount"),
        "approxBalanceOfBtc": m0,
        "approxOf": m1,
        "assetTrending": MessageLookupByLibrary.simpleMessage("Trending"),
        "assetType": MessageLookupByLibrary.simpleMessage("Asset Type"),
        "assets": MessageLookupByLibrary.simpleMessage("Assets"),
        "averageArrival": m2,
        "balanceOfBtc": m3,
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "chain": MessageLookupByLibrary.simpleMessage("Chain"),
        "contract": MessageLookupByLibrary.simpleMessage("Asset Key"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deposit": MessageLookupByLibrary.simpleMessage("Deposit"),
        "depositConfirmation": m4,
        "depositNotice": m5,
        "depositOnlyDesc": m6,
        "depositTip": m7,
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
        "from": MessageLookupByLibrary.simpleMessage("From"),
        "memo": MessageLookupByLibrary.simpleMessage("MEMO"),
        "memoHint": MessageLookupByLibrary.simpleMessage(
            "Confirm if the receiving address requires a MEMO."),
        "memoNo": MessageLookupByLibrary.simpleMessage("No Memo"),
        "memoOptional": MessageLookupByLibrary.simpleMessage("MEMO (Optional)"),
        "minerFee": MessageLookupByLibrary.simpleMessage("Miner Fee"),
        "noTransaction": MessageLookupByLibrary.simpleMessage("NO TRANSACTION"),
        "none": MessageLookupByLibrary.simpleMessage("N/A"),
        "pendingConfirmations": m8,
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
        "sortBy": MessageLookupByLibrary.simpleMessage("SORT BY"),
        "symbol": MessageLookupByLibrary.simpleMessage("Symbol"),
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
        "walletTransactionCurrentValue": m9,
        "walletTransactionThatTimeNoValue":
            MessageLookupByLibrary.simpleMessage(",value then N/A"),
        "walletTransactionThatTimeValue": m10,
        "withdrawal": MessageLookupByLibrary.simpleMessage("Withdrawal"),
        "withdrawalFee": m11,
        "withdrawalFeeReserve": m12
      };
}
