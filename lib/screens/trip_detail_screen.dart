import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip.dart';
import '../models/user.dart';
import '../models/expense.dart';
import '../models/settlement.dart';
import '../services/balance_service.dart';
import '../services/currency_service.dart';
import '../providers/expense_provider.dart';
import '../providers/user_provider.dart';
import '../providers/trip_provider.dart';
import 'add_expense_screen.dart';
import 'manage_trip_screen.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  final Trip trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  _TripDetailScreenState createState() => _TripDetailScreenState();
}

// Data model for pie chart
class CategorySpending {
  final String category;
  final double amount;

  CategorySpending(this.category, this.amount);
}

// Custom painter for pie chart
class PieChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> data;
  final double total;
  final String currency;

  PieChartPainter(this.data, this.total, this.currency);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) * 0.8;
    final paint = Paint()..style = PaintingStyle.fill;

    double startAngle = 0;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.yellow,
    ];

    // Draw pie slices
    for (int i = 0; i < data.length; i++) {
      final entry = data[i];
      final sweepAngle = 2 * math.pi * (entry.value / total);
      paint.color = colors[i % colors.length];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    // Draw labels
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    startAngle = 0;
    for (int i = 0; i < data.length; i++) {
      final entry = data[i];
      final sweepAngle = 2 * math.pi * (entry.value / total);
      final midAngle = startAngle + sweepAngle / 2;

      // Calculate position for label
      final labelRadius = radius * 0.7;
      final dx = center.dx + labelRadius * math.cos(midAngle);
      final dy = center.dy + labelRadius * math.sin(midAngle);
      final labelPosition = Offset(dx, dy);

      // Format percentage and amount
      final percentage = (entry.value / total * 100).toStringAsFixed(1);
      final label = '${entry.key}\n$percentage%';

      textPainter
        ..text = TextSpan(
          text: label,
          style: TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        )
        ..layout()
        ..paint(
          canvas,
          Offset(
            labelPosition.dx - textPainter.width / 2,
            labelPosition.dy - textPainter.height / 2,
          ),
        );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _navigateToAddExpense(List<User> members) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddExpenseScreen(trip: widget.trip, members: members),
      ),
    ).then((_) => setState(() {})); // Refresh data when returning
  }

  void _navigateToManageTrip() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageTripScreen(trip: widget.trip),
      ),
    ).then((result) {
      if (result != null && result is Trip) {
        setState(() {
          // Update the trip if it was modified
        });
      }
    });
  }

  void _confirmDeleteTrip() {
    // Show confirmation dialog
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
                _deleteTrip();
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteTrip() {
    // Delete the trip
    final deleteTrip = ref.read(deleteTripProvider);
    deleteTrip(widget.trip.id);

    // Navigate back to home screen
    Navigator.pop(context);

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Trip "${widget.trip.name}" deleted')),
    );
  }

  void _showAllSettlements(
    List<Settlement> settlements,
    List<User> tripMembers,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'All Settlements',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: settlements.length,
                  itemBuilder: (context, index) {
                    final settlement = settlements[index];
                    final fromUser = tripMembers.firstWhere(
                      (member) => member.id == settlement.fromUserId,
                      orElse: () {
                        final unknownUser = User.empty();
                        unknownUser.name = 'Unknown';
                        return unknownUser;
                      },
                    );
                    final toUser = tripMembers.firstWhere(
                      (member) => member.id == settlement.toUserId,
                      orElse: () {
                        final unknownUser = User.empty();
                        unknownUser.name = 'Unknown';
                        return unknownUser;
                      },
                    );

                    return ListTile(
                      title: Text('${fromUser.name} owes ${toUser.name}'),
                      subtitle: const Text('Settle with UPI or cash'),
                      trailing: Text(
                        CurrencyService.formatCurrency(
                          settlement.amount,
                          widget.trip.baseCurrency,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Load expenses for this trip
    final expensesAsync = ref.watch(tripExpensesProvider(widget.trip.id));

    // Load users
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trip.name),
        actions: [
          IconButton(icon: Icon(Icons.edit), onPressed: _navigateToManageTrip),
          IconButton(icon: Icon(Icons.delete), onPressed: _confirmDeleteTrip),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Share trip functionality
            },
          ),
        ],
      ),
      body: usersAsync.when(
        data: (users) {
          // Filter users that belong to this trip
          final tripMembers = users
              .where((user) => widget.trip.memberIds.contains(user.id))
              .toList();

          return expensesAsync.when(
            data: (expenses) {
              // Calculate balances
              final balances = BalanceService.calculateBalances(
                expenses,
                tripMembers,
              );

              // Calculate settlements
              final settlements = BalanceService.calculateSettlements(
                balances,
                widget.trip.id,
                widget.trip.baseCurrency, // Pass the base currency
              );

              // Calculate total trip cost
              final totalCost = expenses.fold(
                0.0,
                (sum, expense) => sum + expense.amount,
              );

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trip info card
                      Card(
                        elevation: 3,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.trip.name,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(Icons.travel_explore, size: 30),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Duration: ${widget.trip.startDate.toString().split(' ')[0]} - ${widget.trip.endDate.toString().split(' ')[0]}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Members: ${tripMembers.length} people',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Base Currency: ${widget.trip.baseCurrency}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Dashboard summary
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 10),

                      // Summary cards
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 3,
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      'Total Cost',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      CurrencyService.formatCurrency(
                                        totalCost,
                                        widget.trip.baseCurrency,
                                      ),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Category-wise summary
                      Text(
                        'Category-wise Spending',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 10),

                      // Pie chart for category spending
                      _buildCategoryPieChart(expenses),

                      SizedBox(height: 20),

                      // Recent expenses
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recent Expenses',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () => _navigateToAddExpense(tripMembers),
                            child: Text('Add Expense'),
                          ),
                        ],
                      ),

                      SizedBox(height: 10),

                      // List of recent expenses
                      if (expenses.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.money_off,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 10),
                              Text(
                                'No expenses yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () =>
                                    _navigateToAddExpense(tripMembers),
                                child: Text('Add First Expense'),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: expenses.length > 5 ? 5 : expenses.length,
                          itemBuilder: (context, index) {
                            final expense = expenses.elementAt(index);
                            final paidBy = tripMembers.firstWhere(
                              (member) => member.id == expense.paidById,
                              orElse: () {
                                final unknownUser = User.empty();
                                unknownUser.name = 'Unknown';
                                return unknownUser;
                              },
                            );

                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue[100],
                                  child: Text(
                                    expense.categoryId
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: TextStyle(color: Colors.blue[800]),
                                  ),
                                ),
                                title: Text(expense.description),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Paid by ${paidBy.name}',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      '${expense.participantIds.length} participants',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  CurrencyService.formatCurrency(
                                    expense.amount,
                                    expense.currency,
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                      SizedBox(height: 20),

                      // Settlements
                      Text(
                        'Settlements',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 10),

                      if (settlements.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 60,
                                color: Colors.green[400],
                              ),
                              SizedBox(height: 10),
                              Text(
                                'All settled up!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: settlements.length > 2
                              ? 2
                              : settlements.length,
                          itemBuilder: (context, index) {
                            final settlement = settlements.elementAt(index);
                            final fromUser = tripMembers.firstWhere(
                              (member) => member.id == settlement.fromUserId,
                              orElse: () {
                                final unknownUser = User.empty();
                                unknownUser.name = 'Unknown';
                                return unknownUser;
                              },
                            );
                            final toUser = tripMembers.firstWhere(
                              (member) => member.id == settlement.toUserId,
                              orElse: () {
                                final unknownUser = User.empty();
                                unknownUser.name = 'Unknown';
                                return unknownUser;
                              },
                            );

                            return ListTile(
                              title: Text(
                                '${fromUser.name} owes ${toUser.name}',
                              ),
                              subtitle: Text('Settle with UPI or cash'),
                              trailing: Text(
                                CurrencyService.formatCurrency(
                                  settlement.amount,
                                  widget.trip.baseCurrency,
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            );
                          },
                        ),

                      if (settlements.length > 2)
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // Show all settlements
                              _showAllSettlements(settlements, tripMembers);
                            },
                            child: Text('View All Settlements'),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 60, color: Colors.red),
                  SizedBox(height: 10),
                  Text('Error loading expenses: $error'),
                ],
              ),
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 60, color: Colors.red),
              SizedBox(height: 10),
              Text('Error loading users: $error'),
            ],
          ),
        ),
      ),
      floatingActionButton: usersAsync.when(
        data: (users) {
          // Filter users that belong to this trip
          final tripMembers = users
              .where((user) => widget.trip.memberIds.contains(user.id))
              .toList();
          return FloatingActionButton(
            onPressed: () => _navigateToAddExpense(tripMembers),
            tooltip: 'Add Expense',
            child: Icon(Icons.add),
          );
        },
        loading: () =>
            FloatingActionButton(onPressed: null, child: Icon(Icons.add)),
        error: (error, stack) =>
            FloatingActionButton(onPressed: null, child: Icon(Icons.add)),
      ),
    );
  }

  Widget _buildCategoryPieChart(List<Expense> expenses) {
    // Group expenses by category
    final categoryMap = <String, double>{};

    for (var expense in expenses) {
      final categoryName = _getCategoryName(expense.categoryId);
      if (categoryMap.containsKey(categoryName)) {
        categoryMap[categoryName] = categoryMap[categoryName]! + expense.amount;
      } else {
        categoryMap[categoryName] = expense.amount;
      }
    }

    if (categoryMap.isEmpty) {
      return Center(
        child: Text(
          'No spending yet',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    // Convert map to list for pie chart
    final categoryList = categoryMap.entries.toList();
    final total = categoryList.fold(0.0, (sum, item) => sum + item.value);

    return SizedBox(
      height: 200,
      child: CustomPaint(
        painter: PieChartPainter(categoryList, total, widget.trip.baseCurrency),
        size: Size(double.infinity, 200),
      ),
    );
  }

  String _getCategoryName(String categoryId) {
    // Map category IDs to names
    switch (categoryId) {
      case 'food':
        return 'Food';
      case 'hotel':
        return 'Hotel';
      case 'travel':
        return 'Travel';
      case 'shopping':
        return 'Shopping';
      case 'entertainment':
        return 'Entertainment';
      default:
        return 'Other';
    }
  }
}
