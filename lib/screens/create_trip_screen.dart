import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/trip.dart';
import '../models/user.dart';
import '../providers/trip_provider.dart';
import '../providers/user_provider.dart';

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
      appBar: AppBar(title: Text('Create Trip')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Trip Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a trip name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectStartDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _startDate == null
                                ? 'Select start date'
                                : '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectEndDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'End Date',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _endDate == null
                                ? 'Select end date'
                                : '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: _baseCurrency,
                  decoration: InputDecoration(
                    labelText: 'Base Currency',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.currency_rupee,
                    ), // Changed to rupee symbol
                  ),
                  items:
                      [
                        'INR', // Indian Rupee first
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
                SizedBox(height: 20),
                // Members section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Members',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _memberNameController,
                      decoration: InputDecoration(
                        labelText: 'Add member by name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: _addMember,
                        ),
                      ),
                      onSubmitted: (_) => _addMember(),
                    ),
                    SizedBox(height: 10),
                    if (_members.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _members.length,
                          separatorBuilder: (_, __) => Divider(height: 1),
                          itemBuilder: (context, index) {
                            final member = _members[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(member.name.substring(0, 1)),
                              ),
                              title: Text(member.name),
                              subtitle:
                                  member.email != null &&
                                      member.email!.isNotEmpty
                                  ? Text(member.email!)
                                  : null,
                              trailing: IconButton(
                                icon: Icon(Icons.remove_circle_outline),
                                onPressed: () => _removeMember(index),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text('Create Trip'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
