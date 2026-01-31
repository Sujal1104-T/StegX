import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stegx/data/models/history_model.dart';

class HistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get history collection reference for a user
  CollectionReference _getUserHistoryCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('history');
  }

  // Add history item
  Future<void> addHistoryItem(HistoryItem item) async {
    try {
      await _getUserHistoryCollection(item.userId).add(item.toMap());
    } catch (e) {
      throw Exception('Failed to add history item: ${e.toString()}');
    }
  }

  // Get history stream (real-time updates)
  Stream<List<HistoryItem>> getHistoryStream(String userId, {HistoryType? filterType}) {
    Query query = _getUserHistoryCollection(userId)
        .orderBy('timestamp', descending: true);

    if (filterType != null) {
      query = query.where('type', isEqualTo: filterType.name);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return HistoryItem.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get paginated history
  Future<List<HistoryItem>> getHistory(
    String userId, {
    int limit = 20,
    DocumentSnapshot? startAfter,
    HistoryType? filterType,
  }) async {
    try {
      Query query = _getUserHistoryCollection(userId)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (filterType != null) {
        query = query.where('type', isEqualTo: filterType.name);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        return HistoryItem.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch history: ${e.toString()}');
    }
  }

  // Delete single history item
  Future<void> deleteHistoryItem(String userId, String itemId) async {
    try {
      await _getUserHistoryCollection(userId).doc(itemId).delete();
    } catch (e) {
      throw Exception('Failed to delete history item: ${e.toString()}');
    }
  }

  // Clear all history
  Future<void> clearAllHistory(String userId) async {
    try {
      final snapshot = await _getUserHistoryCollection(userId).get();
      final batch = _firestore.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear history: ${e.toString()}');
    }
  }

  // Get history count
  Future<int> getHistoryCount(String userId) async {
    try {
      final snapshot = await _getUserHistoryCollection(userId).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
