import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense_transaction.dart';
import '../services/local_store.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/monthly_trend_chart.dart';
import '../widgets/transaction_form_sheet.dart';

class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({super.key});

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  static const List<String> _baseCategories = [
    'Food',
    'Travel',
    'Bills',
    'Shopping',
  ];

  final LocalStore _store = LocalStore();
  final NumberFormat _moneyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0);
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  List<ExpenseTransaction> _transactions = [];
  List<String> _customCategories = [];
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _transactions = _store.loadTransactions();
    _customCategories = _store.loadCustomCategories();
  }

  List<String> get _allCategories => [..._baseCategories, ..._customCategories];

  List<ExpenseTransaction> get _monthlyTransactions {
    return _transactions.where((tx) {
      return tx.date.year == _selectedMonth.year &&
          tx.date.month == _selectedMonth.month;
    }).toList();
  }

  double get _monthlyIncome => _monthlyTransactions
      .where((tx) => tx.type == TransactionType.income)
      .fold(0.0, (sum, tx) => sum + tx.amount);

  double get _monthlyExpense => _monthlyTransactions
      .where((tx) => tx.type == TransactionType.expense)
      .fold(0.0, (sum, tx) => sum + tx.amount);

  double get _monthlyBalance => _monthlyIncome - _monthlyExpense;

  Future<void> _persist() async {
    await _store.saveTransactions(_transactions);
    await _store.saveCustomCategories(_customCategories);
  }

  Future<void> _upsertTransaction(ExpenseTransaction tx) async {
    final index = _transactions.indexWhere((e) => e.id == tx.id);
    setState(() {
      if (index == -1) {
        _transactions.add(tx);
      } else {
        _transactions[index] = tx;
      }
      _transactions.sort((a, b) => b.date.compareTo(a.date));
    });
    await _persist();
  }

  Future<void> _deleteTransaction(String id) async {
    setState(() {
      _transactions.removeWhere((e) => e.id == id);
    });
    await _persist();
  }

  Future<void> _showTransactionForm({ExpenseTransaction? existing}) async {
    final result = await showModalBottomSheet<ExpenseTransaction>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TransactionFormSheet(
        categories: _allCategories,
        initial: existing,
      ),
    );

    if (result == null) {
      return;
    }

    if (!_allCategories.contains(result.category)) {
      setState(() {
        _customCategories.add(result.category);
      });
    }
    await _upsertTransaction(result);
  }

  Future<void> _confirmDelete(ExpenseTransaction tx) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete transaction?'),
          content: Text('This will remove ${tx.category} on ${_dateFormat.format(tx.date)}.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteTransaction(tx.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy').format(_selectedMonth);
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTransactionForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add transaction'),
      ),
      body: Stack(
        children: [
          const _BackgroundOrnament(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF0B6E4F), Color(0xFF1D8A63)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_rounded,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Personal Expense Tracker',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.4,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Track spending, income, and balance offline.',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: const Color(0xFF5A6672),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF12352D), Color(0xFF0B6E4F)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(11, 110, 79, 0.18),
                                blurRadius: 30,
                                offset: Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_month_rounded, color: Colors.white70),
                                    const SizedBox(width: 8),
                                    Text(
                                      monthLabel,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const Spacer(),
                                    _MonthNavButton(
                                      icon: Icons.chevron_left,
                                      onPressed: () {
                                        setState(() {
                                          _selectedMonth = DateTime(
                                            _selectedMonth.year,
                                            _selectedMonth.month - 1,
                                          );
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    _MonthNavButton(
                                      icon: Icons.chevron_right,
                                      onPressed: () {
                                        setState(() {
                                          _selectedMonth = DateTime(
                                            _selectedMonth.year,
                                            _selectedMonth.month + 1,
                                          );
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _HeaderMetric(
                                        label: 'Income',
                                        value: _moneyFormat.format(_monthlyIncome),
                                        icon: Icons.arrow_downward_rounded,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _HeaderMetric(
                                        label: 'Expenses',
                                        value: _moneyFormat.format(_monthlyExpense),
                                        icon: Icons.arrow_upward_rounded,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.16),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: const Icon(Icons.wallet_rounded, color: Colors.white),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Remaining balance',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    color: Colors.white70,
                                                  ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              _moneyFormat.format(_monthlyBalance),
                                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (_monthlyTransactions.isNotEmpty)
                        ExpensePieChart(
                          transactions: _monthlyTransactions,
                          formatter: _moneyFormat,
                        ),
                      const SizedBox(height: 12),
                      MonthlyTrendChart(
                        transactions: _transactions,
                        anchorMonth: _selectedMonth,
                        formatter: _moneyFormat,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'Transactions',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            '${_monthlyTransactions.length} items',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF5A6672),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (_monthlyTransactions.isEmpty)
                        const _EmptyStateCard()
                      else
                        ..._monthlyTransactions.map(
                          (tx) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _TransactionTile(
                              transaction: tx,
                              dateText: _dateFormat.format(tx.date),
                              moneyFormat: _moneyFormat,
                              onEdit: () => _showTransactionForm(existing: tx),
                              onDelete: () => _confirmDelete(tx),
                            ),
                          ),
                        ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundOrnament extends StatelessWidget {
  const _BackgroundOrnament();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color.fromRGBO(11, 110, 79, 0.18), Color.fromRGBO(11, 110, 79, 0.0)],
                ),
              ),
            ),
          ),
          Positioned(
            top: 260,
            left: -70,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color.fromRGBO(29, 138, 99, 0.12), Color.fromRGBO(29, 138, 99, 0.0)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthNavButton extends StatelessWidget {
  const _MonthNavButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF4EF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF0B6E4F)),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No transactions yet',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4),
                  Text('Add an income or expense to start tracking your month.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.dateText,
    required this.moneyFormat,
    required this.onEdit,
    required this.onDelete,
  });

  final ExpenseTransaction transaction;
  final String dateText;
  final NumberFormat moneyFormat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final accentColor = isIncome ? const Color(0xFF0B6E4F) : const Color(0xFFC85A3D);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isIncome
                      ? [const Color(0xFFDFF5EA), const Color(0xFFCBE9DA)]
                      : [const Color(0xFFFFE8E0), const Color(0xFFF7D1C7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                isIncome ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          transaction.category,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isIncome ? const Color(0xFFEAF7EF) : const Color(0xFFFFEFEA),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${isIncome ? '+' : '-'}${moneyFormat.format(transaction.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    transaction.note.isNotEmpty ? transaction.note : 'No note added',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF5A6672),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_month_rounded, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        dateText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF5A6672),
                            ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: onEdit,
                        child: const Text('Edit'),
                      ),
                      TextButton(
                        onPressed: onDelete,
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
