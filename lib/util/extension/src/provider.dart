part of '../extension.dart';

extension ProviderExtension on BuildContext {
  Map<String, String> get pathParameters =>
      read<MixinParameter>().pathParameters;

  Map<String, String> get queryParameters =>
      read<MixinParameter>().queryParameters;

  AppServices get appServices => read<AppServices>();

  MixinDatabase get mixinDatabase => appServices.mixinDatabase;
}
