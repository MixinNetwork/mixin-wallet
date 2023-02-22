const bitcoin = 'c6d0c728-2624-429b-8e0d-d9d19b6592fa';
const ethereum = '43d61dcd-e413-450d-80b8-101d5e903357';
const eos = '6cfe566e-4aad-470b-8c9a-2fd35b49c68d';
const ripple = '23dfb5a5-5d7b-48b6-905f-3970e3176e27';
const tron = '25dabac5-056a-48ff-b9f9-f67395dc407c';

const erc20USDT = '4d8c508b-91c5-375b-92b0-ee702ed2dac5';
const erc20USDC = '9b180ab6-6abe-3dc0-a13f-04169eb34bfa';
const dai = '94319320-eb5d-3e84-a07e-e24c21b8b934';

const pUsd = '31d2ea9c-95eb-3355-b65b-ba096853bc18';
const xin = 'c94ac88f-4671-3976-b60a-09064f1811e8';

class ChainId {
  ChainId._();

  static const ripple = '23dfb5a5-5d7b-48b6-905f-3970e3176e27';
  static const bitcoin = 'c6d0c728-2624-429b-8e0d-d9d19b6592fa';
  static const ethereum = '43d61dcd-e413-450d-80b8-101d5e903357';
  static const eos = '6cfe566e-4aad-470b-8c9a-2fd35b49c68d';
  static const tron = '25dabac5-056a-48ff-b9f9-f67395dc407c';

  static const litecoin = '76c802a2-7c88-447f-a93e-c29c9e5dd9c8';
  static const dogecoin = '6770a1e5-6086-44d5-b60f-545f9d9e8ffd';
  static const monero = '05c5ac01-31f9-4a69-aa8a-ab796de1d041';
  static const dash = '6472e7e3-75fd-48b6-b1dc-28d294ee1476';
  static const solana = '64692c23-8971-4cf4-84a7-4dd1271dd887';
  static const polygon = 'b7938396-3f94-4e0a-9179-d3440718156f';
}

const topRadius = 20.0;

const depositHelpLink =
    'https://mixinmessenger.zendesk.com/hc/articles/360018789931';

const usdtAssets = {
  '4d8c508b-91c5-375b-92b0-ee702ed2dac5': 'ERC-20',
  'b91e18ff-a9ae-3dc7-8679-e935d9a4b34b': 'TRON(TRC-20)',
  '5dac5e28-ad13-31ea-869f-41770dfcee09': 'EOS',
  '218bc6f4-7927-3f8e-8568-3a3725b74361': 'Polygon',
  '94213408-4ee7-3150-a9c4-9c5cce421c78': 'BEP-20',
};

// ommi usdt do not support deposit.
const omniUSDT = '815b0b1a-2764-3736-8faa-42d694fa620a';

const authScope =
    'PROFILE:READ+ASSETS:READ+CONTACTS:READ+SNAPSHOTS:READ+COLLECTIBLES:READ';
