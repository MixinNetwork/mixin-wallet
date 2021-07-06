import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../db/mixin_database.dart';
import '../service/auth/auth_manager.dart';
import '../util/extension/extension.dart';

class MixinCommonVariables extends Equatable {
  const MixinCommonVariables({
    required this.assetResults,
  });

  final List<AssetResult>? assetResults;

  @override
  List<Object?> get props => [assetResults];
}

class CommonVariableProvider extends HookWidget {
  const CommonVariableProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final currentFiat = useStream(useMemoized(
      () => context.appServices.watchFiats().map(
            (fiats) => fiats.cast<Fiat?>().firstWhereOrNull(
                  (element) => element?.code == auth!.account.fiatCurrency,
                ),
          ),
    )).data;

    final assetResults = useStream<List<AssetResult>>(
      useMemoized(() {
        if (currentFiat == null) return const Stream.empty();
        return context.appServices.watchAssets(currentFiat.rate).map(
              (list) => list
                ..sort(
                  (a, b) => b.amountOfUsd.compareTo(a.amountOfUsd),
                ),
            );
      }, [currentFiat?.rate]),
    ).data;

    final mixinCommonVariables =
        MixinCommonVariables(assetResults: assetResults);

    return Provider.value(
      value: mixinCommonVariables,
      child: child,
    );
  }
}
