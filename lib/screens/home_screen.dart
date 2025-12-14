import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip.dart';
import '../models/user.dart';
import '../providers/trip_provider.dart';
import '../providers/user_provider.dart';
import 'trip_detail_screen.dart';
import 'create_trip_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule user setup for after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupDefaultUser();
    });
  }

  void _setupDefaultUser() {
    try {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        // Create a default user for testing
        final defaultUser = User(
          id: 'user_1',
          name: 'John Doe',
          email: 'john.doe@example.com',
          preferredCurrency: 'USD',
          isDarkModeEnabled: false,
        );

        ref.read(currentUserProvider.notifier).state = defaultUser;
      }
    } catch (e) {
      // Handle any errors during user setup
      print('Error setting up default user: $e');
    }
  }

  void _navigateToCreateTrip() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateTripScreen()),
    );

    // If a trip was created, show a success message
    if (result != null && result is Trip) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trip "${result.name}" created successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(tripsProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Trips'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: tripsAsync.when(
        data: (trips) {
          if (trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.travel_explore, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 20),
                  Text(
                    'No trips yet',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Create your first trip to get started',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return FutureBuilder<List<User>>(
            future: ref.read(usersProvider.future),
            builder: (context, usersSnapshot) {
              if (usersSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final users = usersSnapshot.data ?? [];

              return ListView.builder(
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  final trip = trips[index];

                  // Get actual members for this trip
                  final tripMembers = users
                      .where((user) => trip.memberIds.contains(user.id))
                      .toList();

                  return Card(
                    margin: EdgeInsets.all(10),
                    elevation: 3,
                    child: Dismissible(
                      key: Key(trip.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        // Delete the trip
                        final deleteTrip = ref.read(deleteTripProvider);
                        deleteTrip(trip.id);

                        // Show a snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Trip "${trip.name}" deleted'),
                          ),
                        );
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20.0),
                        color: Colors.red,
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ListTile(
                        title: Text(
                          trip.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${trip.startDate.toString().split(' ')[0]} - ${trip.endDate.toString().split(' ')[0]}',
                            ),
                            SizedBox(height: 5),
                            Text(
                              '${tripMembers.length} members',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TripDetailScreen(trip: trip),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 60, color: Colors.red),
              SizedBox(height: 10),
              Text('Error loading trips: $error'),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // Refresh the provider
                  ref.refresh(tripsProvider);
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTrip,
        tooltip: 'Create Trip',
        child: Icon(Icons.add),
      ),
    );
  }
}
