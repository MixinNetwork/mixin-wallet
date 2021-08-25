import '../util/constants.dart';

import '../util/r.dart';

// const supportedFiats = [
//   'USD',
//   'EUR',
//   'GBP',
//   'AUD',
//   'CAD',
//   'NZD',
//   'ARS',
//   'BRL',
//   'CHF',
//   'CLP',
//   'COP',
//   'CZK',
//   'DKK',
//   'HKD',
//   'ILS',
//   'INR',
//   'ISK',
//   'JPY',
//   'KRW',
//   'MXN',
//   'MYR',
//   'NOK',
//   'PHP',
//   'PLN',
//   'SEK',
//   'SGD',
//   'THB',
//   'VND',
//   'ZAR',
// ];

const wyreDomain = 'api.testwyre.com';

const supportedFiats = [
  'USD',
  'JPY',
  'EUR',
  'KRW',
  'HKD',
  'GBP',
  'AUD',
  'SGD',
  'MYR',
  'PHP',
];

const supportedFiatsSymbol = [
  r'$',
  '¥',
  '€',
  '₩',
  r'HK$',
  '£',
  r'A$',
  r'S$',
  'RM',
  '₱',
];

const supportedFiatsFlag = [
  R.resourcesIcFlagUsd,
  R.resourcesIcFlagJpy,
  R.resourcesIcFlagEur,
  R.resourcesIcFlagKrw,
  R.resourcesIcFlagHkd,
  R.resourcesIcFlagGbp,
  R.resourcesIcFlagAud,
  R.resourcesIcFlagSgd,
  R.resourcesIcFlagMyr,
  R.resourcesIcFlagPhp,
];

const supportedCryptos = ['USDT', 'USDC', 'DAI'];
const supportedCryptosId = [erc20USDT, erc20USDC, dai];
