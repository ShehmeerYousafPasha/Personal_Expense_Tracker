import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense_transaction.dart';

class TransactionFormSheet extends StatefulWidget {
  const TransactionFormSheet({
    super.key,
    required this.categories,
    this.initial,
  });

  final List<String> categories;
  final ExpenseTransaction? initial;

  @override
  State<TransactionFormSheet> createState() => _TransactionFormSheetState();
}

class _TransactionFormSheetState extends State<TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late final TextEditingController _customCategoryController;

  late TransactionType _type;
  late DateTime _date;
  late TimeOfDay _time;
  String? _selectedCategory;
  bool _useCustomCategory = false;

  DateTime get _selectedDateTime =>
      DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);

  bool _isToday(DateTime value, DateTime reference) {
    return value.year == reference.year &&
        value.month == reference.month &&
        value.day == reference.day;
  }

  void _showFutureDateTimeMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Date and time cannot be in the future.')),
    );
  }

  String _normalizeCategory(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }

    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initial?.amount.toStringAsFixed(0) ?? '',
    );
    _noteController = TextEditingController(text: widget.initial?.note ?? '');
    _customCategoryController = TextEditingController();
    _type = widget.initial?.type ?? TransactionType.expense;
    _date = widget.initial?.date ?? DateTime.now();
    _time = TimeOfDay.fromDateTime(widget.initial?.date ?? DateTime.now());

    if (widget.initial == null) {
      // For new transactions, use custom category for income, regular dropdown for expenses
      if (_type == TransactionType.income) {
        _useCustomCategory = true;
        _selectedCategory = null;
      } else {
        _useCustomCategory = false;
        _selectedCategory = widget.categories.isNotEmpty ? widget.categories.first : 'Food';
      }
    } else if (widget.categories.contains(widget.initial!.category)) {
      _useCustomCategory = false;
      _selectedCategory = widget.initial!.category;
    } else {
      _useCustomCategory = true;
      _customCategoryController.text = widget.initial!.category;
      _selectedCategory = null;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        if (_selectedDateTime.isAfter(now)) {
          _time = TimeOfDay.fromDateTime(now);
        }
      });
    }
  }

  Future<void> _pickTime() async {
    final now = DateTime.now();
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) {
      final selectedDateTime = DateTime(
        _date.year,
        _date.month,
        _date.day,
        picked.hour,
        picked.minute,
      );

      if (_isToday(_date, now) && selectedDateTime.isAfter(now)) {
        _showFutureDateTimeMessage();
        return;
      }

      setState(() {
        _time = picked;
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final category = _useCustomCategory
        ? _normalizeCategory(_customCategoryController.text)
        : (_selectedCategory ?? '').trim();

    final dateTime = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );

    if (dateTime.isAfter(DateTime.now())) {
      _showFutureDateTimeMessage();
      return;
    }

    final tx = ExpenseTransaction(
      id: widget.initial?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      amount: int.parse(_amountController.text.trim()).toDouble(),
      category: category,
      date: dateTime,
      note: _noteController.text.trim(),
      type: _type,
    );

    Navigator.pop(context, tx);
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + viewInsets.bottom),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.initial == null ? 'Add transaction' : 'Edit transaction',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Expense'),
                    icon: Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Income'),
                    icon: Icon(Icons.arrow_downward),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (value) {
                  setState(() {
                    _type = value.first;
                    // For income, always use custom category (income source)
                    if (_type == TransactionType.income) {
                      _useCustomCategory = true;
                      _customCategoryController.clear();
                    } else {
                      _useCustomCategory = false;
                      _customCategoryController.clear();
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: 'Rs. ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final amount = int.tryParse((value ?? '').trim());
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              if (_type == TransactionType.expense)
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Use custom category'),
                  value: _useCustomCategory,
                  onChanged: (value) {
                    setState(() {
                      _useCustomCategory = value;
                    });
                  },
                ),
              if (_type == TransactionType.income)
                TextFormField(
                  controller: _customCategoryController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Income source',
                    hintText: 'e.g., Salary, Freelance, Bonus',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter income source';
                    }
                    return null;
                  },
                )
              else if (_useCustomCategory) const SizedBox(height: 8),
              if (_type == TransactionType.expense && _useCustomCategory)
                TextFormField(
                  controller: _customCategoryController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Custom category',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_useCustomCategory && (value == null || value.trim().isEmpty)) {
                      return 'Enter a category name';
                    }
                    return null;
                  },
                )
              else if (_type == TransactionType.expense && !_useCustomCategory)
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (!_useCustomCategory && (value == null || value.trim().isEmpty)) {
                      return 'Choose a category';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month),
                      label: Text(DateFormat('dd MMM yyyy').format(_date)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(_time.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: Text(widget.initial == null ? 'Add transaction' : 'Save changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
