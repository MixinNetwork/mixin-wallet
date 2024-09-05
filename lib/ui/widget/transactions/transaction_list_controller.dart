import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../db/mixin_database.dart';
import '../../../util/logger.dart';
import 'transaction_list.dart';

const _kLoadLimit = 200;

class TransactionListController {
  TransactionListController(
    this._loadMoreItemDb,
    this._refreshSnapshots,
    this._pageSize,
  );

  LoadMoreTransactionCallback _loadMoreItemDb;
  RefreshTransactionCallback _refreshSnapshots;

  // the size of snapshot we need to load once.
  // maybe more than the visible area.
  int _pageSize;

  int? _pendingPageSize;

  final snapshots = ValueNotifier(const <SnapshotItem>[]);

  final _snapshotItems = <SnapshotItem>[];

  final _snapshotFromDb = <SnapshotItem>[];

  Timer? _autoFillTask;

  bool _loading = false;

  var _disposed = false;

  Future<void> loadMoreItem() => _loadMoreItem(200);

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
      if (!_disposed) {
        _snapshotItems.addAll(await _loadMoreItemDb(offset, limit));
        _snapshotFromDb.clear();
        _notifySnapshotsItemUpdated();
      }
    } catch (error, s) {
      e('failed to load item from network. $error $s');
    }

    _loading = false;

    if (_disposed) {
      return;
    }

    if (_pendingPageSize != null) {
      updatePageSize(_pendingPageSize!);
      _pendingPageSize = null;
    }
  }

  void _notifySnapshotsItemUpdated() {
    snapshots.value = [..._snapshotItems, ..._snapshotFromDb];
  }

  // on [_pageSize] update, if current item count less than the new pageSize, we
  // need load more item to fill the blank.
  void updatePageSize(int pageSize) {
    if (_pageSize == pageSize) {
      return;
    }

    if (_loading) {
      _pendingPageSize = pageSize;
      return;
    }

    final moreNeedLoad = pageSize > _snapshotItems.length;
    _pageSize = pageSize;

    if (!moreNeedLoad) {
      return;
    }
    _autoFillTask?.cancel();
    _autoFillTask = Timer(const Duration(milliseconds: 800), () {
      _autoFillTask = null;
      loadMoreItem();
    });
  }

  void dispose() {
    _disposed = true;
    _autoFillTask?.cancel();
    _autoFillTask = null;
  }
}

TransactionListController useTransactionListController({
  required LoadMoreTransactionCallback loadMoreItemDb,
  required RefreshTransactionCallback refreshSnapshots,
  int pageSize = _kLoadLimit,
}) =>
    use(_TransactionListControllerHook(
      loadMoreItemDb: loadMoreItemDb,
      refreshSnapshots: refreshSnapshots,
      pageSize: pageSize,
    ));

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
