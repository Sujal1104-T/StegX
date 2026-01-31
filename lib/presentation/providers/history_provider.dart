import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stegx/data/history_service.dart';
import 'package:stegx/data/models/history_model.dart';
import 'package:stegx/presentation/providers/auth_provider.dart';

// History service provider
final historyServiceProvider = Provider<HistoryService>((ref) => HistoryService());

// History stream provider
final historyStreamProvider = StreamProvider.family<List<HistoryItem>, HistoryType?>((ref, filterType) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  
  return ref.watch(historyServiceProvider).getHistoryStream(user.uid, filterType: filterType);
});

// History filter state
final historyFilterProvider = StateProvider<HistoryType?>((ref) => null);

// History state
class HistoryState {
  final bool isLoading;
  final String? error;

  HistoryState({
    this.isLoading = false,
    this.error,
  });

  HistoryState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return HistoryState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// History notifier
class HistoryNotifier extends StateNotifier<HistoryState> {
  final HistoryService _historyService;
  final String _userId;

  HistoryNotifier(this._historyService, this._userId) : super(HistoryState());

  Future<void> addHistoryItem(HistoryItem item) async {
    try {
      await _historyService.addHistoryItem(item);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteHistoryItem(String itemId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _historyService.deleteHistoryItem(_userId, itemId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> clearAllHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _historyService.clearAllHistory(_userId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// History provider
final historyProvider = StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('User not authenticated');
  
  return HistoryNotifier(
    ref.watch(historyServiceProvider),
    user.uid,
  );
});
