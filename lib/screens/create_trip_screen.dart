import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trip.dart';
import '../models/user.dart';
import '../providers/trip_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/common_widgets.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  _CreateTripScreenState createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _memberNameController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _baseCurrency = 'INR'; // Changed default to INR
  final List<User> _members = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _memberNameController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _addMember() {
    final name = _memberNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a member name')));
      return;
    }

    // Check if member already exists
    if (_members.any((member) => member.name == name)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('This member is already added')));
      return;
    }

    // Create a temporary user (in a real app, you would fetch user details from a service)
    final newUser = User(
      id: Uuid().v4(),
      name: name,
      email: null, // Email is now optional
      preferredCurrency: 'USD',
      isDarkModeEnabled: false,
    );

    setState(() {
      _members.add(newUser);
      _memberNameController.clear();
    });
  }

  void _removeMember(int index) {
    setState(() {
      _members.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select start and end dates')),
        );
        return;
      }

      if (_startDate!.isAfter(_endDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Start date must be before end date')),
        );
        return;
      }

      // Require at least one member
      if (_members.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please add at least one member')),
        );
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      try {
        // Save all members to the database
        final addUser = ref.read(addUserProvider);
        for (final member in _members) {
          await addUser(member);
        }

        final trip = Trip(
          id: Uuid().v4(),
          name: _nameController.text,
          startDate: _startDate!,
          endDate: _endDate!,
          memberIds: _members.map((member) => member.id).toList(),
          ownerId: _members.first.id, // First member is the owner
          adminIds: [_members.first.id], // First member is also admin
          baseCurrency: _baseCurrency,
        );

        // Add trip using provider
        final addTrip = ref.read(addTripProvider);
        await addTrip(trip);

        if (mounted) {
          Navigator.pop(context, trip);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error creating trip: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Create Trip',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                ModernCard(
                  gradient: LinearGradient(colors: AppColors.gradientPrimary),
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.travel_explore,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Plan Your Adventure',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Fill in the details below',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xl),

                // Trip Name
                Text(
                  'Trip Name',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Summer Vacation 2024',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a trip name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.xl),

                // Date Selection
                Text(
                  'Trip Duration',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: ModernCard(
                        padding: EdgeInsets.zero,
                        onTap: () => _selectStartDate(context),
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Start Date',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                _startDate == null
                                    ? 'Select date'
                                    : '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ModernCard(
                        padding: EdgeInsets.zero,
                        onTap: () => _selectEndDate(context),
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'End Date',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                _endDate == null
                                    ? 'Select date'
                                    : '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xl),

                // Currency Selection
                Text(
                  'Base Currency',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: _baseCurrency,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.currency_exchange),
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
                      setState(() {
                        _baseCurrency = newValue;
                      });
                    }
                  },
                ),
                SizedBox(height: AppSpacing.xl),

                // Members section
                Text(
                  'Trip Members',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _memberNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter member name',
                    prefixIcon: Icon(Icons.person_add),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add_circle, color: AppColors.primary),
                      onPressed: _addMember,
                    ),
                  ),
                  onSubmitted: (_) => _addMember(),
                ),
                SizedBox(height: AppSpacing.md),
                if (_members.isNotEmpty)
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _members.asMap().entries.map((entry) {
                      final index = entry.key;
                      final member = entry.value;
                      return AvatarChip(
                        name: member.name,
                        isSelected: true,
                        trailing: IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.error,
                          ),
                          onPressed: () => _removeMember(index),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      );
                    }).toList(),
                  ),
                SizedBox(height: AppSpacing.xxl),

                // Submit Button
                GradientButton(
                  text: 'Create Trip',
                  onPressed: _isSubmitting ? () {} : _submitForm,
                  isLoading: _isSubmitting,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
