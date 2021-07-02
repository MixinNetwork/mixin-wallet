import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';

part 'auth.g.dart';

@JsonSerializable(anyMap: true)
class Auth extends Equatable {
  const Auth({
    required this.accessToken,
    this.account,
  });

  factory Auth.fromJson(Map<String, dynamic> json) => _$AuthFromJson(json);

  Map<String, dynamic> toJson() => _$AuthToJson(this);

  @JsonKey()
  final String accessToken;
  @JsonKey()
  final Account? account;

  @override
  List<Object?> get props => [accessToken, account];

  Auth copyWith({
    String? accessToken,
    Account? account,
  }) =>
      Auth(
        accessToken: accessToken ?? this.accessToken,
        account: account ?? this.account,
      );
}
