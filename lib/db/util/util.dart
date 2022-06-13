import 'package:drift/drift.dart';

final maxLimit = _MaxLimit();

class _MaxLimit extends Limit {
  _MaxLimit() : super(0, null);

  @override
  void writeInto(GenerationContext context) {
    // do nothing;
  }
}

const ignoreOrderBy = OrderBy([]);
const ignoreWhere = CustomExpression<bool>('true');
