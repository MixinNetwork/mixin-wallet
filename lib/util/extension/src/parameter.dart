part of '../extension.dart';

extension ParameterExtension on BuildContext {
  Map<String, String> get pathParameters =>
      read<MixinParameter>().pathParameters;

  Map<String, String> get queryParameters =>
      read<MixinParameter>().queryParameters;
}
