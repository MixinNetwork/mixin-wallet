// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telegram_receiver.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TelegramReceiver _$TelegramReceiverFromJson(Map<String, dynamic> json) =>
    TelegramReceiver(
      id: json['id'] as int,
      isBot: json['is_bot'] as bool?,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String?,
      photoUrl: json['photo_url'] as String?,
    );

Map<String, dynamic> _$TelegramReceiverToJson(TelegramReceiver instance) =>
    <String, dynamic>{
      'id': instance.id,
      'is_bot': instance.isBot,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'photo_url': instance.photoUrl,
    };
