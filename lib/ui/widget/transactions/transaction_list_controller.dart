import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../db/mixin_database.dart';
import '../../../util/extension/extension.dart';
import '../../../util/logger.dart';
import 'transaction_list.dart';

class TransactionListController {
  TransactionListController(
    this._loadMoreItemDb,
    this._refreshSnapshots,
  );

  LoadMoreTransactionCallback _loadMoreItemDb;
  RefreshTransactionCallback _refreshSnapshots;

  final snapshots = ValueNotifier(const <SnapshotItem>[]);

  final _snapshotItems = <SnapshotItem>[];

  final _snapshotFromDb = <SnapshotItem>[];

  bool _loading = false;

  Future<void> loadMoreItem() async {
    if (_loading) {
      return;
    }
    _loading = true;

    final offset = _snapshotItems.isEmpty
        ? null
        : _snapshotItems.last.createdAt.toIso8601String();

    final dbResult = _loadMoreItemDb(offset);
    final networkResult = _refreshSnapshots(offset);

    try {
      _snapshotFromDb
        ..clear()
        ..addAll(await dbResult);
      _notifySnapshotsItemUpdated();
    } catch (e, s) {
      w('failed to load from database. $e $s');
    }

    try {
      final lists = await networkResult;
      _snapshotItems.addAll(lists);
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
}

TransactionListController useTransactionListController({
  required LoadMoreTransactionCallback loadMoreItemDb,
  required RefreshTransactionCallback refreshSnapshots,
}) {
  final controller = use(_TransactionListControllerHook(
    loadMoreItemDb: loadMoreItemDb,
    refreshSnapshots: refreshSnapshots,
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
  });

  final LoadMoreTransactionCallback loadMoreItemDb;
  final RefreshTransactionCallback refreshSnapshots;

  @override
  _TransactionListControllerHookState createState() =>
      _TransactionListControllerHookState();
}

class _TransactionListControllerHookState extends HookState<
    TransactionListController, _TransactionListControllerHook> {
  late final TransactionListController _controller = TransactionListController(
    hook.loadMoreItemDb,
    hook.refreshSnapshots,
  );

  @override
  void didUpdateHook(_TransactionListControllerHook oldHook) {
    super.didUpdateHook(oldHook);
    _controller
      .._loadMoreItemDb = hook.loadMoreItemDb
      .._refreshSnapshots = hook.refreshSnapshots;
  }

  @override
  TransactionListController build(BuildContext context) => _controller;
}
