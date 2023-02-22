import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rxdart/rxdart.dart';

import '../../db/mixin_database.dart';
import '../../service/account_provider.dart';
import '../../service/profile/profile_manager.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../../util/native_scroll.dart';
import '../../util/r.dart';
import '../router/mixin_routes.dart';
import 'asset.dart';
import 'chain_network_label.dart';
import 'search_header_widget.dart';
import 'symbol.dart';
import 'text.dart';

class SearchAssetBottomSheet extends HookWidget {
  const SearchAssetBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final keywordStreamController = useStreamController<String>();
    final keywordStream = useMemoized(
        () => keywordStreamController.stream.map((e) => e.trim()).distinct());
    final hasKeyword =
        useMemoizedStream(() => keywordStream.map((event) => event.isNotEmpty))
                .data ??
            false;

    return SizedBox(
      height: MediaQuery.of(context).size.height - 100,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 8),
            child: SearchHeaderWidget(
              hintText: context.l10n.search,
              onChanged: keywordStreamController.add,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: IndexedStack(
              index: hasKeyword ? 1 : 0,
              children: [
                const _EmptyKeywordAssetList(),
                _SearchAssetList(keywordStream: keywordStream),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyKeywordAssetList extends HookWidget {
  const _EmptyKeywordAssetList();

  @override
  Widget build(BuildContext context) {
    final assetIds = useMemoizedFuture(() async {
          await context.appServices.updateTopAssetIds();
          return topAssetIds;
        }).data ??
        topAssetIds;

    final faitCurrency = useAccountFaitCurrency();

    final topAssets = useMemoizedStream(
          () =>
              context.appServices.watchAssetResultsOfIn(assetIds, faitCurrency),
          keys: [...topAssetIds, faitCurrency],
        ).data ??
        [];

    final histories = useMemoizedStream(
          () => context.appServices
              .watchAssetResultsOfIn(searchAssetHistory, faitCurrency),
          keys: [faitCurrency],
        ).data ??
        [];

    final slivers = [
      if (histories.isNotEmpty)
        SliverToBoxAdapter(child: _SubTitle(context.l10n.recentSearches)),
      if (histories.isNotEmpty)
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => _Item(
              data: histories[index],
            ),
            childCount: histories.length,
          ),
        ),
      if (topAssets.isNotEmpty)
        SliverToBoxAdapter(child: _SubTitle(context.l10n.assetTrending)),
      if (topAssets.isNotEmpty)
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => _Item(
              data: topAssets[index],
            ),
            childCount: topAssets.length,
          ),
        ),
    ];

    if (slivers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return CustomScrollView(
      slivers: slivers,
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      );
}

class _SearchAssetList extends HookWidget {
  const _SearchAssetList({
    required this.keywordStream,
  });

  final Stream<String> keywordStream;

  @override
  Widget build(BuildContext context) {
    final isNetworkSearching = useState(false);
    useEffect(() {
      CancelableOperation<dynamic>? lastRequest;
      final listen = keywordStream
          .where((event) => event.isNotEmpty)
          .map((event) {
            isNetworkSearching.value = true;
            return event;
          })
          .debounceTime(const Duration(milliseconds: 500))
          .map(
            (String keyword) => CancelableOperation.fromFuture(
              context.appServices.searchAndUpdateAsset(keyword),
            ),
          )
          .listen((event) {
            lastRequest?.cancel();
            lastRequest = event;
            event.value.then((_) {
              isNetworkSearching.value = false;
            });
          });
      return () {
        listen.cancel();
        lastRequest?.cancel();
      };
    }, [keywordStream]);

    final keyword = useMemoizedStream(() => keywordStream.throttleTime(
          const Duration(milliseconds: 100),
          trailing: true,
          leading: false,
        )).data;

    final faitCurrency = useAccountFaitCurrency();

    final searchResult = useMemoizedStream(() {
      if (keyword?.isEmpty ?? true) return Stream.value(<AssetResult>[]);
      return context.appServices
          .searchAssetResults(keyword!, faitCurrency)
          .watch();
    }, keys: [keyword]);

    final searchList = searchResult.data ?? const [];

    if ((searchResult.connectionState != ConnectionState.done &&
            searchResult.connectionState != ConnectionState.active) ||
        (searchList.isEmpty && isNetworkSearching.value)) {
      return const _SearchLoadingLayout();
    }

    if (searchList.isEmpty) {
      return const _SearchEmptyLayout();
    }

    return NativeScrollBuilder(
      builder: (context, controller) => ListView.builder(
        controller: controller,
        itemCount: searchList.length,
        itemBuilder: (BuildContext context, int index) => _Item(
          data: searchList[index],
          replaceHistory: true,
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.data,
    this.replaceHistory = false,
  });

  final AssetResult data;
  final bool replaceHistory;

  @override
  Widget build(BuildContext context) {
    void onTap() {
      if (replaceHistory) {
        putSearchAssetHistory(data.assetId);
      }
      context.push(assetDetailPath.toUri({'id': data.assetId}));
    }

    return Material(
        color: context.theme.background,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 72,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                const SizedBox(width: 20),
                SymbolIconWithBorder(
                  symbolUrl: data.iconUrl,
                  chainUrl: data.chainIconUrl,
                  size: 40,
                  chainSize: 14,
                  chainBorder: BorderSide(
                    color: context.colorScheme.background,
                    width: 1.5,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: MixinText(
                              data.symbol.overflow,
                              style: TextStyle(
                                color: context.theme.text,
                                fontSize: 16,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          ChainNetworkLabel(asset: data),
                        ],
                      ),
                      MixinText(
                        data.name.overflow,
                        style: TextStyle(
                          color: context.theme.secondaryText,
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                AssetPrice(data: data),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ));
  }
}

class _SearchEmptyLayout extends StatelessWidget {
  const _SearchEmptyLayout();

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 100),
          Center(
            child: SvgPicture.asset(
              R.resourcesEmptyTransactionGreySvg,
              width: 80,
              height: 80,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              context.l10n.noResult,
              style: TextStyle(
                color: context.colorScheme.thirdText,
                fontSize: 14,
              ),
            ),
          ),
          const Spacer(flex: 164),
        ],
      );
}

class _SearchLoadingLayout extends StatelessWidget {
  const _SearchLoadingLayout();

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 100),
          Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: context.colorScheme.captionIcon,
              ),
            ),
          ),
          const Spacer(flex: 164),
        ],
      );
}
