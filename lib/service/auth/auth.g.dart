// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Auth _$AuthFromJson(Map json) {
  return Auth(
    accessToken: json['accessToken'] as String,
    account:
        Account.fromJson(Map<String, dynamic>.from(json['account'] as Map)),
  );
}

Map<String, dynamic> _$AuthToJson(Auth instance) => <String, dynamic>{
      'accessToken': instance.accessToken,
      'account': instance.account.toJson(),
    };
