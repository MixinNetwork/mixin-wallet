import 'dart:convert';

import 'package:dio/dio.dart';

import 'vo/telegram_user.dart';

export 'vo/telegram_user.dart';

class TelegramApi {
  TelegramApi._internal();

  static final instance = TelegramApi._internal();

  final Dio dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      contentType: Headers.jsonContentType));

  Future<TelegramUser> verifyInitData(String initData) async {
    final response = await dio.post<Map<String, dynamic>>(
      'https://telegram.mixinwallet.com/tg',
      data: jsonEncode({'init_data': initData}),
    );
    return TelegramUser.fromJson(response.data!);
  }
}
