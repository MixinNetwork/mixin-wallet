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

  static String m0(value) => "Add ${value} address";

  static String m1(value) => "${value} has been hidden";

  static String m2(value) => "${value} has been shown";

  static String m3(value) => "Average arrival time:${value}";

  static String m4(value) => "${value} BTC";

  static String m5(count) => "${count} items";

  static String m6(value) => "Delete ${value} address";

  static String m7(value) =>
      "Deposit will arrive after at least ${value} block confirmations";

  static String m8(value) =>
      "Both a Memo and an Address are required to successfully deposit your ${value} to your account.";

  static String m9(value) => "Deposit at least ${value} for the first time";

  static String m10(value) => "This address only supports ${value}.";

  static String m11(arg0) =>
      "ERROR 20124: Insufficient transaction fee. Please make sure your wallet has ${arg0} as fee";

  static String m12(arg0, arg1) =>
      "ERROR 30102: Invalid address format. Please enter the correct ${arg0} ${arg1} address!";

  static String m13(arg0) =>
      "ERROR 10006: Please update Mixin(${arg0}) to continue use the service.";

  static String m14(count, arg0) =>
      "${Intl.plural(count, one: 'ERROR 20119: PIN incorrect. You still have ${arg0} chance. Please wait for 24 hours to retry later.', other: 'ERROR 20119: PIN incorrect. You still have ${arg0} chances. Please wait for 24 hours to retry later.')}";

  static String m15(arg0) => "Server is under maintenance: ${arg0}";

  static String m16(arg0) => "ERROR: ${arg0}";

  static String m17(arg0) => "ERROR: ${arg0}";

  static String m18(value, value2) => "${value}/${value2} confirmations";

  static String m19(value) => "Request payment amount: ${value}";

  static String m20(value) => "Send to ${value}";

  static String m21(value) =>
      "Swap with slippage greater than ${value} is not currently supported";

  static String m22(value) => "value now ${value}";

  static String m23(value) => "value then ${value}";

  static String m24(value) => "Withdrawal to ${value}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "accessDenied": MessageLookupByLibrary.simpleMessage("Access denied"),
        "addAddress": MessageLookupByLibrary.simpleMessage("Add address"),
        "addAddressByPinTip":
            MessageLookupByLibrary.simpleMessage("Enter PIN to save address"),
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
        "addWithdrawalAddress": m0,
        "address": MessageLookupByLibrary.simpleMessage("Address"),
        "addressSearchHint":
            MessageLookupByLibrary.simpleMessage("Label, Address"),
        "allTransactions":
            MessageLookupByLibrary.simpleMessage("All Transactions"),
        "alreadyHidden": m1,
        "alreadyShown": m2,
        "amount": MessageLookupByLibrary.simpleMessage("Amount"),
        "assetAddressGeneratingTip": MessageLookupByLibrary.simpleMessage(
            "Asset address is being generated, please wait..."),
        "assetTrending": MessageLookupByLibrary.simpleMessage("Trending"),
        "assetType": MessageLookupByLibrary.simpleMessage("Asset Type"),
        "assets": MessageLookupByLibrary.simpleMessage("Assets"),
        "authHint": MessageLookupByLibrary.simpleMessage(
            "Read-only authorization cannot use your assets, please rest assured"),
        "authSlogan": MessageLookupByLibrary.simpleMessage(
            "Mixin Wallet is a user-friendly, secure and powerful multi-chain digital wallet."),
        "authTips": MessageLookupByLibrary.simpleMessage(
            "An open source cryptocurrency wallet"),
        "authorize": MessageLookupByLibrary.simpleMessage("Sign in with Mixin"),
        "averageArrival": m3,
        "balance": MessageLookupByLibrary.simpleMessage("BALANCE"),
        "balanceOfBtc": m4,
        "buy": MessageLookupByLibrary.simpleMessage("Buy"),
        "buyDisclaimer": MessageLookupByLibrary.simpleMessage(
            "Services provided by https://sendwyre.com"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "chain": MessageLookupByLibrary.simpleMessage("Chain"),
        "coins": MessageLookupByLibrary.simpleMessage("Coins"),
        "collectiblesReadFailed":
            MessageLookupByLibrary.simpleMessage("Failed to read collectibles"),
        "collectionItemCount": m5,
        "comingSoon": MessageLookupByLibrary.simpleMessage("Coming soon"),
        "completed": MessageLookupByLibrary.simpleMessage("Completed"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "contact": MessageLookupByLibrary.simpleMessage("Contact"),
        "contactReadFailed":
            MessageLookupByLibrary.simpleMessage("Failed to read contact list"),
        "contactSearchHint":
            MessageLookupByLibrary.simpleMessage("Name, Mixin ID"),
        "continueText": MessageLookupByLibrary.simpleMessage("Continue"),
        "contract": MessageLookupByLibrary.simpleMessage("Asset Key"),
        "copyLink": MessageLookupByLibrary.simpleMessage("Copy link"),
        "copyToClipboard":
            MessageLookupByLibrary.simpleMessage("Copied to Clipboard"),
        "createPin": MessageLookupByLibrary.simpleMessage("Create PIN"),
        "createPinTips": MessageLookupByLibrary.simpleMessage(
            "Please create a PIN to protect your assets"),
        "customDateRange":
            MessageLookupByLibrary.simpleMessage("Custom date range"),
        "date": MessageLookupByLibrary.simpleMessage("Date"),
        "dateRange": MessageLookupByLibrary.simpleMessage("date range"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteAddressByPinTip":
            MessageLookupByLibrary.simpleMessage("Enter PIN to delete address"),
        "deleteWithdrawalAddress": m6,
        "deposit": MessageLookupByLibrary.simpleMessage("Deposit"),
        "depositConfirmation": m7,
        "depositMemoNotice": MessageLookupByLibrary.simpleMessage(
            "Memo is required, or you will lose your coins."),
        "depositNotice": m8,
        "depositReserve": m9,
        "depositTip": m10,
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
        "download": MessageLookupByLibrary.simpleMessage("Download"),
        "downloadMixinMessengerHint":
            MessageLookupByLibrary.simpleMessage("Don’t have Mixin Messenger?"),
        "emptyAmount": MessageLookupByLibrary.simpleMessage("Empty amount"),
        "emptyLabelOrAddress":
            MessageLookupByLibrary.simpleMessage("Empty address or label"),
        "eosContractAddress":
            MessageLookupByLibrary.simpleMessage("EOS contract address"),
        "errorAuthentication": MessageLookupByLibrary.simpleMessage(
            "ERROR 401: Sign in to continue"),
        "errorBadData": MessageLookupByLibrary.simpleMessage(
            "ERROR 10002: The request data has invalid field"),
        "errorBlockchain": MessageLookupByLibrary.simpleMessage(
            "ERROR 30100: Blockchain not in sync, please try again later."),
        "errorConnectionTimeout": MessageLookupByLibrary.simpleMessage(
            "Network connection timeout, please try again"),
        "errorFullGroup": MessageLookupByLibrary.simpleMessage(
            "ERROR 20116: The group chat is full."),
        "errorInsufficientBalance": MessageLookupByLibrary.simpleMessage(
            "ERROR 20117: Insufficient balance"),
        "errorInsufficientTransactionFeeWithAmount": m11,
        "errorInvalidAddress": m12,
        "errorInvalidAddressPlain": MessageLookupByLibrary.simpleMessage(
            "ERROR 30102: Invalid address format."),
        "errorInvalidCodeTooFrequent": MessageLookupByLibrary.simpleMessage(
            "ERROR 20129: Send verification code too frequent, please try again later."),
        "errorInvalidEmergencyContact": MessageLookupByLibrary.simpleMessage(
            "ERROR 20130: Invalid emergency contact"),
        "errorInvalidPinFormat": MessageLookupByLibrary.simpleMessage(
            "ERROR 20118: Invalid PIN format."),
        "errorNetworkTaskFailed": MessageLookupByLibrary.simpleMessage(
            "Network connection failed. Check or switch your network and try again"),
        "errorNoCamera": MessageLookupByLibrary.simpleMessage("No camera"),
        "errorNoPinToken": MessageLookupByLibrary.simpleMessage(
            "No token, Please log in again and try this feature again."),
        "errorNotFound":
            MessageLookupByLibrary.simpleMessage("ERROR 404: Not found"),
        "errorNotSupportedAudioFormat": MessageLookupByLibrary.simpleMessage(
            "Not supported audio format, please open by other app."),
        "errorNumberReachedLimit": MessageLookupByLibrary.simpleMessage(
            "ERROR 20132: The number has reached the limit."),
        "errorOldVersion": m13,
        "errorOpenLocation":
            MessageLookupByLibrary.simpleMessage("Can\'t find an map app"),
        "errorPermission": MessageLookupByLibrary.simpleMessage(
            "Please open the necessary permissions"),
        "errorPhoneInvalidFormat": MessageLookupByLibrary.simpleMessage(
            "ERROR 20110: Invalid phone number"),
        "errorPhoneSmsDelivery": MessageLookupByLibrary.simpleMessage(
            "ERROR 10003: Failed to deliver SMS"),
        "errorPhoneVerificationCodeExpired":
            MessageLookupByLibrary.simpleMessage(
                "ERROR 20114: Expired phone verification code"),
        "errorPhoneVerificationCodeInvalid":
            MessageLookupByLibrary.simpleMessage(
                "ERROR 20113: Invalid phone verification code"),
        "errorPinCheckTooManyRequest": MessageLookupByLibrary.simpleMessage(
            "You have tried more than 5 times, please wait at least 24 hours to try again."),
        "errorPinIncorrect":
            MessageLookupByLibrary.simpleMessage("ERROR 20119: PIN incorrect"),
        "errorPinIncorrectWithTimes": m14,
        "errorRecaptchaIsInvalid": MessageLookupByLibrary.simpleMessage(
            "ERROR 10004: Recaptcha is invalid"),
        "errorServer5xxCode": m15,
        "errorTooManyRequest": MessageLookupByLibrary.simpleMessage(
            "ERROR 429: Rate limit exceeded"),
        "errorTooManyStickers": MessageLookupByLibrary.simpleMessage(
            "ERROR 20126: Too many stickers"),
        "errorTooSmallTransferAmount": MessageLookupByLibrary.simpleMessage(
            "ERROR 20120: Transfer amount is too small"),
        "errorTooSmallWithdrawAmount": MessageLookupByLibrary.simpleMessage(
            "ERROR 20127: Withdraw amount too small"),
        "errorTranscriptForward": MessageLookupByLibrary.simpleMessage(
            "Please forward all attachments after they have been downloaded"),
        "errorUnableToOpenMedia": MessageLookupByLibrary.simpleMessage(
            "Can\'t find an app able to open this media."),
        "errorUnknownWithCode": m16,
        "errorUnknownWithMessage": m17,
        "errorUsedPhone": MessageLookupByLibrary.simpleMessage(
            "ERROR 20122: This phone number is already associated with another account."),
        "errorUserInvalidFormat":
            MessageLookupByLibrary.simpleMessage("Invalid user id"),
        "errorWithdrawalMemoFormatIncorrect":
            MessageLookupByLibrary.simpleMessage(
                "ERROR 20131: Withdrawal memo format incorrect."),
        "export": MessageLookupByLibrary.simpleMessage("Export"),
        "exportTransactionsData":
            MessageLookupByLibrary.simpleMessage("Export transactions data"),
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
        "lastNinetyDays": MessageLookupByLibrary.simpleMessage("Last 90 days"),
        "lastSevenDays": MessageLookupByLibrary.simpleMessage("Last 7 days"),
        "lastThirtyDays": MessageLookupByLibrary.simpleMessage("Last 30 days"),
        "linkGenerated": MessageLookupByLibrary.simpleMessage("Link generated"),
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
        "nfts": MessageLookupByLibrary.simpleMessage("NFTs"),
        "noAsset": MessageLookupByLibrary.simpleMessage("NO ASSET"),
        "noCollectiblesFound":
            MessageLookupByLibrary.simpleMessage("No collectibles found"),
        "noCollectionFound":
            MessageLookupByLibrary.simpleMessage("No collection found"),
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
        "pendingConfirmations": m18,
        "raw": MessageLookupByLibrary.simpleMessage("Raw"),
        "rawTransaction":
            MessageLookupByLibrary.simpleMessage("Raw Transaction"),
        "reauthorize": MessageLookupByLibrary.simpleMessage("Reauthorize"),
        "rebate": MessageLookupByLibrary.simpleMessage("Rebate"),
        "receive": MessageLookupByLibrary.simpleMessage("Receive"),
        "received": MessageLookupByLibrary.simpleMessage("Received"),
        "receivers": MessageLookupByLibrary.simpleMessage("Receivers"),
        "recentSearches":
            MessageLookupByLibrary.simpleMessage("Recent searches"),
        "refund": MessageLookupByLibrary.simpleMessage("Refund"),
        "removeAuthorize": MessageLookupByLibrary.simpleMessage("Deauthorize"),
        "requestPayment":
            MessageLookupByLibrary.simpleMessage("Request payment"),
        "requestPaymentAmount": m19,
        "requestPaymentGeneratedTips": MessageLookupByLibrary.simpleMessage(
            "A request payment link has been generated, please send it to the specified contact."),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "search": MessageLookupByLibrary.simpleMessage("Search"),
        "selectContactOrAddress":
            MessageLookupByLibrary.simpleMessage("Choose a address or contact"),
        "send": MessageLookupByLibrary.simpleMessage("Send"),
        "sendLink": MessageLookupByLibrary.simpleMessage("Send link"),
        "sendTo": m20,
        "sendToContact":
            MessageLookupByLibrary.simpleMessage("Send to contact"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "show": MessageLookupByLibrary.simpleMessage("Show"),
        "signTransaction":
            MessageLookupByLibrary.simpleMessage("Sign Transaction"),
        "signers": MessageLookupByLibrary.simpleMessage("Signers"),
        "slippage": MessageLookupByLibrary.simpleMessage("Slippage"),
        "slippageOver": m21,
        "snapshotHash": MessageLookupByLibrary.simpleMessage("Snapshot hash"),
        "sortBy": MessageLookupByLibrary.simpleMessage("SORT BY"),
        "state": MessageLookupByLibrary.simpleMessage("State"),
        "submitTransaction":
            MessageLookupByLibrary.simpleMessage("Submit Transaction"),
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
        "walletTransactionCurrentValue": m22,
        "walletTransactionThatTimeNoValue":
            MessageLookupByLibrary.simpleMessage("value then N/A"),
        "walletTransactionThatTimeValue": m23,
        "wireServiceTip": MessageLookupByLibrary.simpleMessage(
            "This service is provided by Wyre. We act as a conduit only and do not charge additional fees."),
        "withdrawal": MessageLookupByLibrary.simpleMessage("Withdrawal"),
        "withdrawalMemoHint":
            MessageLookupByLibrary.simpleMessage("Memo (Optional)"),
        "withdrawalTo": m24,
        "withdrawalWithPin":
            MessageLookupByLibrary.simpleMessage("Withdrawal with PIN"),
        "wyreServiceStatement":
            MessageLookupByLibrary.simpleMessage("Service statement")
      };
}
