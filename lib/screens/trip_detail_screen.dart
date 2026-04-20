import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trip.dart';
import '../models/user.dart';
import '../models/expense.dart';
import '../models/settlement.dart';
import '../services/balance_service.dart';
import '../services/currency_service.dart';
import '../providers/expense_provider.dart';
import '../providers/user_provider.dart';
import '../providers/trip_provider.dart';
import '../widgets/common_widgets.dart';
import 'add_expense_screen.dart';
import 'manage_trip_screen.dart';
import 'manage_categories_screen.dart';

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

// Custom painter for modern donut chart
class DonutChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> data;
  final double total;
  final String currency;
  final double innerRadius;

  DonutChartPainter(
    this.data,
    this.total,
    this.currency, {
    this.innerRadius = 0.6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) * 0.9;
    final innerR = radius * innerRadius;
    final paint = Paint()..style = PaintingStyle.fill;

    double startAngle = -math.pi / 2; // Start from top
    final colors = [
      Color(0xFF0EA5E9),
      Color(0xFF8B5CF6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEC4899),
      Color(0xFF14B8A6),
      Color(0xFFF97316),
      Color(0xFF6366F1),
    ];

    // Draw donut slices
    for (int i = 0; i < data.length; i++) {
      final entry = data[i];
      final sweepAngle = 2 * math.pi * (entry.value / total);
      paint.color = colors[i % colors.length];

      final path = Path()
        ..addArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
        )
        ..addArc(
          Rect.fromCircle(center: center, radius: innerR),
          startAngle + sweepAngle,
          -sweepAngle,
        );

      canvas.drawPath(path, paint);
      startAngle += sweepAngle;
    }

    // Draw center text
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter
      ..text = TextSpan(
        text: '${data.length}\nCategories',
        style: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      )
      ..layout()
      ..paint(
        canvas,
        Offset(
          center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2,
        ),
      );
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.trip.name,
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.category_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageCategoriesScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined),
            onPressed: _navigateToManageTrip,
          ),
          IconButton(
            icon: Icon(Icons.share_outlined),
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
                widget.trip.baseCurrency,
              );

              // Calculate total trip cost
              final totalCost = expenses.fold(
                0.0,
                (sum, expense) => sum + expense.amount,
              );

              final perPerson = tripMembers.isNotEmpty
                  ? totalCost / tripMembers.length
                  : 0.0;

              return SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Section
                    _buildHeroSection(totalCost, perPerson, expenses.length),

                    SizedBox(height: AppSpacing.xl),

                    // Dashboard Stats
                    _buildDashboardStats(
                      totalCost,
                      perPerson,
                      expenses.length,
                      settlements.length,
                    ),

                    SizedBox(height: AppSpacing.xl),

                    // Category Breakdown
                    SectionHeader(title: 'Category Breakdown'),
                    SizedBox(height: AppSpacing.md),
                    ModernCard(child: _buildCategoryPieChart(expenses)),

                    SizedBox(height: AppSpacing.xl),

                    // Recent Expenses
                    SectionHeader(
                      title: 'Recent Expenses',
                      action: TextButton(
                        onPressed: () => _navigateToAddExpense(tripMembers),
                        child: Text('Add New'),
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    _buildExpensesList(expenses, tripMembers),

                    SizedBox(height: AppSpacing.xl),

                    // Settlements
                    SectionHeader(title: 'Settlements'),
                    SizedBox(height: AppSpacing.md),
                    _buildSettlementsList(settlements, tripMembers),
                  ],
                ),
              );
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
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
              Icon(Icons.error_outline, size: 60, color: Colors.red),
              SizedBox(height: 10),
              Text('Error loading users: $error'),
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
            onTap: () {
              usersAsync.whenData((users) {
                final tripMembers = users
                    .where((user) => widget.trip.memberIds.contains(user.id))
                    .toList();
                _navigateToAddExpense(tripMembers);
              });
            },
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

  Widget _buildHeroSection(
    double totalCost,
    double perPerson,
    int expenseCount,
  ) {
    return ModernCard(
      gradient: LinearGradient(
        colors: AppColors.gradientPrimary,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.trip.name,
                      style: GoogleFonts.inter(
                        fontSize: 24,
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
                          '${widget.trip.startDate.toString().split(' ')[0]} - ${widget.trip.endDate.toString().split(' ')[0]}',
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
                Icons.travel_explore,
                size: 40,
                color: Colors.white.withOpacity(0.9),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          Divider(color: Colors.white.withOpacity(0.3)),
          SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Spent',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    CurrencyService.formatCurrency(
                      totalCost,
                      widget.trip.baseCurrency,
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Per Person',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    CurrencyService.formatCurrency(
                      perPerson,
                      widget.trip.baseCurrency,
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardStats(
    double totalCost,
    double perPerson,
    int expenseCount,
    int settlementCount,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          icon: Icons.account_balance_wallet,
          label: 'Total Cost',
          value: CurrencyService.formatCurrency(
            totalCost,
            widget.trip.baseCurrency,
          ),
          color: AppColors.primary,
        ),
        _buildStatCard(
          icon: Icons.person,
          label: 'Per Person',
          value: CurrencyService.formatCurrency(
            perPerson,
            widget.trip.baseCurrency,
          ),
          color: Color(0xFF8B5CF6),
        ),
        _buildStatCard(
          icon: Icons.receipt_long,
          label: 'Expenses',
          value: '$expenseCount',
          color: Color(0xFF10B981),
        ),
        _buildStatCard(
          icon: Icons.handshake,
          label: 'Settlements',
          value: '$settlementCount',
          color: AppColors.accent,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return ModernCard(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList(List<Expense> expenses, List<User> tripMembers) {
    if (expenses.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long,
        title: 'No expenses yet',
        subtitle: 'Start tracking your trip expenses',
        action: GradientButton(
          text: 'Add First Expense',
          onPressed: () => _navigateToAddExpense(tripMembers),
          width: 200,
        ),
      );
    }

    return ListView.builder(
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

        return ModernCard(
          margin: EdgeInsets.only(bottom: AppSpacing.sm),
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getCategoryIcon(expense.categoryId),
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.description,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Paid by ${paidBy.name} • ${expense.participantIds.length} participants',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                CurrencyService.formatCurrency(
                  expense.amount,
                  expense.currency,
                ),
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettlementsList(
    List<Settlement> settlements,
    List<User> tripMembers,
  ) {
    if (settlements.isEmpty) {
      return ModernCard(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 48,
                color: AppColors.success,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'All settled up!',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: settlements.length > 3 ? 3 : settlements.length,
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

            return ModernCard(
              margin: EdgeInsets.only(bottom: AppSpacing.sm),
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.error.withOpacity(0.1),
                    child: Text(
                      fromUser.name.substring(0, 1).toUpperCase(),
                      style: GoogleFonts.inter(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${fromUser.name} owes ${toUser.name}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Settle with UPI or cash',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyService.formatCurrency(
                      settlement.amount,
                      widget.trip.baseCurrency,
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (settlements.length > 3)
          Center(
            child: TextButton(
              onPressed: () {
                _showAllSettlements(settlements, tripMembers);
              },
              child: Text('View All Settlements'),
            ),
          ),
      ],
    );
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'food':
        return Icons.restaurant;
      case 'hotel':
        return Icons.hotel;
      case 'travel':
        return Icons.flight;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.theater_comedy;
      case 'revolutionary':
        return Icons.stars;
      default:
        return Icons.category;
    }
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
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
      );
    }

    // Convert map to list for chart
    final categoryList = categoryMap.entries.toList();
    final total = categoryList.fold(0.0, (sum, item) => sum + item.value);

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: CustomPaint(
            painter: DonutChartPainter(
              categoryList,
              total,
              widget.trip.baseCurrency,
            ),
            size: Size(double.infinity, 200),
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        // Legend
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          children: categoryList.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final colors = [
              Color(0xFF0EA5E9),
              Color(0xFF8B5CF6),
              Color(0xFF10B981),
              Color(0xFFF59E0B),
              Color(0xFFEC4899),
              Color(0xFF14B8A6),
              Color(0xFFF97316),
              Color(0xFF6366F1),
            ];

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  category.key,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
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
