// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:personal_expense_tracker/models/expense_transaction.dart';

void main() {
  test('Transaction map conversion round-trip', () {
    final tx = ExpenseTransaction(
      id: 't1',
      amount: 120.5,
      category: 'Food',
      date: DateTime(2026, 5, 3),
      note: 'Lunch',
      type: TransactionType.expense,
    );

    final rebuilt = ExpenseTransaction.fromMap(tx.toMap());

    expect(rebuilt.id, tx.id);
    expect(rebuilt.amount, tx.amount);
    expect(rebuilt.category, tx.category);
    expect(rebuilt.note, tx.note);
    expect(rebuilt.type, tx.type);
  });
}
