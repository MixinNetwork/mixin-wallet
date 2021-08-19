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

  /// `≈ {value} BTC`
  String approxBalanceOfBtc(Object value) {
    return Intl.message(
      '≈ $value BTC',
      name: 'approxBalanceOfBtc',
      desc: '',
      args: [value],
    );
  }

  /// `≈ {value}`
  String approxOf(Object value) {
    return Intl.message(
      '≈ $value',
      name: 'approxOf',
      desc: '',
      args: [value],
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

  /// `MEMO`
  String get memo {
    return Intl.message(
      'MEMO',
      name: 'memo',
      desc: '',
      args: [],
    );
  }

  /// `Notice: Both a Memo and an Address are required to successfully deposit your {value} to Mixin.`
  String depositNotice(Object value) {
    return Intl.message(
      'Notice: Both a Memo and an Address are required to successfully deposit your $value to Mixin.',
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

  /// `This address only supports BTC and Omni USDT.`
  String get depositTipBtc {
    return Intl.message(
      'This address only supports BTC and Omni USDT.',
      name: 'depositTipBtc',
      desc: '',
      args: [],
    );
  }

  /// `This address supports all ERC-20 tokens, such as ETH, XIN, TUSD, HT, LOOM, LEO, etc.`
  String get depositTipEth {
    return Intl.message(
      'This address supports all ERC-20 tokens, such as ETH, XIN, TUSD, HT, LOOM, LEO, etc.',
      name: 'depositTipEth',
      desc: '',
      args: [],
    );
  }

  /// `This address supports all base on EOS tokens, such as EOS, IQ, BLACK, OCT, KARMA, etc.`
  String get depositTipEos {
    return Intl.message(
      'This address supports all base on EOS tokens, such as EOS, IQ, BLACK, OCT, KARMA, etc.',
      name: 'depositTipEos',
      desc: '',
      args: [],
    );
  }

  /// `This address supports all TRC-10 and TRC-20 tokens, such as TRX, BTT, USDT-TRON, etc.`
  String get depositTipTron {
    return Intl.message(
      'This address supports all TRC-10 and TRC-20 tokens, such as TRX, BTT, USDT-TRON, etc.',
      name: 'depositTipTron',
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

  /// `Send to Address`
  String get sendToAddress {
    return Intl.message(
      'Send to Address',
      name: 'sendToAddress',
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

  /// `Select from Address Book`
  String get selectFromAddressBook {
    return Intl.message(
      'Select from Address Book',
      name: 'selectFromAddressBook',
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

  /// `Copy to clipboard`
  String get copyToClipboard {
    return Intl.message(
      'Copy to clipboard',
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

  /// `Authorize`
  String get authorize {
    return Intl.message(
      'Authorize',
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

  /// `No address selected`
  String get noAddressSelected {
    return Intl.message(
      'No address selected',
      name: 'noAddressSelected',
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

  /// `Send to`
  String get sendTo {
    return Intl.message(
      'Send to',
      name: 'sendTo',
      desc: '',
      args: [],
    );
  }

  /// `Withdraw to an exchange or wallet.`
  String get sendToAddressDescription {
    return Intl.message(
      'Withdraw to an exchange or wallet.',
      name: 'sendToAddressDescription',
      desc: '',
      args: [],
    );
  }

  /// `Transfer to Mixin Messenger contact.`
  String get sendToContactDescription {
    return Intl.message(
      'Transfer to Mixin Messenger contact.',
      name: 'sendToContactDescription',
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

  /// `Select from contacts`
  String get selectFromContacts {
    return Intl.message(
      'Select from contacts',
      name: 'selectFromContacts',
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

  /// `No contact selected`
  String get noContactSelected {
    return Intl.message(
      'No contact selected',
      name: 'noContactSelected',
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
