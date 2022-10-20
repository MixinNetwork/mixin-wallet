import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'telegram_user.g.dart';

@JsonSerializable()
class TelegramUser with EquatableMixin {
  TelegramUser({
    required this.userId,
    required this.mixinId,
    required this.privateKey,
    required this.sessionId,
    required this.pinToken,
  });

  factory TelegramUser.fromJson(Map<String, dynamic> json) =>
      _$TelegramUserFromJson(json);

  @JsonKey(name: 'user_id')
  final int userId;

  @JsonKey(name: 'mixin_id')
  final String mixinId;

  @JsonKey(name: 'private_key')
  final String privateKey;

  @JsonKey(name: 'session_id')
  final String sessionId;

  @JsonKey(name: 'pin_token')
  final String pinToken;

  Map<String, dynamic> toJson() => _$TelegramUserToJson(this);

  @override
  List<Object?> get props => [userId, mixinId, privateKey, sessionId, pinToken];
}
