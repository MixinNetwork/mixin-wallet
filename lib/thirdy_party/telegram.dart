import 'package:dio/dio.dart';

import 'vo/telegram_user.dart';

export 'vo/telegram_user.dart';

class TelegramApi {
  TelegramApi._internal();

  static final instance = TelegramApi._internal();

  final Dio dio = Dio();

  Future<TelegramUser> verifyInitData(String initData) async {
    final response = await dio.post<Map<String, dynamic>>(
      'https://telegram.mixinwallet.com/tg',
      data: {'init_data': initData},
    );
    return TelegramUser.fromJson(response.data!);
  }
}
