import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../models/user.dart';
import '../models/settlement.dart';
import '../services/balance_service.dart';

final balancesProvider = FutureProvider.family<Map<String, double>, String>((
  ref,
  tripId,
) async {
  // In a real app, we would fetch expenses and members for the trip
  // For now, we'll return an empty map
  return {};
});

final settlementsProvider = FutureProvider.family<List<Settlement>, String>((
  ref,
  tripId,
) async {
  // In a real app, we would fetch settlements for the trip
  // For now, we'll return an empty list
  return [];
});

// Provider to calculate balances for a specific trip
final tripBalancesProvider =
    StateNotifierProvider<TripBalancesNotifier, Map<String, double>>((ref) {
      return TripBalancesNotifier();
    });

class TripBalancesNotifier extends StateNotifier<Map<String, double>> {
  TripBalancesNotifier() : super({});

  void calculateBalances(List<Expense> expenses, List<User> members) {
    state = BalanceService.calculateBalances(expenses, members);
  }
}

// Provider to calculate settlements for a specific trip
final tripSettlementsProvider =
    StateNotifierProvider<TripSettlementsNotifier, List<Settlement>>((ref) {
      return TripSettlementsNotifier();
    });

class TripSettlementsNotifier extends StateNotifier<List<Settlement>> {
  TripSettlementsNotifier() : super([]);

  void calculateSettlements(
    Map<String, double> balances,
    String tripId,
    String baseCurrency,
  ) {
    state = BalanceService.calculateSettlements(balances, tripId, baseCurrency);
  }
}
