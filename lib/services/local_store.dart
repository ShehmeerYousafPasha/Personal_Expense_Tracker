import 'dart:convert';

import 'package:get_storage/get_storage.dart';

import '../models/expense_transaction.dart';

class LocalStore {
  static const String transactionKey = 'transactions_v1';
  static const String customCategoryKey = 'custom_categories_v1';
  final GetStorage _box = GetStorage();

  List<ExpenseTransaction> loadTransactions() {
    final raw = _box.read(transactionKey);
    if (raw == null) {
      return [];
    }

    final decoded = jsonDecode(raw as String) as List<dynamic>;
    final transactions = decoded
        .map((e) => ExpenseTransaction.fromMap(e as Map<String, dynamic>))
        .toList();
    transactions.sort((a, b) => b.date.compareTo(a.date));
    return transactions;
  }

  Future<void> saveTransactions(List<ExpenseTransaction> transactions) async {
    final encoded = jsonEncode(transactions.map((e) => e.toMap()).toList());
    await _box.write(transactionKey, encoded);
  }

  List<String> loadCustomCategories() {
    final raw = _box.read(customCategoryKey);
    if (raw == null) {
      return [];
    }
    return List<String>.from(raw as List<dynamic>);
  }

  Future<void> saveCustomCategories(List<String> categories) async {
    await _box.write(customCategoryKey, categories);
  }
}
