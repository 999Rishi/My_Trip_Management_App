import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../models/trip.dart';
import '../models/user.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../services/currency_service.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final Trip trip;
  final List<User> members;

  const AddExpenseScreen({super.key, required this.trip, required this.members});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  late DateTime _dateTime;
  String _currency = 'INR';
  String _paidById = '';
  List<String> _participantIds = [];
  String _categoryId = 'misc';
  final Map<String, double> _shares = {};
  double _convertedAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _dateTime = DateTime.now();
    _currency = widget.trip.baseCurrency;
    if (widget.members.isNotEmpty) {
      _paidById = widget.members.first.id;
      _participantIds = widget.members.map((member) => member.id).toList();
      _initializeShares();
    }
    _convertedAmount = 0.0;
  }

  void _initializeShares() {
    final count = _participantIds.length;
    if (count > 0) {
      final share = 1.0 / count;
      for (final participantId in _participantIds) {
        _shares[participantId] = share;
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: widget.trip.startDate,
      lastDate: widget.trip.endDate,
    );
    if (picked != null && picked != _dateTime) {
      setState(() {
        _dateTime = picked;
      });
    }
  }

  void _updateCurrency(String newCurrency) {
    setState(() {
      _currency = newCurrency;
    });
    _convertAmount();
  }

  void _updatePaidBy(String userId) {
    setState(() {
      _paidById = userId;
    });
  }

  void _updateParticipants(List<String> participantIds) {
    setState(() {
      _participantIds = participantIds;
      _initializeShares();
    });
    _convertAmount();
  }

  Future<void> _convertAmount() async {
    if (_amountController.text.isEmpty) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    try {
      final converted = CurrencyService.convertCurrency(
        amount,
        _currency,
        widget.trip.baseCurrency,
      );
      setState(() {
        _convertedAmount = converted;
      });
    } catch (e) {
      setState(() {
        _convertedAmount = amount; // Fallback to original amount
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_participantIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select at least one participant')),
        );
        return;
      }

      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Please enter a valid amount')));
        return;
      }

      final expense = Expense(
        id: Uuid().v4(),
        tripId: widget.trip.id,
        description: _descriptionController.text,
        amount: amount,
        currency: _currency,
        paidById: _paidById,
        participantIds: _participantIds,
        shares: _shares,
        categoryId: _categoryId,
        dateTime: _dateTime,
        splitType: 'equal', // Default to equal split
      );

      try {
        // Add expense using provider
        final addExpense = ref.read(addExpenseProvider);
        await addExpense(expense);

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error adding expense: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Add Expense')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.currency_rupee),
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _convertAmount();
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        initialValue: _currency,
                        decoration: InputDecoration(
                          labelText: 'Currency',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            [
                              'INR',
                              'USD',
                              'EUR',
                              'GBP',
                              'JPY',
                              'CAD',
                              'AUD',
                              'CHF',
                              'CNY',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _updateCurrency(newValue);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (_convertedAmount > 0 &&
                    _currency != widget.trip.baseCurrency)
                  Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Converted: ${_convertedAmount.toStringAsFixed(2)} ${widget.trip.baseCurrency}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                SizedBox(height: 20),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_dateTime.year}-${_dateTime.month.toString().padLeft(2, '0')}-${_dateTime.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Paid by',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: widget.members.map((member) {
                    return ChoiceChip(
                      label: Text(member.name),
                      selected: _paidById == member.id,
                      onSelected: (selected) {
                        if (selected) {
                          _updatePaidBy(member.id);
                        }
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                Text(
                  'Participants',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: widget.members.map((member) {
                    final isSelected = _participantIds.contains(member.id);
                    return FilterChip(
                      label: Text(member.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _participantIds.add(member.id);
                          } else {
                            _participantIds.remove(member.id);
                          }
                          _initializeShares();
                        });
                        _convertAmount();
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                categoriesAsync.when(
                  data: (categories) {
                    return DropdownButtonFormField<String>(
                      initialValue: _categoryId,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: categories.map<DropdownMenuItem<String>>((
                        category,
                      ) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Row(
                            children: [
                              Icon(_getIconData(category.icon), size: 20),
                              SizedBox(width: 10),
                              Text(category.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _categoryId = newValue;
                          });
                        }
                      },
                    );
                  },
                  loading: () => CircularProgressIndicator(),
                  error: (error, stack) => Text('Error loading categories'),
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text('Add Expense'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to convert string icon name to IconData
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'local_dining':
        return Icons.local_dining;
      case 'hotel':
        return Icons.hotel;
      case 'train':
        return Icons.train;
      case 'confirmation_number':
        return Icons.confirmation_number;
      case 'help':
        return Icons.help;
      default:
        return Icons.help;
    }
  }
}
