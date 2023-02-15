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

  test('parse ethereum uri', () async {
    const url1 =
        'ethereum:0xfb6916095ca1df60bb79Ce92ce3ea74c37c5d359?value=2.014e18';
    final result1 = await _parse(url1);
    expect(result1, isNotNull);

    expect(result1!.assetId, ChainId.ethereum);
    expect(result1.destination, '0xfb6916095ca1df60bb79Ce92ce3ea74c37c5d359');
    expect(result1.amount, '2.014');

    const url2 =
        'ethereum:pay-0xdAC17F958D2ee523a2206206994597C13D831ec7@1/transfer?address=0x00d02d4A148bCcc66C6de20C4EB1CbAB4298cDcc&uint256=2e7&gasPrice=14';
    final result2 = await _parse(url2);
    expect(result2, isNotNull);

    expect(result2!.assetId, '4d8c508b-91c5-375b-92b0-ee702ed2dac5');
    expect(result2.destination, '0x00d02d4A148bCcc66C6de20C4EB1CbAB4298cDcc');
    expect(result2.amount, '20');

    const url3 =
        'ethereum:0xD994790d2905b073c438457c9b8933C0148862db@1?value=1.697e16&gasPrice=14&label=Bitrefill%2008cba4ee-b6cd-47c8-9768-c82959c0edce';
    final result3 = await _parse(url3);
    expect(result3, isNotNull);

    expect(result3!.assetId, ChainId.ethereum);
    expect(result3.destination, '0xD994790d2905b073c438457c9b8933C0148862db');
    expect(result3.amount, '0.01697');

    const url4 =
        'ethereum:0xA974c709cFb4566686553a20790685A47acEAA33@1/transfer?address=0xB38F2E40e82F0AE5613D55203d84953aE4d5181B&amount=1.24&uint256=1.24e18';
    final result4 = await _parse(url4);
    expect(result4, isNotNull);

    expect(result4!.assetId, 'c94ac88f-4671-3976-b60a-09064f1811e8');
    expect(result4.destination, '0xB38F2E40e82F0AE5613D55203d84953aE4d5181B');
    expect(result4.amount, '1.24');

    const url5 =
        'ethereum:pay-0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48@1/transfer?address=0x50bF16E33E892F1c9Aa7C7FfBaF710E971b86Dd1&gasPrice=14';
    final result5 = await _parse(url5);
    expect(result5, isNull);

    const url6 =
        'ethereum:0xA974c709cFb4566686553a20790685A47acEAA33@1/transfer?a=b&c=d&uint256=1.24e18&e=f&amount=1.24&g=h&address=0xB38F2E40e82F0AE5613D55203d84953aE4d5181B&i=j&k=m&n=o&p=q';
    final result6 = await _parse(url6);
    expect(result6, isNotNull);

    expect(result6!.assetId, 'c94ac88f-4671-3976-b60a-09064f1811e8');
    expect(result6.destination, '0xB38F2E40e82F0AE5613D55203d84953aE4d5181B');
    expect(result6.amount, '1.24');

    const url7 =
        'ethereum:0xA974c709cFb4566686553a20790685A47acEAA33@1/transfer?address=0xB38F2E40e82F0AE5613D55203d84953aE4d5181B&amount=1e7&uint256=1.24e18';
    final result7 = await _parse(url7);
    expect(result7, isNull);

    const url8 =
        'ethereum:0x20269e75b1637632e87f65A0A053d6720A781f39?amount=0.00016882';
    final result8 = await _parse(url8);
    expect(result8, isNotNull);

    expect(result8!.assetId, ChainId.ethereum);
    expect(result8.destination, '0x20269e75b1637632e87f65A0A053d6720A781f39');
    expect(result8.amount, '0.00016882');

    const url9 =
        'ethereum:0xfb6916095ca1df60bb79Ce92ce3ea74c37c5d359?value=2.014e18&amount=2.014';
    final result9 = await _parse(url9);
    expect(result9, isNotNull);

    expect(result9!.assetId, ChainId.ethereum);
    expect(result9.destination, '0xfb6916095ca1df60bb79Ce92ce3ea74c37c5d359');
    expect(result9.amount, '2.014');

    const url10 =
        'ethereum:0xfb6916095ca1df60bb79Ce92ce3ea74c37c5d359?value=2.014e18&amount=2.013';
    final result10 = await _parse(url10);
    expect(result10, isNull);

    const url11 =
        'ethereum:0xA974c709cFb4566686553a20790685A47acEAA33@1/transfer?address=0xB38F2E40e82F0AE5613D55203d84953aE4d5181B&amount=1&uint256=1.24e18';
    final result11 = await _parse(url11);
    expect(result11, isNull);
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
                'c94ac88f-4671-3976-b60a-09064f1811e8': 18, // XIN
              }[assetId] ??
              0),
    );
