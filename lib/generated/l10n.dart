// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class L10n {
  L10n();

  static L10n? _current;

  static L10n get current {
    assert(_current != null,
        'No instance of L10n was loaded. Try to initialize the L10n delegate before accessing L10n.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<L10n> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = L10n();
      L10n._current = instance;

      return instance;
    });
  }

  static L10n of(BuildContext context) {
    final instance = L10n.maybeOf(context);
    assert(instance != null,
        'No instance of L10n present in the widget tree. Did you add L10n.delegate in localizationsDelegates?');
    return instance!;
  }

  static L10n? maybeOf(BuildContext context) {
    return Localizations.of<L10n>(context, L10n);
  }

  /// `Total Balance`
  String get totalBalance {
    return Intl.message(
      'Total Balance',
      name: 'totalBalance',
      desc: '',
      args: [],
    );
  }

  /// `{value} BTC`
  String balanceOfBtc(Object value) {
    return Intl.message(
      '$value BTC',
      name: 'balanceOfBtc',
      desc: '',
      args: [value],
    );
  }

  /// `N/A`
  String get none {
    return Intl.message(
      'N/A',
      name: 'none',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get send {
    return Intl.message(
      'Send',
      name: 'send',
      desc: '',
      args: [],
    );
  }

  /// `Receive`
  String get receive {
    return Intl.message(
      'Receive',
      name: 'receive',
      desc: '',
      args: [],
    );
  }

  /// `Assets`
  String get assets {
    return Intl.message(
      'Assets',
      name: 'assets',
      desc: '',
      args: [],
    );
  }

  /// `Transactions`
  String get transactions {
    return Intl.message(
      'Transactions',
      name: 'transactions',
      desc: '',
      args: [],
    );
  }

  /// `Deposit`
  String get deposit {
    return Intl.message(
      'Deposit',
      name: 'deposit',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message(
      'Address',
      name: 'address',
      desc: '',
      args: [],
    );
  }

  /// `Memo`
  String get memo {
    return Intl.message(
      'Memo',
      name: 'memo',
      desc: '',
      args: [],
    );
  }

  /// `Notice`
  String get notice {
    return Intl.message(
      'Notice',
      name: 'notice',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Both a Memo and an Address are required to successfully deposit your {value} to your account.`
  String depositNotice(Object value) {
    return Intl.message(
      'Both a Memo and an Address are required to successfully deposit your $value to your account.',
      name: 'depositNotice',
      desc: '',
      args: [value],
    );
  }

  /// `This address only supports {value}.`
  String depositTip(Object value) {
    return Intl.message(
      'This address only supports $value.',
      name: 'depositTip',
      desc: '',
      args: [value],
    );
  }

  /// `This address only supports BTC.`
  String get depositTipBtc {
    return Intl.message(
      'This address only supports BTC.',
      name: 'depositTipBtc',
      desc: '',
      args: [],
    );
  }

  /// `This address supports all ERC-20 tokens.`
  String get depositTipEth {
    return Intl.message(
      'This address supports all ERC-20 tokens.',
      name: 'depositTipEth',
      desc: '',
      args: [],
    );
  }

  /// `This address supports all base on EOS tokens.`
  String get depositTipEos {
    return Intl.message(
      'This address supports all base on EOS tokens.',
      name: 'depositTipEos',
      desc: '',
      args: [],
    );
  }

  /// `This address supports all TRC-10 and TRC-20 tokens, such as TRX, USDT-TRON, etc.`
  String get depositTipTron {
    return Intl.message(
      'This address supports all TRC-10 and TRC-20 tokens, such as TRX, USDT-TRON, etc.',
      name: 'depositTipTron',
      desc: '',
      args: [],
    );
  }

  /// `Do not support smart contract transfers.`
  String get depositTipNotSupportContract {
    return Intl.message(
      'Do not support smart contract transfers.',
      name: 'depositTipNotSupportContract',
      desc: '',
      args: [],
    );
  }

  /// `Deposit will arrive after at least {value} block confirmations`
  String depositConfirmation(Object value) {
    return Intl.message(
      'Deposit will arrive after at least $value block confirmations',
      name: 'depositConfirmation',
      desc: '',
      args: [value],
    );
  }

  /// `Deposit at least {value} for the first time`
  String depositReserve(Object value) {
    return Intl.message(
      'Deposit at least $value for the first time',
      name: 'depositReserve',
      desc: '',
      args: [value],
    );
  }

  /// `Average arrival time:{value}`
  String averageArrival(Object value) {
    return Intl.message(
      'Average arrival time:$value',
      name: 'averageArrival',
      desc: '',
      args: [value],
    );
  }

  /// `NO TRANSACTION`
  String get noTransaction {
    return Intl.message(
      'NO TRANSACTION',
      name: 'noTransaction',
      desc: '',
      args: [],
    );
  }

  /// `Withdrawal`
  String get withdrawal {
    return Intl.message(
      'Withdrawal',
      name: 'withdrawal',
      desc: '',
      args: [],
    );
  }

  /// `Fee`
  String get fee {
    return Intl.message(
      'Fee',
      name: 'fee',
      desc: '',
      args: [],
    );
  }

  /// `Rebate`
  String get rebate {
    return Intl.message(
      'Rebate',
      name: 'rebate',
      desc: '',
      args: [],
    );
  }

  /// `Transfer`
  String get transfer {
    return Intl.message(
      'Transfer',
      name: 'transfer',
      desc: '',
      args: [],
    );
  }

  /// `Depositing`
  String get depositing {
    return Intl.message(
      'Depositing',
      name: 'depositing',
      desc: '',
      args: [],
    );
  }

  /// `Raw`
  String get raw {
    return Intl.message(
      'Raw',
      name: 'raw',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Id`
  String get transactionsId {
    return Intl.message(
      'Transaction Id',
      name: 'transactionsId',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Type`
  String get transactionsType {
    return Intl.message(
      'Transaction Type',
      name: 'transactionsType',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get transactionsStatus {
    return Intl.message(
      'Status',
      name: 'transactionsStatus',
      desc: '',
      args: [],
    );
  }

  /// `From`
  String get from {
    return Intl.message(
      'From',
      name: 'from',
      desc: '',
      args: [],
    );
  }

  /// `To`
  String get to {
    return Intl.message(
      'To',
      name: 'to',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get time {
    return Intl.message(
      'Time',
      name: 'time',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: '',
      args: [],
    );
  }

  /// `Trace`
  String get trace {
    return Intl.message(
      'Trace',
      name: 'trace',
      desc: '',
      args: [],
    );
  }

  /// `Asset Type`
  String get assetType {
    return Intl.message(
      'Asset Type',
      name: 'assetType',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `value now {value}`
  String walletTransactionCurrentValue(Object value) {
    return Intl.message(
      'value now $value',
      name: 'walletTransactionCurrentValue',
      desc: '',
      args: [value],
    );
  }

  /// `value then {value}`
  String walletTransactionThatTimeValue(Object value) {
    return Intl.message(
      'value then $value',
      name: 'walletTransactionThatTimeValue',
      desc: '',
      args: [value],
    );
  }

  /// `value then N/A`
  String get walletTransactionThatTimeNoValue {
    return Intl.message(
      'value then N/A',
      name: 'walletTransactionThatTimeNoValue',
      desc: '',
      args: [],
    );
  }

  /// `Symbol`
  String get symbol {
    return Intl.message(
      'Symbol',
      name: 'symbol',
      desc: '',
      args: [],
    );
  }

  /// `Chain`
  String get chain {
    return Intl.message(
      'Chain',
      name: 'chain',
      desc: '',
      args: [],
    );
  }

  /// `Asset Key`
  String get contract {
    return Intl.message(
      'Asset Key',
      name: 'contract',
      desc: '',
      args: [],
    );
  }

  /// `Asset key is NOT a deposit address!`
  String get transactionsAssetKeyWarning {
    return Intl.message(
      'Asset key is NOT a deposit address!',
      name: 'transactionsAssetKeyWarning',
      desc: '',
      args: [],
    );
  }

  /// `Label, Address`
  String get addressSearchHint {
    return Intl.message(
      'Label, Address',
      name: 'addressSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `Add address`
  String get addAddress {
    return Intl.message(
      'Add address',
      name: 'addAddress',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get filterTitle {
    return Intl.message(
      'Filter',
      name: 'filterTitle',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get filterApply {
    return Intl.message(
      'Apply',
      name: 'filterApply',
      desc: '',
      args: [],
    );
  }

  /// `FILTER BY`
  String get filterBy {
    return Intl.message(
      'FILTER BY',
      name: 'filterBy',
      desc: '',
      args: [],
    );
  }

  /// `SORT BY`
  String get sortBy {
    return Intl.message(
      'SORT BY',
      name: 'sortBy',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get amount {
    return Intl.message(
      'Amount',
      name: 'amount',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get filterAll {
    return Intl.message(
      'All',
      name: 'filterAll',
      desc: '',
      args: [],
    );
  }

  /// `Miner Fee`
  String get minerFee {
    return Intl.message(
      'Miner Fee',
      name: 'minerFee',
      desc: '',
      args: [],
    );
  }

  /// `{value}/{value2} confirmations`
  String pendingConfirmations(Object value, Object value2) {
    return Intl.message(
      '$value/$value2 confirmations',
      name: 'pendingConfirmations',
      desc: '',
      args: [value, value2],
    );
  }

  /// `Label (e.g. exchanges, wallets, etc.)`
  String get addAddressLabelHint {
    return Intl.message(
      'Label (e.g. exchanges, wallets, etc.)',
      name: 'addAddressLabelHint',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `All Transactions`
  String get allTransactions {
    return Intl.message(
      'All Transactions',
      name: 'allTransactions',
      desc: '',
      args: [],
    );
  }

  /// `Trending`
  String get assetTrending {
    return Intl.message(
      'Trending',
      name: 'assetTrending',
      desc: '',
      args: [],
    );
  }

  /// `Recent searches`
  String get recentSearches {
    return Intl.message(
      'Recent searches',
      name: 'recentSearches',
      desc: '',
      args: [],
    );
  }

  /// `Copied to Clipboard`
  String get copyToClipboard {
    return Intl.message(
      'Copied to Clipboard',
      name: 'copyToClipboard',
      desc: '',
      args: [],
    );
  }

  /// `Destination Tag or ID Number or notes. If not, you can set it `
  String get addAddressMemo {
    return Intl.message(
      'Destination Tag or ID Number or notes. If not, you can set it ',
      name: 'addAddressMemo',
      desc: '',
      args: [],
    );
  }

  /// `If you are required to fill in Destination Tag or ID Number or notes, you can `
  String get addAddressNoMemo {
    return Intl.message(
      'If you are required to fill in Destination Tag or ID Number or notes, you can ',
      name: 'addAddressNoMemo',
      desc: '',
      args: [],
    );
  }

  /// `No Tag`
  String get addAddressTagAction {
    return Intl.message(
      'No Tag',
      name: 'addAddressTagAction',
      desc: '',
      args: [],
    );
  }

  /// `Add Tag`
  String get addAddressNoTagAction {
    return Intl.message(
      'Add Tag',
      name: 'addAddressNoTagAction',
      desc: '',
      args: [],
    );
  }

  /// `No Memo`
  String get addAddressMemoAction {
    return Intl.message(
      'No Memo',
      name: 'addAddressMemoAction',
      desc: '',
      args: [],
    );
  }

  /// `Add Memo`
  String get addAddressNoMemoAction {
    return Intl.message(
      'Add Memo',
      name: 'addAddressNoMemoAction',
      desc: '',
      args: [],
    );
  }

  /// `Mixin does not support withdrawal to the`
  String get addAddressNotSupportTip {
    return Intl.message(
      'Mixin does not support withdrawal to the',
      name: 'addAddressNotSupportTip',
      desc: '',
      args: [],
    );
  }

  /// `EOS contract address`
  String get eosContractAddress {
    return Intl.message(
      'EOS contract address',
      name: 'eosContractAddress',
      desc: '',
      args: [],
    );
  }

  /// `Memo`
  String get memoHint {
    return Intl.message(
      'Memo',
      name: 'memoHint',
      desc: '',
      args: [],
    );
  }

  /// `Tag`
  String get tagHint {
    return Intl.message(
      'Tag',
      name: 'tagHint',
      desc: '',
      args: [],
    );
  }

  /// `Network fee:`
  String get networkFee {
    return Intl.message(
      'Network fee:',
      name: 'networkFee',
      desc: '',
      args: [],
    );
  }

  /// `Minimum withdrawal:`
  String get minimumWithdrawal {
    return Intl.message(
      'Minimum withdrawal:',
      name: 'minimumWithdrawal',
      desc: '',
      args: [],
    );
  }

  /// `Minimum reserve:`
  String get minimumReserve {
    return Intl.message(
      'Minimum reserve:',
      name: 'minimumReserve',
      desc: '',
      args: [],
    );
  }

  /// `Mixin Wallet`
  String get mixinWallet {
    return Intl.message(
      'Mixin Wallet',
      name: 'mixinWallet',
      desc: '',
      args: [],
    );
  }

  /// `Mixin Wallet is a user-friendly, secure and powerful multi-chain digital wallet.`
  String get authSlogan {
    return Intl.message(
      'Mixin Wallet is a user-friendly, secure and powerful multi-chain digital wallet.',
      name: 'authSlogan',
      desc: '',
      args: [],
    );
  }

  /// `Read-only authorization cannot use your assets, please rest assured`
  String get authHint {
    return Intl.message(
      'Read-only authorization cannot use your assets, please rest assured',
      name: 'authHint',
      desc: '',
      args: [],
    );
  }

  /// `Sign in with Mixin`
  String get authorize {
    return Intl.message(
      'Sign in with Mixin',
      name: 'authorize',
      desc: '',
      args: [],
    );
  }

  /// `An open source cryptocurrency wallet`
  String get authTips {
    return Intl.message(
      'An open source cryptocurrency wallet',
      name: 'authTips',
      desc: '',
      args: [],
    );
  }

  /// `Hidden Assets`
  String get hiddenAssets {
    return Intl.message(
      'Hidden Assets',
      name: 'hiddenAssets',
      desc: '',
      args: [],
    );
  }

  /// `Hide small assets`
  String get hideSmallAssets {
    return Intl.message(
      'Hide small assets',
      name: 'hideSmallAssets',
      desc: '',
      args: [],
    );
  }

  /// `Hide`
  String get hide {
    return Intl.message(
      'Hide',
      name: 'hide',
      desc: '',
      args: [],
    );
  }

  /// `Show`
  String get show {
    return Intl.message(
      'Show',
      name: 'show',
      desc: '',
      args: [],
    );
  }

  /// `{value} has been hidden`
  String alreadyHidden(Object value) {
    return Intl.message(
      '$value has been hidden',
      name: 'alreadyHidden',
      desc: '',
      args: [value],
    );
  }

  /// `{value} has been shown`
  String alreadyShown(Object value) {
    return Intl.message(
      '$value has been shown',
      name: 'alreadyShown',
      desc: '',
      args: [value],
    );
  }

  /// `UNDO`
  String get undo {
    return Intl.message(
      'UNDO',
      name: 'undo',
      desc: '',
      args: [],
    );
  }

  /// `Empty amount`
  String get emptyAmount {
    return Intl.message(
      'Empty amount',
      name: 'emptyAmount',
      desc: '',
      args: [],
    );
  }

  /// `No contact or address selected`
  String get noWithdrawalDestinationSelected {
    return Intl.message(
      'No contact or address selected',
      name: 'noWithdrawalDestinationSelected',
      desc: '',
      args: [],
    );
  }

  /// `Empty address or label`
  String get emptyLabelOrAddress {
    return Intl.message(
      'Empty address or label',
      name: 'emptyLabelOrAddress',
      desc: '',
      args: [],
    );
  }

  /// `Contact`
  String get contact {
    return Intl.message(
      'Contact',
      name: 'contact',
      desc: '',
      args: [],
    );
  }

  /// `Send to contact`
  String get sendToContact {
    return Intl.message(
      'Send to contact',
      name: 'sendToContact',
      desc: '',
      args: [],
    );
  }

  /// `Name, Mixin ID`
  String get contactSearchHint {
    return Intl.message(
      'Name, Mixin ID',
      name: 'contactSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `Memo (Optional)`
  String get withdrawalMemoHint {
    return Intl.message(
      'Memo (Optional)',
      name: 'withdrawalMemoHint',
      desc: '',
      args: [],
    );
  }

  /// `Waiting action done...`
  String get waitingActionDone {
    return Intl.message(
      'Waiting action done...',
      name: 'waitingActionDone',
      desc: '',
      args: [],
    );
  }

  /// `Failed to read contact list`
  String get contactReadFailed {
    return Intl.message(
      'Failed to read contact list',
      name: 'contactReadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Reauthorize`
  String get reauthorize {
    return Intl.message(
      'Reauthorize',
      name: 'reauthorize',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Hash`
  String get transactionHash {
    return Intl.message(
      'Transaction Hash',
      name: 'transactionHash',
      desc: '',
      args: [],
    );
  }

  /// `Buy`
  String get buy {
    return Intl.message(
      'Buy',
      name: 'buy',
      desc: '',
      args: [],
    );
  }

  /// `Swap`
  String get swap {
    return Intl.message(
      'Swap',
      name: 'swap',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get other {
    return Intl.message(
      'Other',
      name: 'other',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `NO ASSET`
  String get noAsset {
    return Intl.message(
      'NO ASSET',
      name: 'noAsset',
      desc: '',
      args: [],
    );
  }

  /// `Network type`
  String get networkType {
    return Intl.message(
      'Network type',
      name: 'networkType',
      desc: '',
      args: [],
    );
  }

  /// `Coming soon`
  String get comingSoon {
    return Intl.message(
      'Coming soon',
      name: 'comingSoon',
      desc: '',
      args: [],
    );
  }

  /// `Deauthorize`
  String get removeAuthorize {
    return Intl.message(
      'Deauthorize',
      name: 'removeAuthorize',
      desc: '',
      args: [],
    );
  }

  /// `NO RESULT`
  String get noResult {
    return Intl.message(
      'NO RESULT',
      name: 'noResult',
      desc: '',
      args: [],
    );
  }

  /// `Transaction`
  String get transaction {
    return Intl.message(
      'Transaction',
      name: 'transaction',
      desc: '',
      args: [],
    );
  }

  /// `Service statement`
  String get wyreServiceStatement {
    return Intl.message(
      'Service statement',
      name: 'wyreServiceStatement',
      desc: '',
      args: [],
    );
  }

  /// `This service is provided by Wyre. We act as a conduit only and do not charge additional fees.`
  String get wireServiceTip {
    return Intl.message(
      'This service is provided by Wyre. We act as a conduit only and do not charge additional fees.',
      name: 'wireServiceTip',
      desc: '',
      args: [],
    );
  }

  /// `Don't show again`
  String get dontShowAgain {
    return Intl.message(
      'Don\'t show again',
      name: 'dontShowAgain',
      desc: '',
      args: [],
    );
  }

  /// `Got it`
  String get gotIt {
    return Intl.message(
      'Got it',
      name: 'gotIt',
      desc: '',
      args: [],
    );
  }

  /// `Transaction fee:`
  String get transactionFee {
    return Intl.message(
      'Transaction fee:',
      name: 'transactionFee',
      desc: '',
      args: [],
    );
  }

  /// `Charged by third party service provider. US users are charged 2.9% + 30c of the transaction amount with a minimum charge of $5. International users are charged 3.9% + 30c of the transaction amount with a minimum charge of $5.`
  String get transactionFeeTip {
    return Intl.message(
      'Charged by third party service provider. US users are charged 2.9% + 30c of the transaction amount with a minimum charge of \$5. International users are charged 3.9% + 30c of the transaction amount with a minimum charge of \$5.',
      name: 'transactionFeeTip',
      desc: '',
      args: [],
    );
  }

  /// `Charged by third party service provider. Paid directly to Ethereum miners to ensure transactions are completed on Ethereum. Network fees vary based on immediate market conditions.`
  String get networkFeeTip {
    return Intl.message(
      'Charged by third party service provider. Paid directly to Ethereum miners to ensure transactions are completed on Ethereum. Network fees vary based on immediate market conditions.',
      name: 'networkFeeTip',
      desc: '',
      args: [],
    );
  }

  /// `Pay`
  String get pay {
    return Intl.message(
      'Pay',
      name: 'pay',
      desc: '',
      args: [],
    );
  }

  /// `BALANCE`
  String get balance {
    return Intl.message(
      'BALANCE',
      name: 'balance',
      desc: '',
      args: [],
    );
  }

  /// `No camera`
  String get errorNoCamera {
    return Intl.message(
      'No camera',
      name: 'errorNoCamera',
      desc: '',
      args: [],
    );
  }

  /// `Swap type`
  String get swapType {
    return Intl.message(
      'Swap type',
      name: 'swapType',
      desc: '',
      args: [],
    );
  }

  /// `Transfer details`
  String get transferDetail {
    return Intl.message(
      'Transfer details',
      name: 'transferDetail',
      desc: '',
      args: [],
    );
  }

  /// `Transaction phase`
  String get transactionPhase {
    return Intl.message(
      'Transaction phase',
      name: 'transactionPhase',
      desc: '',
      args: [],
    );
  }

  /// `Checking`
  String get transactionChecking {
    return Intl.message(
      'Checking',
      name: 'transactionChecking',
      desc: '',
      args: [],
    );
  }

  /// `Trading`
  String get transactionTrading {
    return Intl.message(
      'Trading',
      name: 'transactionTrading',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get transactionDone {
    return Intl.message(
      'Done',
      name: 'transactionDone',
      desc: '',
      args: [],
    );
  }

  /// `Received`
  String get received {
    return Intl.message(
      'Received',
      name: 'received',
      desc: '',
      args: [],
    );
  }

  /// `Refund`
  String get refund {
    return Intl.message(
      'Refund',
      name: 'refund',
      desc: '',
      args: [],
    );
  }

  /// `Have you paid in Mixin?`
  String get paidInMixin {
    return Intl.message(
      'Have you paid in Mixin?',
      name: 'paidInMixin',
      desc: '',
      args: [],
    );
  }

  /// `If you have paid via Mixin, please be patient.`
  String get paidInMixinWarning {
    return Intl.message(
      'If you have paid via Mixin, please be patient.',
      name: 'paidInMixinWarning',
      desc: '',
      args: [],
    );
  }

  /// `Paid`
  String get paid {
    return Intl.message(
      'Paid',
      name: 'paid',
      desc: '',
      args: [],
    );
  }

  /// `Unpaid`
  String get unpaid {
    return Intl.message(
      'Unpaid',
      name: 'unpaid',
      desc: '',
      args: [],
    );
  }

  /// `Incomplete`
  String get incomplete {
    return Intl.message(
      'Incomplete',
      name: 'incomplete',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get completed {
    return Intl.message(
      'Completed',
      name: 'completed',
      desc: '',
      args: [],
    );
  }

  /// `Slippage`
  String get slippage {
    return Intl.message(
      'Slippage',
      name: 'slippage',
      desc: '',
      args: [],
    );
  }

  /// `Swap with slippage greater than {value} is not currently supported`
  String slippageOver(Object value) {
    return Intl.message(
      'Swap with slippage greater than $value is not currently supported',
      name: 'slippageOver',
      desc: '',
      args: [value],
    );
  }

  /// `Go pay`
  String get goPay {
    return Intl.message(
      'Go pay',
      name: 'goPay',
      desc: '',
      args: [],
    );
  }

  /// `Services provided by MixSwap`
  String get swapDisclaimer {
    return Intl.message(
      'Services provided by MixSwap',
      name: 'swapDisclaimer',
      desc: '',
      args: [],
    );
  }

  /// `Services provided by https://sendwyre.com`
  String get buyDisclaimer {
    return Intl.message(
      'Services provided by https://sendwyre.com',
      name: 'buyDisclaimer',
      desc: '',
      args: [],
    );
  }

  /// `Does not meet minimum transaction size`
  String get notMeetMinimumAmount {
    return Intl.message(
      'Does not meet minimum transaction size',
      name: 'notMeetMinimumAmount',
      desc: '',
      args: [],
    );
  }

  /// `Choose a address or contact`
  String get selectContactOrAddress {
    return Intl.message(
      'Choose a address or contact',
      name: 'selectContactOrAddress',
      desc: '',
      args: [],
    );
  }

  /// `Memo is required, or you will lose your coins.`
  String get depositMemoNotice {
    return Intl.message(
      'Memo is required, or you will lose your coins.',
      name: 'depositMemoNotice',
      desc: '',
      args: [],
    );
  }

  /// `Coins`
  String get coins {
    return Intl.message(
      'Coins',
      name: 'coins',
      desc: '',
      args: [],
    );
  }

  /// `NFTs`
  String get nfts {
    return Intl.message(
      'NFTs',
      name: 'nfts',
      desc: '',
      args: [],
    );
  }

  /// `No collectibles found`
  String get noCollectiblesFound {
    return Intl.message(
      'No collectibles found',
      name: 'noCollectiblesFound',
      desc: '',
      args: [],
    );
  }

  /// `No collection found`
  String get noCollectionFound {
    return Intl.message(
      'No collection found',
      name: 'noCollectionFound',
      desc: '',
      args: [],
    );
  }

  /// `{count} items`
  String collectionItemCount(Object count) {
    return Intl.message(
      '$count items',
      name: 'collectionItemCount',
      desc: '',
      args: [count],
    );
  }

  /// `Failed to read collectibles`
  String get collectiblesReadFailed {
    return Intl.message(
      'Failed to read collectibles',
      name: 'collectiblesReadFailed',
      desc: '',
      args: [],
    );
  }

  /// `Request payment`
  String get requestPayment {
    return Intl.message(
      'Request payment',
      name: 'requestPayment',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continueText {
    return Intl.message(
      'Continue',
      name: 'continueText',
      desc: '',
      args: [],
    );
  }

  /// `Send link`
  String get sendLink {
    return Intl.message(
      'Send link',
      name: 'sendLink',
      desc: '',
      args: [],
    );
  }

  /// `Copy link`
  String get copyLink {
    return Intl.message(
      'Copy link',
      name: 'copyLink',
      desc: '',
      args: [],
    );
  }

  /// `A request payment link has been generated, please send it to the specified contact.`
  String get requestPaymentGeneratedTips {
    return Intl.message(
      'A request payment link has been generated, please send it to the specified contact.',
      name: 'requestPaymentGeneratedTips',
      desc: '',
      args: [],
    );
  }

  /// `Request payment amount: {value}`
  String requestPaymentAmount(Object value) {
    return Intl.message(
      'Request payment amount: $value',
      name: 'requestPaymentAmount',
      desc: '',
      args: [value],
    );
  }

  /// `Link generated`
  String get linkGenerated {
    return Intl.message(
      'Link generated',
      name: 'linkGenerated',
      desc: '',
      args: [],
    );
  }

  /// `State`
  String get state {
    return Intl.message(
      'State',
      name: 'state',
      desc: '',
      args: [],
    );
  }

  /// `Snapshot hash`
  String get snapshotHash {
    return Intl.message(
      'Snapshot hash',
      name: 'snapshotHash',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get download {
    return Intl.message(
      'Download',
      name: 'download',
      desc: '',
      args: [],
    );
  }

  /// `Don’t have Mixin Messenger?`
  String get downloadMixinMessengerHint {
    return Intl.message(
      'Don’t have Mixin Messenger?',
      name: 'downloadMixinMessengerHint',
      desc: '',
      args: [],
    );
  }

  /// `Asset address is being generated, please wait...`
  String get assetAddressGeneratingTip {
    return Intl.message(
      'Asset address is being generated, please wait...',
      name: 'assetAddressGeneratingTip',
      desc: '',
      args: [],
    );
  }

  /// `Create PIN`
  String get createPin {
    return Intl.message(
      'Create PIN',
      name: 'createPin',
      desc: '',
      args: [],
    );
  }

  /// `Please create a PIN to protect your assets`
  String get createPinTips {
    return Intl.message(
      'Please create a PIN to protect your assets',
      name: 'createPinTips',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Access denied`
  String get accessDenied {
    return Intl.message(
      'Access denied',
      name: 'accessDenied',
      desc: '',
      args: [],
    );
  }

  /// `ERROR 401: Sign in to continue`
  String get errorAuthentication {
    return Intl.message(
      'ERROR 401: Sign in to continue',
      name: 'errorAuthentication',
      desc: '',
      args: [],
    );
  }

  /// `ERROR 10002: The request data has invalid field`
  String get errorBadData {
    return Intl.message(
      'ERROR 10002: The request data has invalid field',
      name: 'errorBadData',
      desc: '',
      args: [],
    );
  }

  /// `ERROR 30100: Blockchain not in sync, please try again later.`
  String get errorBlockchain {
    return Intl.message(
      'ERROR 30100: Blockchain not in sync, please try again later.',
      name: 'errorBlockchain',
      desc: '',
      args: [],
    );
  }

  /// `Network connection timeout, please try again`
  String get errorConnectionTimeout {
    return Intl.message(
      'Network connection timeout, please try again',
      name: 'errorConnectionTimeout',
      desc: '',
      args: [],
    );
  }

  /// `ERROR 20116: The group chat is full.`
  String get errorFullGroup {
    return Intl.message(
      'ERROR 20116: The group chat is full.',
      name: 'errorFullGroup',
      desc: '',
      args: [],
    );
  }

  /// `ERROR 20117: Insufficient balance`
  String get errorInsufficientBalance {
    return Intl.message(
      'ERROR 20117: Insufficient balance',
      name: 'errorInsufficientBalance',
      desc: '',
      args: [],
    );
  }

  /// `ERROR 20124: Insufficient transaction fee. Please make sure your wallet has {arg0} as fee`
  String errorInsufficientTransactionFeeWithAmount(Object arg0) {
    return Intl.message(
      'ERROR 20124: Insufficient transaction fee. Please make sure your wallet has $arg0 as fee',
      name: 'errorInsufficientTransactionFeeWithAmount',
      desc: '',
      args: [arg0],
    );
  }

  /// `ERROR 30102: Invalid address format. Please enter the correct {arg0} {arg1} address!`
  String errorInvalidAddress(Object arg0, Object arg1) {
    return Intl.message(
      'ERROR 30102: Invalid address format. Please enter the correct $arg0 $arg1 address!',
      name: 'errorInvalidAddress',
      desc: '',
      args: [arg0, arg1],
    );
  }

  /// `ERROR 30102: Invalid address format.`
  String get errorInvalidAddressPlain {
    return Intl.message(
      'ERROR 30102: Invalid address format.',
      name: 'errorInvalidAddressPlain',
      desc: '',
      args: [],
    );
  }

  /// `ERROR 20129: Send verification code too frequent, please try again later.`
  String get errorInvalidCodeTooFrequent {
    return Intl.message(
      'ERROR 20129: Send verification code too frequent, please try again later.',
      name: 'errorInvalidCodeTooFrequent',
      desc: '',
      args: [],
    );
  }

  /// `ERROR 20130: Invalid emergency contact`
  String get errorInvalidEmergencyContact {
    return Intl.message(
      'ERROR 20130: Invalid emergency contact',
      name: 'errorInvalidEmergencyContact',
      desc: '',
      args: [],
    );
  }

  /// `ERROR 20118: Invalid PIN format.`
  String get errorInvalidPinFormat {
    return Intl.message(
      'ERROR 20118: Invalid PIN format.',
      name: 'errorInvalidPinFormat',
      desc: '',
      args: [],
    );
  }

  /// `Network connection failed. Check or switch your network and try again`
  String get errorNetworkTaskFailed {
    return Intl.message(
      'Network connection failed. Check or switch your network and try again',
      name: 'errorNetworkTaskFailed',
      desc: '',
      args: [],
    );
  }

  /// `No token, Please log in again and try this feature again.`
  String get errorNoPinToken {
    return Intl.message(
      'No token, Please log in again and try this feature again.',
      name: 'errorNoPinToken',
      desc: '',
      args: [],
    );
  }

  /// `ERROR 404: Not found`
  String get errorNotFound {
    return Intl.message(
      'ERROR 404: Not found',
      name: 'errorNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Not supported audio format, please open by other app.`
  String get errorNotSupportedAudioFormat {
    return Intl.message(
      'Not supported audio format, please open by other app.',
      name: 'errorNotSupportedAudioFormat',
      desc: '',
      args: [],
    );
  }

  /// `ERROR 20132: The number has reached the limit.`
  String get errorNumberReachedLimit {
    return Intl.message(
      'ERROR 20132: The number has reached the limit.',
      name: 'errorNumberReachedLimit',
      desc: '',
      args: [],
    );
  }

  /// `ERROR 10006: Please update Mixin({arg0}) to continue use the service.`
  String errorOldVersion(Object arg0) {
    return Intl.message(
      'ERROR 10006: Please update Mixin($arg0) to continue use the service.',
      name: 'errorOldVersion',
      desc: '',
      args: [arg0],
    );
  }

  /// `Can't find an map app`
  String get errorOpenLocation {
    return Intl.message(
      'Can\'t find an map app',
      name: 'errorOpenLocation',
      desc: '',
      args: [],
    );
  }

  /// `Please open the necessary permissions`
  String get errorPermission {
    return Intl.message(
      'Please open the necessary permissions',
      name: 'errorPermission',
      desc: '',
      args: [],
    );
  }

  /// `ERROR 20110: Invalid phone number`
  String get errorPhoneInvalidFormat {
    return Intl.message(
      'ERROR 20110: Invalid phone number',
      name: 'errorPhoneInvalidFormat',
      desc: '',
      args: [],
    );
  }

  /// `ERROR 10003: Failed to deliver SMS`
  String get errorPhoneSmsDelivery {
    return Intl.message(
      'ERROR 10003: Failed to deliver SMS',
      name: 'errorPhoneSmsDelivery',
      desc: '',
      args: [],
    );
  }

  /// `ERROR 20114: Expired phone verification code`
  String get errorPhoneVerificationCodeExpired {
    return Intl.message(
      'ERROR 20114: Expired phone verification code',
      name: 'errorPhoneVerificationCodeExpired',
      desc: '',
      args: [],
    );
  }

  /// `ERROR 20113: Invalid phone verification code`
  String get errorPhoneVerificationCodeInvalid {
    return Intl.message(
      'ERROR 20113: Invalid phone verification code',
      name: 'errorPhoneVerificationCodeInvalid',
      desc: '',
      args: [],
    );
  }

  /// `You have tried more than 5 times, please wait at least 24 hours to try again.`
  String get errorPinCheckTooManyRequest {
    return Intl.message(
      'You have tried more than 5 times, please wait at least 24 hours to try again.',
      name: 'errorPinCheckTooManyRequest',
      desc: '',
      args: [],
    );
  }

  /// `ERROR 20119: PIN incorrect`
  String get errorPinIncorrect {
    return Intl.message(
      'ERROR 20119: PIN incorrect',
      name: 'errorPinIncorrect',
      desc: '',
      args: [],
    );
  }

  /// `{count, plural, one{ERROR 20119: PIN incorrect. You still have {arg0} chance. Please wait for 24 hours to retry later.} other{ERROR 20119: PIN incorrect. You still have {arg0} chances. Please wait for 24 hours to retry later.}}`
  String errorPinIncorrectWithTimes(num count, Object arg0) {
    return Intl.plural(
      count,
      one:
          'ERROR 20119: PIN incorrect. You still have $arg0 chance. Please wait for 24 hours to retry later.',
      other:
          'ERROR 20119: PIN incorrect. You still have $arg0 chances. Please wait for 24 hours to retry later.',
      name: 'errorPinIncorrectWithTimes',
      desc: '',
      args: [count, arg0],
    );
  }

  /// `ERROR 10004: Recaptcha is invalid`
  String get errorRecaptchaIsInvalid {
    return Intl.message(
      'ERROR 10004: Recaptcha is invalid',
      name: 'errorRecaptchaIsInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Server is under maintenance: {arg0}`
  String errorServer5xxCode(Object arg0) {
    return Intl.message(
      'Server is under maintenance: $arg0',
      name: 'errorServer5xxCode',
      desc: '',
      args: [arg0],
    );
  }

  /// `ERROR 429: Rate limit exceeded`
  String get errorTooManyRequest {
    return Intl.message(
      'ERROR 429: Rate limit exceeded',
      name: 'errorTooManyRequest',
      desc: '',
      args: [],
    );
  }

  /// `ERROR 20126: Too many stickers`
  String get errorTooManyStickers {
    return Intl.message(
      'ERROR 20126: Too many stickers',
      name: 'errorTooManyStickers',
      desc: '',
      args: [],
    );
  }

  /// `ERROR 20120: Transfer amount is too small`
  String get errorTooSmallTransferAmount {
    return Intl.message(
      'ERROR 20120: Transfer amount is too small',
      name: 'errorTooSmallTransferAmount',
      desc: '',
      args: [],
    );
  }

  /// `ERROR 20127: Withdraw amount too small`
  String get errorTooSmallWithdrawAmount {
    return Intl.message(
      'ERROR 20127: Withdraw amount too small',
      name: 'errorTooSmallWithdrawAmount',
      desc: '',
      args: [],
    );
  }

  /// `Please forward all attachments after they have been downloaded`
  String get errorTranscriptForward {
    return Intl.message(
      'Please forward all attachments after they have been downloaded',
      name: 'errorTranscriptForward',
      desc: '',
      args: [],
    );
  }

  /// `Can't find an app able to open this media.`
  String get errorUnableToOpenMedia {
    return Intl.message(
      'Can\'t find an app able to open this media.',
      name: 'errorUnableToOpenMedia',
      desc: '',
      args: [],
    );
  }

  /// `ERROR: {arg0}`
  String errorUnknownWithCode(Object arg0) {
    return Intl.message(
      'ERROR: $arg0',
      name: 'errorUnknownWithCode',
      desc: '',
      args: [arg0],
    );
  }

  /// `ERROR: {arg0}`
  String errorUnknownWithMessage(Object arg0) {
    return Intl.message(
      'ERROR: $arg0',
      name: 'errorUnknownWithMessage',
      desc: '',
      args: [arg0],
    );
  }

  /// `ERROR 20122: This phone number is already associated with another account.`
  String get errorUsedPhone {
    return Intl.message(
      'ERROR 20122: This phone number is already associated with another account.',
      name: 'errorUsedPhone',
      desc: '',
      args: [],
    );
  }

  /// `Invalid user id`
  String get errorUserInvalidFormat {
    return Intl.message(
      'Invalid user id',
      name: 'errorUserInvalidFormat',
      desc: '',
      args: [],
    );
  }

  /// `ERROR 20131: Withdrawal memo format incorrect.`
  String get errorWithdrawalMemoFormatIncorrect {
    return Intl.message(
      'ERROR 20131: Withdrawal memo format incorrect.',
      name: 'errorWithdrawalMemoFormatIncorrect',
      desc: '',
      args: [],
    );
  }

  /// `Send to {value}`
  String sendTo(Object value) {
    return Intl.message(
      'Send to $value',
      name: 'sendTo',
      desc: '',
      args: [value],
    );
  }

  /// `Withdrawal with PIN`
  String get withdrawalWithPin {
    return Intl.message(
      'Withdrawal with PIN',
      name: 'withdrawalWithPin',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<L10n> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<L10n> load(Locale locale) => L10n.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
