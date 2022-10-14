// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telegram_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TelegramUser _$TelegramUserFromJson(Map<String, dynamic> json) => TelegramUser(
      userId: json['user_id'] as String,
      mixinId: json['mixin_id'] as String,
      privateKey: json['private_key'] as String,
      sessionId: json['session_id'] as String,
      pinToken: json['pin_token'] as String,
    );

Map<String, dynamic> _$TelegramUserToJson(TelegramUser instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'mixin_id': instance.mixinId,
      'private_key': instance.privateKey,
      'session_id': instance.sessionId,
      'pin_token': instance.pinToken,
    };
