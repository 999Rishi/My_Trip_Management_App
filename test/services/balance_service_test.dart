import 'package:flutter_test/flutter_test.dart';
import 'package:trip/models/expense.dart';
import 'package:trip/models/user.dart';
import 'package:trip/services/balance_service.dart';

void main() {
  group('BalanceService', () {
    late User user1;
    late User user2;
    late User user3;

    setUp(() {
      user1 = User(id: 'user1', name: 'Alice', email: 'alice@example.com');

      user2 = User(id: 'user2', name: 'Bob', email: 'bob@example.com');

      user3 = User(id: 'user3', name: 'Charlie', email: 'charlie@example.com');
    });

    test('calculateBalances with equal splits', () {
      final expenses = [
        Expense(
          id: 'exp1',
          tripId: 'trip1',
          description: 'Dinner',
          amount: 100.0,
          currency: 'USD',
          paidById: 'user1',
          participantIds: ['user1', 'user2', 'user3'],
          shares: {'user1': 0.33, 'user2': 0.33, 'user3': 0.34},
          categoryId: 'food',
          dateTime: DateTime.now(),
          splitType: 'equal',
        ),
      ];

      final members = [user1, user2, user3];
      final balances = BalanceService.calculateBalances(expenses, members);

      // Alice paid $100 but owes $33, so her balance should be $67
      expect(balances['user1'], closeTo(67.0, 0.1));

      // Bob and Charlie each owe $33, so their balances should be -$33
      expect(balances['user2'], closeTo(-33.0, 0.1));
      expect(balances['user3'], closeTo(-34.0, 0.1));
    });

    test('calculateBalances with unequal splits', () {
      final expenses = [
        Expense(
          id: 'exp1',
          tripId: 'trip1',
          description: 'Hotel',
          amount: 300.0,
          currency: 'USD',
          paidById: 'user2',
          participantIds: ['user1', 'user2'],
          shares: {'user1': 0.25, 'user2': 0.75},
          categoryId: 'hotel',
          dateTime: DateTime.now(),
          splitType: 'unequal',
        ),
      ];

      final members = [user1, user2];
      final balances = BalanceService.calculateBalances(expenses, members);

      // Alice owes $75 (25% of $300), so her balance should be -$75
      expect(balances['user1'], closeTo(-75.0, 0.1));

      // Bob paid $300 but owes $225 (75% of $300), so his balance should be $75
      expect(balances['user2'], closeTo(75.0, 0.1));
    });

    test('getUserNetBalance', () {
      final balances = {'user1': 50.0, 'user2': -25.0, 'user3': 0.0};

      expect(BalanceService.getUserNetBalance('user1', balances), 50.0);
      expect(BalanceService.getUserNetBalance('user2', balances), -25.0);
      expect(BalanceService.getUserNetBalance('user3', balances), 0.0);
      expect(BalanceService.getUserNetBalance('user4', balances), 0.0);
    });

    test('getUserTotalExpenses', () {
      final expenses = [
        Expense(
          id: 'exp1',
          tripId: 'trip1',
          description: 'Expense 1',
          amount: 100.0,
          currency: 'USD',
          paidById: 'user1',
          participantIds: ['user1', 'user2'],
          shares: {'user1': 0.5, 'user2': 0.5},
          categoryId: 'misc',
          dateTime: DateTime.now(),
        ),
        Expense(
          id: 'exp2',
          tripId: 'trip1',
          description: 'Expense 2',
          amount: 50.0,
          currency: 'USD',
          paidById: 'user1',
          participantIds: ['user1', 'user3'],
          shares: {'user1': 0.5, 'user3': 0.5},
          categoryId: 'misc',
          dateTime: DateTime.now(),
        ),
        Expense(
          id: 'exp3',
          tripId: 'trip1',
          description: 'Expense 3',
          amount: 75.0,
          currency: 'USD',
          paidById: 'user2',
          participantIds: ['user2', 'user3'],
          shares: {'user2': 0.5, 'user3': 0.5},
          categoryId: 'misc',
          dateTime: DateTime.now(),
        ),
      ];

      // User1 paid for expenses totaling $150
      expect(BalanceService.getUserTotalExpenses('user1', expenses), 150.0);

      // User2 paid for expenses totaling $75
      expect(BalanceService.getUserTotalExpenses('user2', expenses), 75.0);

      // User3 paid for no expenses
      expect(BalanceService.getUserTotalExpenses('user3', expenses), 0.0);
    });

    test('getUserTotalShare', () {
      final expenses = [
        Expense(
          id: 'exp1',
          tripId: 'trip1',
          description: 'Expense 1',
          amount: 100.0,
          currency: 'USD',
          paidById: 'user2',
          participantIds: ['user1', 'user2'],
          shares: {'user1': 0.3, 'user2': 0.7},
          categoryId: 'misc',
          dateTime: DateTime.now(),
        ),
        Expense(
          id: 'exp2',
          tripId: 'trip1',
          description: 'Expense 2',
          amount: 200.0,
          currency: 'USD',
          paidById: 'user3',
          participantIds: ['user1', 'user3'],
          shares: {'user1': 0.4, 'user3': 0.6},
          categoryId: 'misc',
          dateTime: DateTime.now(),
        ),
      ];

      // User1's share: 30% of $100 + 40% of $200 = $30 + $80 = $110
      expect(BalanceService.getUserTotalShare('user1', expenses), 110.0);

      // User2's share: 70% of $100 = $70
      expect(BalanceService.getUserTotalShare('user2', expenses), 70.0);

      // User3's share: 60% of $200 = $120
      expect(BalanceService.getUserTotalShare('user3', expenses), 120.0);
    });
  });
}
