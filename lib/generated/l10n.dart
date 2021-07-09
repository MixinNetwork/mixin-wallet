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

  /// `Notice: Both an Account Memo and an Account Name are required to successfully deposit your {value} to Mixin.`
  String depositNotice(Object value) {
    return Intl.message(
      'Notice: Both an Account Memo and an Account Name are required to successfully deposit your $value to Mixin.',
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

  /// `Sending coin or token other than {value} to this address my result in the loss of your deposit.`
  String depositOnlyDesc(Object value) {
    return Intl.message(
      'Sending coin or token other than $value to this address my result in the loss of your deposit.',
      name: 'depositOnlyDesc',
      desc: '',
      args: [value],
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
