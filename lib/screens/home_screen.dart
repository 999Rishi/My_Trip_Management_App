import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trip.dart';
import '../models/user.dart';
import '../providers/trip_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/common_widgets.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Trips',
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: tripsAsync.when(
        data: (trips) {
          if (trips.isEmpty) {
            return EmptyState(
              icon: Icons.travel_explore,
              title: 'No trips yet',
              subtitle: 'Create your first trip to start tracking expenses',
              action: GradientButton(
                text: 'Create Your First Trip',
                onPressed: _navigateToCreateTrip,
                width: 240,
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
                padding: EdgeInsets.all(AppSpacing.lg),
                itemCount: trips.length,
                itemBuilder: (context, index) {
                  final trip = trips[index];

                  // Get actual members for this trip
                  final tripMembers = users
                      .where((user) => trip.memberIds.contains(user.id))
                      .toList();

                  return _buildTripCard(context, trip, tripMembers);
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
              Icon(Icons.error_outline, size: 60, color: Colors.red),
              SizedBox(height: 10),
              Text('Error loading trips: $error'),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(tripsProvider);
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: AppColors.gradientPrimary),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _navigateToCreateTrip,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, Trip trip, List<User> members) {
    final gradients = [
      [Color(0xFF0EA5E9), Color(0xFF0284C7)],
      [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      [Color(0xFF10B981), Color(0xFF059669)],
      [Color(0xFFF59E0B), Color(0xFFD97706)],
      [Color(0xFFEC4899), Color(0xFFDB2777)],
    ];

    final gradientIndex = trip.name.hashCode % gradients.length;
    final gradient = gradients[gradientIndex];

    return Dismissible(
      key: Key(trip.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        final deleteTrip = ref.read(deleteTripProvider);
        deleteTrip(trip.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip "${trip.name}" deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.only(bottom: AppSpacing.md),
        child: Icon(Icons.delete_outline, color: Colors.white, size: 32),
      ),
      child: ModernCard(
        margin: EdgeInsets.only(bottom: AppSpacing.md),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripDetailScreen(trip: trip),
            ),
          );
        },
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.name,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${trip.startDate.toString().split(' ')[0]} - ${trip.endDate.toString().split(' ')[0]}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${members.length} ${members.length == 1 ? 'member' : 'members'}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
