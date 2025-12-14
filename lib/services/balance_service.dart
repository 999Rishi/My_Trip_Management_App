import '../models/expense.dart';
import '../models/user.dart';
import '../models/settlement.dart';

class BalanceService {
  // Calculate balances for all users in a trip
  static Map<String, double> calculateBalances(
    List<Expense> expenses,
    List<User> members,
  ) {
    final balances = <String, double>{};

    // Initialize balances for all members
    for (final member in members) {
      balances[member.id] = 0.0;
    }

    // Process each expense
    for (final expense in expenses) {
      // Subtract the amount paid by the payer
      balances[expense.paidById] =
          (balances[expense.paidById] ?? 0) + expense.amount;

      // Subtract each participant's share
      for (final participantId in expense.participantIds) {
        final share = expense.shares[participantId] ?? 0;
        final amountOwed = expense.amount * share;
        balances[participantId] = (balances[participantId] ?? 0) - amountOwed;
      }
    }

    return balances;
  }

  // Calculate who owes whom (simplified algorithm)
  static List<Settlement> calculateSettlements(
    Map<String, double> balances,
    String tripId,
    String baseCurrency, // Add baseCurrency parameter
  ) {
    final settlements = <Settlement>[];

    // Separate creditors (positive balance) and debtors (negative balance)
    final creditors = <String, double>{};
    final debtors = <String, double>{};

    balances.forEach((userId, balance) {
      if (balance > 0.01) {
        creditors[userId] = balance;
      } else if (balance < -0.01) {
        debtors[userId] = -balance; // Make it positive for easier calculation
      }
    });

    // Simple settlement algorithm
    creditors.forEach((creditorId, creditAmount) {
      var remainingCredit = creditAmount;

      debtors.forEach((debtorId, debtAmount) {
        if (remainingCredit <= 0.01) return;
        if (debtAmount <= 0.01) return;

        final settlementAmount = remainingCredit < debtAmount
            ? remainingCredit
            : debtAmount;

        settlements.add(
          Settlement(
            id: 'settle_${DateTime.now().millisecondsSinceEpoch}_${creditorId}_$debtorId',
            tripId: tripId,
            fromUserId: debtorId,
            toUserId: creditorId,
            amount: settlementAmount,
            currency: baseCurrency, // Use the trip's base currency
            dateTime: DateTime.now(),
            paymentMethod: 'cash',
            isSettled: false,
          ),
        );

        remainingCredit -= settlementAmount;
        debtors[debtorId] = debtAmount - settlementAmount;
      });
    });

    return settlements;
  }

  // Get user's net balance
  static double getUserNetBalance(String userId, Map<String, double> balances) {
    return balances[userId] ?? 0.0;
  }

  // Get user's total expenses
  static double getUserTotalExpenses(String userId, List<Expense> expenses) {
    return expenses
        .where((expense) => expense.paidById == userId)
        .fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Get user's total share of expenses
  static double getUserTotalShare(String userId, List<Expense> expenses) {
    return expenses
        .where((expense) => expense.participantIds.contains(userId))
        .fold(0.0, (sum, expense) {
          final share = expense.shares[userId] ?? 0;
          return sum + (expense.amount * share);
        });
  }
}
