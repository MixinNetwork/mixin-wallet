part of '../extension.dart';

extension ProviderExtension on BuildContext {
  Map<String, String> get pathParameters => vRouter.pathParameters;

  Map<String, String> get queryParameters => vRouter.queryParameters;

  AppServices get appServices => read<AppServices>();

  MixinDatabase get mixinDatabase => appServices.mixinDatabase;

  void replace(Object url) => vRouter.to(url.toString(), isReplacement: true);

  void push(Object url) => vRouter.to(url.toString());

  void toExternal(Object url) => vRouter.toExternal(url.toString());

  void pop() => vRouter.historyBack();
}
