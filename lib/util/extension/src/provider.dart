part of '../extension.dart';

extension ProviderExtension on BuildContext {
  AppServices get appServices => read<AppServices>();

  MixinDatabase get mixinDatabase => appServices.mixinDatabase;

  String get url =>
      GoRouter.of(this).routerDelegate.currentConfiguration.uri.toString();

  GoRouter get router => GoRouter.of(this);

  void toExternal(Object url, {bool openNewTab = false}) => launchUrlString(
        url.toString(),
        mode: openNewTab
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault,
      );

  void pop() => router.pop();

  bool canPop() => router.canPop();
}
