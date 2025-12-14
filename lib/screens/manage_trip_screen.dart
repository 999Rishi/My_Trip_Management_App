import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/trip.dart';
import '../models/user.dart';
import '../providers/trip_provider.dart';
import '../providers/user_provider.dart';

class ManageTripScreen extends ConsumerStatefulWidget {
  final Trip trip;

  const ManageTripScreen({super.key, required this.trip});

  @override
  _ManageTripScreenState createState() => _ManageTripScreenState();
}

class _ManageTripScreenState extends ConsumerState<ManageTripScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late DateTime _startDate;
  late DateTime _endDate;
  late String _baseCurrency;
  List<User> _members = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.trip.name);
    _startDate = widget.trip.startDate;
    _endDate = widget.trip.endDate;
    _baseCurrency = widget.trip.baseCurrency;

    // Load members
    _loadMembers();
  }

  void _loadMembers() {
    // Load actual members from the provider based on member IDs in the trip
    ref.read(usersProvider).whenData((users) {
      // Filter users that belong to this trip
      final tripMembers = users
          .where((user) => widget.trip.memberIds.contains(user.id))
          .toList();
      setState(() {
        _members = tripMembers;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
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
      initialDate: _startDate.isAfter(_endDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_startDate.isAfter(_endDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Start date must be before end date')),
        );
        return;
      }

      final updatedTrip = Trip(
        id: widget.trip.id,
        name: _nameController.text,
        startDate: _startDate,
        endDate: _endDate,
        memberIds: _members.map((member) => member.id).toList(),
        ownerId: widget.trip.ownerId,
        adminIds: widget.trip.adminIds,
        baseCurrency: _baseCurrency,
        isArchived: widget.trip.isArchived,
      );

      // Update trip using provider
      final updateTrip = ref.read(updateTripProvider);
      updateTrip(updatedTrip);

      Navigator.pop(context, updatedTrip);
    }
  }

  void _inviteMember() {
    // Show dialog to invite member
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController nameController = TextEditingController();
        return AlertDialog(
          title: Text('Add Member'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Enter member name',
              hintText: 'John Smith',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a member name')),
                  );
                  return;
                }

                // Check if member already exists
                if (_members.any((member) => member.name == name)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('This member is already added')),
                  );
                  return;
                }

                // Create a new user
                final newUser = User(
                  id: Uuid().v4(),
                  name: name,
                  email: null,
                  preferredCurrency: 'USD',
                  isDarkModeEnabled: false,
                );

                // Save the user to the database
                final addUser = ref.read(addUserProvider);
                await addUser(newUser);

                setState(() {
                  _members.add(newUser);
                });

                // Also update the trip with the new member
                final updatedTrip = Trip(
                  id: widget.trip.id,
                  name: widget.trip.name,
                  startDate: widget.trip.startDate,
                  endDate: widget.trip.endDate,
                  memberIds: [...widget.trip.memberIds, newUser.id],
                  ownerId: widget.trip.ownerId,
                  adminIds: widget.trip.adminIds,
                  baseCurrency: widget.trip.baseCurrency,
                  isArchived: widget.trip.isArchived,
                );

                // Update trip using provider
                final updateTrip = ref.read(updateTripProvider);
                updateTrip(updatedTrip);

                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Member added!')));
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeMember(int index) {
    // Don't allow removing the owner
    if (_members[index].id == widget.trip.ownerId) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cannot remove the trip owner')));
      return;
    }

    final memberIdToRemove = _members[index].id;

    setState(() {
      _members.removeAt(index);
    });

    // Also update the trip to remove the member
    final updatedMemberIds = List<String>.from(widget.trip.memberIds);
    updatedMemberIds.remove(memberIdToRemove);

    final updatedTrip = Trip(
      id: widget.trip.id,
      name: widget.trip.name,
      startDate: widget.trip.startDate,
      endDate: widget.trip.endDate,
      memberIds: updatedMemberIds,
      ownerId: widget.trip.ownerId,
      adminIds: widget.trip.adminIds,
      baseCurrency: widget.trip.baseCurrency,
      isArchived: widget.trip.isArchived,
    );

    // Update trip using provider
    final updateTrip = ref.read(updateTripProvider);
    updateTrip(updatedTrip);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Member removed')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Trip'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Delete trip confirmation
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Delete Trip'),
                    content: Text(
                      'Are you sure you want to delete "${widget.trip.name}"? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Delete the trip
                          final deleteTrip = ref.read(deleteTripProvider);
                          deleteTrip(widget.trip.id);

                          // Navigate back to home screen
                          Navigator.pop(context);

                          // Show a snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Trip "${widget.trip.name}" deleted',
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
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
                        ),
                        child: Text(
                          _startDate.toString().split(' ')[0],
                          style: TextStyle(fontSize: 16),
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
                        ),
                        child: Text(
                          _endDate.toString().split(' ')[0],
                          style: TextStyle(fontSize: 16),
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
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                items:
                    [
                      'USD',
                      'EUR',
                      'GBP',
                      'JPY',
                      'CAD',
                      'AUD',
                      'CHF',
                      'CNY',
                      'INR',
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
              SizedBox(height: 30),
              Text(
                'Members',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              // Use Consumer to watch for user changes and keep members list updated
              Consumer(
                builder: (context, ref, child) {
                  ref.watch(usersProvider);
                  return FutureBuilder<List<User>>(
                    future: _getTripMembers(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error loading members');
                      } else {
                        // Update the members list when data is available
                        if (snapshot.hasData) {
                          _members = snapshot.data!;
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _members.length,
                          itemBuilder: (context, index) {
                            final member = _members[index];
                            final isOwner = member.id == widget.trip.ownerId;
                            final isAdmin = widget.trip.adminIds.contains(
                              member.id,
                            );

                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(member.name.substring(0, 1)),
                                ),
                                title: Text(member.name),
                                subtitle: member.email != null
                                    ? Text(member.email!)
                                    : null,
                                trailing: isOwner
                                    ? Chip(label: Text('Owner'))
                                    : isAdmin
                                    ? Chip(label: Text('Admin'))
                                    : IconButton(
                                        icon: Icon(Icons.remove_circle),
                                        onPressed: () => _removeMember(index),
                                      ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  );
                },
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _inviteMember,
                icon: Icon(Icons.person_add),
                label: Text('Add Member'),
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<User>> _getTripMembers() async {
    final usersAsync = await ref.read(usersProvider.future);
    // Filter users that belong to this trip
    final tripMembers = usersAsync
        .where((user) => widget.trip.memberIds.contains(user.id))
        .toList();
    return tripMembers;
  }
}
