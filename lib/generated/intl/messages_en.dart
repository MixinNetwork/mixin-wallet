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

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "address": MessageLookupByLibrary.simpleMessage("Address"),
        "approxBalanceOfBtc": m0,
        "approxOf": m1,
        "assetType": MessageLookupByLibrary.simpleMessage("Asset Type"),
        "assets": MessageLookupByLibrary.simpleMessage("Assets"),
        "averageArrival": m2,
        "balanceOfBtc": m3,
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
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
        "from": MessageLookupByLibrary.simpleMessage("From"),
        "memo": MessageLookupByLibrary.simpleMessage("MEMO"),
        "noTransaction": MessageLookupByLibrary.simpleMessage("NO TRANSACTION"),
        "none": MessageLookupByLibrary.simpleMessage("N/A"),
        "raw": MessageLookupByLibrary.simpleMessage("Raw"),
        "rebate": MessageLookupByLibrary.simpleMessage("Rebate"),
        "receive": MessageLookupByLibrary.simpleMessage("Receive"),
        "search": MessageLookupByLibrary.simpleMessage("Search"),
        "send": MessageLookupByLibrary.simpleMessage("Send"),
        "time": MessageLookupByLibrary.simpleMessage("Time"),
        "to": MessageLookupByLibrary.simpleMessage("To"),
        "totalBalance": MessageLookupByLibrary.simpleMessage("Total Balance"),
        "trace": MessageLookupByLibrary.simpleMessage("Trace"),
        "transactions": MessageLookupByLibrary.simpleMessage("Transactions"),
        "transactionsId":
            MessageLookupByLibrary.simpleMessage("Transaction Id"),
        "transactionsStatus": MessageLookupByLibrary.simpleMessage("Status"),
        "transactionsType":
            MessageLookupByLibrary.simpleMessage("Transaction Type"),
        "transfer": MessageLookupByLibrary.simpleMessage("Transfer"),
        "withdrawal": MessageLookupByLibrary.simpleMessage("Withdrawal")
      };
}
