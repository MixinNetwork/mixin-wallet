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
      "Notice: Both an Account Memo and an Account Name are required to successfully deposit your ${value} to Mixin.";

  static String m5(value) => "Send only ${value} to this deposit address.";

  static String m6(value) =>
      "Sending coin or token other than ${value} to this address my result in the loss of your deposit.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "address": MessageLookupByLibrary.simpleMessage("Address"),
        "approxBalanceOfBtc": m0,
        "approxOf": m1,
        "assets": MessageLookupByLibrary.simpleMessage("Assets"),
        "averageArrival": m2,
        "balanceOfBtc": m3,
        "deposit": MessageLookupByLibrary.simpleMessage("Deposit"),
        "depositNotice": m4,
        "depositOnly": m5,
        "depositOnlyDesc": m6,
        "memo": MessageLookupByLibrary.simpleMessage("MEMO"),
        "noTransaction": MessageLookupByLibrary.simpleMessage("NO TRANSACTION"),
        "none": MessageLookupByLibrary.simpleMessage("N/A"),
        "receive": MessageLookupByLibrary.simpleMessage("Receive"),
        "send": MessageLookupByLibrary.simpleMessage("Send"),
        "totalBalance": MessageLookupByLibrary.simpleMessage("Total Balance"),
        "transactions": MessageLookupByLibrary.simpleMessage("Transactions")
      };
}
