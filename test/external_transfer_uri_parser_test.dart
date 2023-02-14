import 'package:flutter_test/flutter_test.dart';
import 'package:mixin_wallet/util/constants.dart';
import 'package:mixin_wallet/util/pay/external_transfer_uri_parser.dart';

void main() {
  test('parse bitcoin', () async {
    const urls = [
      'bitcoin:BC1QA7A84SQ2NNKPXUA5DLY6FG553D5V06NSL608SS?amount=0.00186487',
      'bitcoin:35pkcZ531UWYwVWRGeMG6eXkWbPptFg6AG?amount=0.00173492&fee=5&rbf=false&lightning=LNBC1734920N1P3EC8DGPP5NTUUNWS3GF9XUE4EZ2NCPEJCZHAJRVALFW8ALWFPN29LEE76NV5SDZ2GF5HGUN9VE5KCMPQV9SNYCMZVE3RWTF3XVMK2TF5XGMRJTFCXSCNSTF4VCCXYERYXQ6N2VRPVVCQZX7XQRP9SSP5Q4JSN54FHFQ8TRGHQGDQW2PUV790PXNSFVZG20CW322K0E6L7M8Q9QYYSSQA42ZJEMX44Y6PEW3YHWHXV9JUXTM96DMHKEPMD3LXUQTPH0HGSKX9TVZD2XVG7DETCVN450JXN25FM8G80GRYGU9ZHXC3XURSJ4Z20GPF8SQT7',
      'LIGHTNING:LNBC1197710N1P36QPY7PP5NZT3GTZMZP00E8NAR0C40DQVS5JT7PWCF7Z4MLXKH6F988QT08MSDZ2GF5HGUN9VE5KCMPQXGENSVFKXPNRXTTRV43NWTF5V4SKVTFEVCUXYTTXXAJNZVM9X4JRGETY8YCQZX7XQRP9SSP5EU7UUK9E5VKGQ2KYTW68D2JHTK7ALWSTFKYFMMSL2FGT22ZLMW9Q9QYYSSQAWC3VFFRPEGE79NLXKRMPVVR8Q9NVUMD4LFF3U2QRJ23A0RUUTGKJ7UCQQTE3RV93JYH20GJFPQHGLL7K2RPJMNYFXAP9NXPC4XQ80GPFE00SQ',
      'bitcoin:BC1QA7A84SQ2NNKPXUA5DLY6FG553D5V06NSL608SS?amount=0.12e3',
    ];

    final result1 = await _parse(urls[0]);
    expect(result1?.assetId, ChainId.bitcoin);
    expect(result1?.amount, '0.00186487');
    expect(result1?.destination, 'BC1QA7A84SQ2NNKPXUA5DLY6FG553D5V06NSL608SS');

    final result2 = await _parse(urls[1]);
    expect(result2?.assetId, ChainId.bitcoin);
    expect(result2?.amount, '0.00173492');
    expect(result2?.destination, '35pkcZ531UWYwVWRGeMG6eXkWbPptFg6AG');

    expect(await _parse(urls[2]), null);
    expect(await _parse(urls[3]), null);
  });
}

Future<ExternalTransfer?> _parse(String uri) => parseExternalTransferUri(
      uri,
      getAddressFee: (assetId, destination) async => AddressFeeResponse(
        destination: destination,
        assetId: assetId,
        fee: '0',
      ),
      findAssetIdByAssetKey: (assetKey) async => const {
        '0xdac17f958d2ee523a2206206994597c13d831ec7':
            '4d8c508b-91c5-375b-92b0-ee702ed2dac5',
        // ERC20 USDT
        '0xa974c709cfb4566686553a20790685a47aceaa33':
            'c94ac88f-4671-3976-b60a-09064f1811e8',
        // XIN
      }[assetKey],
      getAssetPrecisionById: (assetId) async => AssetPrecision(
          assetId: assetId,
          chainId: ChainId.ethereum,
          precision: const {
                '4d8c508b-91c5-375b-92b0-ee702ed2dac5': 6, // ERC20 USDT
                'c94ac88f-4671-3976-b60a-09064f1811e8': 8, // XIN
              }[assetId] ??
              0),
    );
