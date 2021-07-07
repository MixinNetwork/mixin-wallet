import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../db/mixin_database.dart';
import '../../../util/logger.dart';
import 'transaction_list.dart';

class TransactionListController {
  TransactionListController(
    this._loadMoreItemDb,
    this._loadMoreItemNetwork,
  );

  LoadMoreTransactionCallback _loadMoreItemDb;
  LoadMoreTransactionCallback _loadMoreItemNetwork;

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
    final networkResult = _loadMoreItemNetwork(offset);

    try {
      _snapshotFromDb
        ..clear()
        ..addAll(await dbResult);
      _updateSnapshotsItem();
    } catch (e, s) {
      w('failed to load from database. $e $s');
    }
    //
    // try {
    //   _snapshotItems.addAll(await networkResult);
    //   _snapshotFromDb.clear();
    //   _updateSnapshotsItem();
    // } catch (error, s) {
    //   e('failed to load item from network. $error $s');
    // }
    _loading = false;
  }

  void _updateSnapshotsItem() {
    snapshots.value = [..._snapshotItems, ..._snapshotFromDb];
  }
}

TransactionListController useTransactionListController({
  required LoadMoreTransactionCallback loadMoreItemDb,
  required LoadMoreTransactionCallback loadMoreItemNetwork,
}) {
  final controller = use(_TransactionListControllerHook(
    loadMoreItemDb: loadMoreItemDb,
    loadMoreItemNetwork: loadMoreItemNetwork,
  ));
  return controller;
}

class _TransactionListControllerHook extends Hook<TransactionListController> {
  const _TransactionListControllerHook({
    required this.loadMoreItemDb,
    required this.loadMoreItemNetwork,
  });

  final LoadMoreTransactionCallback loadMoreItemDb;
  final LoadMoreTransactionCallback loadMoreItemNetwork;

  @override
  _TransactionListControllerHookState createState() =>
      _TransactionListControllerHookState();
}

class _TransactionListControllerHookState extends HookState<
    TransactionListController, _TransactionListControllerHook> {
  late final TransactionListController _controller = TransactionListController(
    hook.loadMoreItemDb,
    hook.loadMoreItemNetwork,
  );

  @override
  void didUpdateHook(_TransactionListControllerHook oldHook) {
    super.didUpdateHook(oldHook);
    _controller
      .._loadMoreItemDb = hook.loadMoreItemDb
      .._loadMoreItemNetwork = hook.loadMoreItemNetwork;
  }

  @override
  TransactionListController build(BuildContext context) => _controller;
}
