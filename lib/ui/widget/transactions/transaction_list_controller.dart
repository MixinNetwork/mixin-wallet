import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../db/mixin_database.dart';
import '../../../util/extension/extension.dart';
import '../../../util/logger.dart';
import 'transaction_list.dart';

const _kLoadLimit = 5;

class TransactionListController {
  TransactionListController(
    this._loadMoreItemDb,
    this._refreshSnapshots,
    this._pageSize,
  );

  LoadMoreTransactionCallback _loadMoreItemDb;
  RefreshTransactionCallback _refreshSnapshots;
  int _pageSize;

  final snapshots = ValueNotifier(const <SnapshotItem>[]);

  final _snapshotItems = <SnapshotItem>[];

  final _snapshotFromDb = <SnapshotItem>[];

  Timer? _autoFillTask;

  bool _loading = false;

  Future<void> loadMoreItem() => _loadMoreItem(_pageSize);

  Future<void> _loadMoreItem(int limit) async {
    if (_loading) {
      return;
    }
    _loading = true;

    final offset = _snapshotItems.length;
    final lastItemCreatedAt = _snapshotItems.isEmpty
        ? null
        : _snapshotItems.last.createdAt.toIso8601String();

    i('TransactionListController start to load. $offset, $limit $lastItemCreatedAt');

    final cacheDbResult = _loadMoreItemDb(offset, limit);
    final networkResult = _refreshSnapshots(lastItemCreatedAt, limit);

    try {
      _snapshotFromDb
        ..clear()
        ..addAll(await cacheDbResult);
      _notifySnapshotsItemUpdated();
    } catch (e, s) {
      w('failed to load from database. $e $s');
    }

    try {
      await networkResult;
      _snapshotItems.addAll(await _loadMoreItemDb(offset, limit));
      _snapshotFromDb.clear();
      _notifySnapshotsItemUpdated();
    } catch (error, s) {
      e('failed to load item from network. $error $s');
    }
    _loading = false;
  }

  void _notifySnapshotsItemUpdated() {
    snapshots.value = [..._snapshotItems, ..._snapshotFromDb];
  }

  void _refreshSnapshotsItem(List<SnapshotItem> items) {
    final map = {for (var e in items) e.snapshotId: e};

    void updateList(List<SnapshotItem> list) {
      for (var i = 0; i < list.length; i++) {
        final item = list[i];
        final newItem = map[item.snapshotId];
        if (newItem == null) {
          continue;
        }
        list[i] = newItem;
      }
    }

    updateList(_snapshotItems);
    updateList(_snapshotFromDb);

    _notifySnapshotsItemUpdated();
  }

  // on [_pageSize] update, if current item count less than the new pageSize, we
  // need load more item to fill the blank.
  void updatePageSize(int pageSize) {
    if (_pageSize == pageSize) {
      return;
    }

    if (_loading) {
      // TODO check this after loading
      return;
    }

    final moreNeedLoad = pageSize - _snapshotItems.length;
    _pageSize = pageSize;

    if (moreNeedLoad <= 0) {
      return;
    }
    _autoFillTask?.cancel();
    _autoFillTask = Timer(const Duration(milliseconds: 800), () {
      _autoFillTask = null;
      _loadMoreItem(moreNeedLoad);
    });
  }

  void dispose() {
    _autoFillTask?.cancel();
    _autoFillTask = null;
  }
}

TransactionListController useTransactionListController({
  required LoadMoreTransactionCallback loadMoreItemDb,
  required RefreshTransactionCallback refreshSnapshots,
  int pageSize = _kLoadLimit,
}) {
  final controller = use(_TransactionListControllerHook(
    loadMoreItemDb: loadMoreItemDb,
    refreshSnapshots: refreshSnapshots,
    pageSize: pageSize,
  ));
  final snapshotDao = useContext().appServices.mixinDatabase.snapshotDao;
  useEffect(() {
    final subscription = snapshotDao.updateTransactionStream
        .listen(controller._refreshSnapshotsItem);
    return subscription.cancel;
  }, [snapshotDao]);
  return controller;
}

class _TransactionListControllerHook extends Hook<TransactionListController> {
  const _TransactionListControllerHook({
    required this.loadMoreItemDb,
    required this.refreshSnapshots,
    required this.pageSize,
  });

  final LoadMoreTransactionCallback loadMoreItemDb;
  final RefreshTransactionCallback refreshSnapshots;
  final int pageSize;

  @override
  _TransactionListControllerHookState createState() =>
      _TransactionListControllerHookState();
}

class _TransactionListControllerHookState extends HookState<
    TransactionListController, _TransactionListControllerHook> {
  late final TransactionListController _controller = TransactionListController(
    hook.loadMoreItemDb,
    hook.refreshSnapshots,
    hook.pageSize,
  );

  @override
  void didUpdateHook(_TransactionListControllerHook oldHook) {
    super.didUpdateHook(oldHook);
    _controller
      .._loadMoreItemDb = hook.loadMoreItemDb
      .._refreshSnapshots = hook.refreshSnapshots
      ..updatePageSize(hook.pageSize);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  TransactionListController build(BuildContext context) => _controller;
}
