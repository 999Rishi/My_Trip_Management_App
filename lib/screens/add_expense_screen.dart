import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/expense.dart';
import '../models/trip.dart';
import '../models/user.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../services/currency_service.dart';
import '../widgets/common_widgets.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final Trip trip;
  final List<User> members;

  const AddExpenseScreen({
    super.key,
    required this.trip,
    required this.members,
  });

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
      // Ensure the person who paid is also a participant
      if (!_participantIds.contains(userId)) {
        _participantIds.add(userId);
        _initializeShares();
      }
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Add Expense',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount Input Section
                ModernCard(
                  gradient: LinearGradient(colors: AppColors.gradientPrimary),
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      Text(
                        'Amount',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.9),
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _currency,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _amountController,
                              style: GoogleFonts.inter(
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '0',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black.withOpacity(0.5),
                                ),
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
                        ],
                      ),
                      if (_convertedAmount > 0 &&
                          _currency != widget.trip.baseCurrency)
                        Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            '≈ ${_convertedAmount.toStringAsFixed(2)} ${widget.trip.baseCurrency}',
                            style: GoogleFonts.inter(
                              color: Colors.black.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xl),

                // Description
                Text(
                  'Description',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'What was this expense for?',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.xl),

                // Date & Currency Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          ModernCard(
                            padding: EdgeInsets.zero,
                            onTap: () => _selectDate(context),
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.md),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '${_dateTime.year}-${_dateTime.month.toString().padLeft(2, '0')}-${_dateTime.day.toString().padLeft(2, '0')}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Currency',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          DropdownButtonFormField<String>(
                            initialValue: _currency,
                            isExpanded: true,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
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
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xl),

                // Paid By
                Text(
                  'Paid By',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: widget.members.map((member) {
                    final isSelected = _paidById == member.id;
                    return AvatarChip(
                      key: ValueKey('paid_by_${member.id}'),
                      name: member.name,
                      isSelected: isSelected,
                      onTap: () {
                        _updatePaidBy(member.id);
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: AppSpacing.xl),

                // Participants
                Text(
                  'Participants',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: widget.members.map((member) {
                    final isSelected = _participantIds.contains(member.id);
                    return AvatarChip(
                      name: member.name,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _participantIds.remove(member.id);
                          } else {
                            _participantIds.add(member.id);
                          }
                          _initializeShares();
                        });
                        _convertAmount();
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: AppSpacing.xl),

                // Category
                Text(
                  'Category',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                categoriesAsync.when(
                  data: (categories) {
                    return DropdownButtonFormField<String>(
                      initialValue: _categoryId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.category_outlined),
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
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Text('Error loading categories'),
                ),
                SizedBox(height: AppSpacing.xxl),

                // Submit Button
                GradientButton(text: 'Add Expense', onPressed: _submitForm),
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
      case 'stars':
        return Icons.stars;
      default:
        return Icons.help;
    }
  }
}
