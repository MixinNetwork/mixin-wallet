// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(value) => "${value} has been hidden";

  static String m1(value) => "${value} has been shown";

  static String m2(value) => "Average arrival time:${value}";

  static String m3(value) => "${value} BTC";

  static String m4(value) =>
      "Deposit will arrive after at least ${value} block confirmations";

  static String m5(value) =>
      "Both a Memo and an Address are required to successfully deposit your ${value} to your account.";

  static String m6(value) => "Deposit at least ${value} for the first time";

  static String m7(value) => "This address only supports ${value}.";

  static String m8(value, value2) => "${value}/${value2} confirmations";

  static String m9(value) =>
      "Swap with slippage greater than ${value} is not currently supported";

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
        "addAddressNotSupportTip": MessageLookupByLibrary.simpleMessage(
            "Mixin does not support withdrawal to the"),
        "addAddressTagAction": MessageLookupByLibrary.simpleMessage("No Tag"),
        "address": MessageLookupByLibrary.simpleMessage("Address"),
        "addressSearchHint":
            MessageLookupByLibrary.simpleMessage("Label, Address"),
        "allTransactions":
            MessageLookupByLibrary.simpleMessage("All Transactions"),
        "alreadyHidden": m0,
        "alreadyShown": m1,
        "amount": MessageLookupByLibrary.simpleMessage("Amount"),
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
        "averageArrival": m2,
        "balance": MessageLookupByLibrary.simpleMessage("BALANCE"),
        "balanceOfBtc": m3,
        "buy": MessageLookupByLibrary.simpleMessage("Buy"),
        "buyDisclaimer": MessageLookupByLibrary.simpleMessage(
            "Services provided by https://sendwyre.com"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "chain": MessageLookupByLibrary.simpleMessage("Chain"),
        "comingSoon": MessageLookupByLibrary.simpleMessage("Coming soon"),
        "completed": MessageLookupByLibrary.simpleMessage("Completed"),
        "contact": MessageLookupByLibrary.simpleMessage("Contact"),
        "contactReadFailed":
            MessageLookupByLibrary.simpleMessage("Failed to read contact list"),
        "contactSearchHint":
            MessageLookupByLibrary.simpleMessage("Name, Mixin ID"),
        "contract": MessageLookupByLibrary.simpleMessage("Asset Key"),
        "copyToClipboard":
            MessageLookupByLibrary.simpleMessage("Copied to Clipboard"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deposit": MessageLookupByLibrary.simpleMessage("Deposit"),
        "depositConfirmation": m4,
        "depositMemoNotice": MessageLookupByLibrary.simpleMessage(
            "Memo is required, or you will lose your coins."),
        "depositNotice": m5,
        "depositReserve": m6,
        "depositTip": m7,
        "depositTipBtc": MessageLookupByLibrary.simpleMessage(
            "This address only supports BTC."),
        "depositTipEos": MessageLookupByLibrary.simpleMessage(
            "This address supports all base on EOS tokens."),
        "depositTipEth": MessageLookupByLibrary.simpleMessage(
            "This address supports all ERC-20 tokens."),
        "depositTipNotSupportContract": MessageLookupByLibrary.simpleMessage(
            "Do not support smart contract transfers."),
        "depositTipTron": MessageLookupByLibrary.simpleMessage(
            "This address supports all TRC-10 and TRC-20 tokens, such as TRX, USDT-TRON, etc."),
        "depositing": MessageLookupByLibrary.simpleMessage("Depositing"),
        "dontShowAgain":
            MessageLookupByLibrary.simpleMessage("Don\'t show again"),
        "emptyAmount": MessageLookupByLibrary.simpleMessage("Empty amount"),
        "emptyLabelOrAddress":
            MessageLookupByLibrary.simpleMessage("Empty address or label"),
        "eosContractAddress":
            MessageLookupByLibrary.simpleMessage("EOS contract address"),
        "errorNoCamera": MessageLookupByLibrary.simpleMessage("No camera"),
        "fee": MessageLookupByLibrary.simpleMessage("Fee"),
        "filterAll": MessageLookupByLibrary.simpleMessage("All"),
        "filterApply": MessageLookupByLibrary.simpleMessage("Apply"),
        "filterBy": MessageLookupByLibrary.simpleMessage("FILTER BY"),
        "filterTitle": MessageLookupByLibrary.simpleMessage("Filter"),
        "from": MessageLookupByLibrary.simpleMessage("From"),
        "goPay": MessageLookupByLibrary.simpleMessage("Go pay"),
        "gotIt": MessageLookupByLibrary.simpleMessage("Got it"),
        "hiddenAssets": MessageLookupByLibrary.simpleMessage("Hidden Assets"),
        "hide": MessageLookupByLibrary.simpleMessage("Hide"),
        "hideSmallAssets":
            MessageLookupByLibrary.simpleMessage("Hide small assets"),
        "incomplete": MessageLookupByLibrary.simpleMessage("Incomplete"),
        "memo": MessageLookupByLibrary.simpleMessage("Memo"),
        "memoHint": MessageLookupByLibrary.simpleMessage("Memo"),
        "minerFee": MessageLookupByLibrary.simpleMessage("Miner Fee"),
        "minimumReserve":
            MessageLookupByLibrary.simpleMessage("Minimum reserve:"),
        "minimumWithdrawal":
            MessageLookupByLibrary.simpleMessage("Minimum withdrawal:"),
        "mixinWallet": MessageLookupByLibrary.simpleMessage("Mixin Wallet"),
        "networkFee": MessageLookupByLibrary.simpleMessage("Network fee:"),
        "networkFeeTip": MessageLookupByLibrary.simpleMessage(
            "Charged by third party service provider. Paid directly to Ethereum miners to ensure transactions are completed on Ethereum. Network fees vary based on immediate market conditions."),
        "networkType": MessageLookupByLibrary.simpleMessage("Network type"),
        "noAsset": MessageLookupByLibrary.simpleMessage("NO ASSET"),
        "noResult": MessageLookupByLibrary.simpleMessage("NO RESULT"),
        "noTransaction": MessageLookupByLibrary.simpleMessage("NO TRANSACTION"),
        "noWithdrawalDestinationSelected": MessageLookupByLibrary.simpleMessage(
            "No contact or address selected"),
        "none": MessageLookupByLibrary.simpleMessage("N/A"),
        "notMeetMinimumAmount": MessageLookupByLibrary.simpleMessage(
            "Does not meet minimum transaction size"),
        "notice": MessageLookupByLibrary.simpleMessage("Notice"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "other": MessageLookupByLibrary.simpleMessage("Other"),
        "paid": MessageLookupByLibrary.simpleMessage("Paid"),
        "paidInMixin":
            MessageLookupByLibrary.simpleMessage("Have you paid in Mixin?"),
        "paidInMixinWarning": MessageLookupByLibrary.simpleMessage(
            "If you have paid via Mixin, please be patient."),
        "pay": MessageLookupByLibrary.simpleMessage("Pay"),
        "pendingConfirmations": m8,
        "raw": MessageLookupByLibrary.simpleMessage("Raw"),
        "reauthorize": MessageLookupByLibrary.simpleMessage("Reauthorize"),
        "rebate": MessageLookupByLibrary.simpleMessage("Rebate"),
        "receive": MessageLookupByLibrary.simpleMessage("Receive"),
        "received": MessageLookupByLibrary.simpleMessage("Received"),
        "recentSearches":
            MessageLookupByLibrary.simpleMessage("Recent searches"),
        "refund": MessageLookupByLibrary.simpleMessage("Refund"),
        "removeAuthorize": MessageLookupByLibrary.simpleMessage("Deauthorize"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "search": MessageLookupByLibrary.simpleMessage("Search"),
        "selectContactOrAddress":
            MessageLookupByLibrary.simpleMessage("Choose a address or contact"),
        "send": MessageLookupByLibrary.simpleMessage("Send"),
        "sendTo": MessageLookupByLibrary.simpleMessage("Send to"),
        "sendToContact":
            MessageLookupByLibrary.simpleMessage("Send to contact"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "show": MessageLookupByLibrary.simpleMessage("Show"),
        "slippage": MessageLookupByLibrary.simpleMessage("Slippage"),
        "slippageOver": m9,
        "sortBy": MessageLookupByLibrary.simpleMessage("SORT BY"),
        "swap": MessageLookupByLibrary.simpleMessage("Swap"),
        "swapDisclaimer": MessageLookupByLibrary.simpleMessage(
            "Services provided by MixSwap"),
        "swapType": MessageLookupByLibrary.simpleMessage("Swap type"),
        "symbol": MessageLookupByLibrary.simpleMessage("Symbol"),
        "tagHint": MessageLookupByLibrary.simpleMessage("Tag"),
        "time": MessageLookupByLibrary.simpleMessage("Time"),
        "to": MessageLookupByLibrary.simpleMessage("To"),
        "totalBalance": MessageLookupByLibrary.simpleMessage("Total Balance"),
        "trace": MessageLookupByLibrary.simpleMessage("Trace"),
        "transaction": MessageLookupByLibrary.simpleMessage("Transaction"),
        "transactionChecking": MessageLookupByLibrary.simpleMessage("Checking"),
        "transactionDone": MessageLookupByLibrary.simpleMessage("Done"),
        "transactionFee":
            MessageLookupByLibrary.simpleMessage("Transaction fee:"),
        "transactionFeeTip": MessageLookupByLibrary.simpleMessage(
            "Charged by third party service provider. US users are charged 2.9% + 30c of the transaction amount with a minimum charge of \$5. International users are charged 3.9% + 30c of the transaction amount with a minimum charge of \$5."),
        "transactionHash":
            MessageLookupByLibrary.simpleMessage("Transaction Hash"),
        "transactionPhase":
            MessageLookupByLibrary.simpleMessage("Transaction phase"),
        "transactionTrading": MessageLookupByLibrary.simpleMessage("Trading"),
        "transactions": MessageLookupByLibrary.simpleMessage("Transactions"),
        "transactionsAssetKeyWarning": MessageLookupByLibrary.simpleMessage(
            "Asset key is NOT a deposit address!"),
        "transactionsId":
            MessageLookupByLibrary.simpleMessage("Transaction Id"),
        "transactionsStatus": MessageLookupByLibrary.simpleMessage("Status"),
        "transactionsType":
            MessageLookupByLibrary.simpleMessage("Transaction Type"),
        "transfer": MessageLookupByLibrary.simpleMessage("Transfer"),
        "transferDetail":
            MessageLookupByLibrary.simpleMessage("Transfer details"),
        "undo": MessageLookupByLibrary.simpleMessage("UNDO"),
        "unpaid": MessageLookupByLibrary.simpleMessage("Unpaid"),
        "waitingActionDone":
            MessageLookupByLibrary.simpleMessage("Waiting action done..."),
        "walletTransactionCurrentValue": m10,
        "walletTransactionThatTimeNoValue":
            MessageLookupByLibrary.simpleMessage("value then N/A"),
        "walletTransactionThatTimeValue": m11,
        "wireServiceTip": MessageLookupByLibrary.simpleMessage(
            "This service is provided by Wyre. We act as a conduit only and do not charge additional fees."),
        "withdrawal": MessageLookupByLibrary.simpleMessage("Withdrawal"),
        "withdrawalMemoHint":
            MessageLookupByLibrary.simpleMessage("Memo (Optional)"),
        "wyreServiceStatement":
            MessageLookupByLibrary.simpleMessage("Service statement")
      };
}
