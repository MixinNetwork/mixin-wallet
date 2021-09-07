part of '../extension.dart';

extension ProviderExtension on BuildContext {
  Map<String, String> get pathParameters => vRouter.pathParameters;

  Map<String, String> get queryParameters => vRouter.queryParameters;

  AppServices get appServices => read<AppServices>();

  MixinDatabase get mixinDatabase => appServices.mixinDatabase;

  void replace(Object url) => vRouter.to(url.toString(), isReplacement: true);

  void push(Object url) => vRouter.to(url.toString());

  String get url => vRouter.url;

  String get path => vRouter.path;

  void toExternal(Object url, {bool openNewTab = false}) =>
      vRouter.toExternal(url.toString(), openNewTab: openNewTab);

  void pop() => vRouter.historyBack();
}
