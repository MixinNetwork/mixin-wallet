import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';

import '../../thirdy_party/telegram.dart';

part 'auth.g.dart';

@JsonSerializable(anyMap: true)
class Auth extends Equatable {
  const Auth({
    required this.accessToken,
    required this.account,
    required this.credential,
  }) : assert(
          accessToken != null || credential != null,
          'accessToken or credential must be not null',
        );

  factory Auth.fromJson(Map<String, dynamic> json) => _$AuthFromJson(json);

  Map<String, dynamic> toJson() => _$AuthToJson(this);

  // not null if login by mixin oauth. for mixin bot
  @JsonKey()
  final String? accessToken;
  @JsonKey()
  final Account account;

  // not null if login by private key. for telegram bot.
  @JsonKey()
  final TelegramUser? credential;

  @override
  List<Object?> get props => [accessToken, account, credential];

  Auth copyWith({
    String? accessToken,
    Account? account,
    TelegramUser? credential,
  }) =>
      Auth(
        accessToken: accessToken ?? this.accessToken,
        account: account ?? this.account,
        credential: credential ?? this.credential,
      );
}
