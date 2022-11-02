import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'telegram_receiver.g.dart';

@JsonSerializable()
class TelegramReceiver with EquatableMixin {
  TelegramReceiver({
    required this.id,
    this.isBot,
    required this.firstName,
    this.lastName,
    this.photoUrl,
  });

  factory TelegramReceiver.fromJson(Map<String, dynamic> json) =>
      _$TelegramReceiverFromJson(json);

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'is_bot')
  final bool? isBot;

  @JsonKey(name: 'first_name')
  final String firstName;

  @JsonKey(name: 'last_name')
  final String? lastName;

  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  Map<String, dynamic> toJson() => _$TelegramReceiverToJson(this);

  @override
  List<Object?> get props => [id, isBot, firstName, lastName, photoUrl];
}
