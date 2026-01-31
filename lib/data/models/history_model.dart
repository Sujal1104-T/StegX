import 'package:cloud_firestore/cloud_firestore.dart';

enum HistoryType { encrypt, decrypt }

class HistoryItem {
  final String id;
  final String userId;
  final HistoryType type;
  final DateTime timestamp;
  final String imageName;
  final int? messageLength; // for encryption
  final bool? success; // for decryption

  HistoryItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.timestamp,
    required this.imageName,
    this.messageLength,
    this.success,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'imageName': imageName,
      if (messageLength != null) 'messageLength': messageLength,
      if (success != null) 'success': success,
    };
  }

  // Create from Firestore document
  factory HistoryItem.fromMap(String id, Map<String, dynamic> map) {
    return HistoryItem(
      id: id,
      userId: map['userId'] as String,
      type: HistoryType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => HistoryType.encrypt,
      ),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      imageName: map['imageName'] as String,
      messageLength: map['messageLength'] as int?,
      success: map['success'] as bool?,
    );
  }

  // Copy with method
  HistoryItem copyWith({
    String? id,
    String? userId,
    HistoryType? type,
    DateTime? timestamp,
    String? imageName,
    int? messageLength,
    bool? success,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      imageName: imageName ?? this.imageName,
      messageLength: messageLength ?? this.messageLength,
      success: success ?? this.success,
    );
  }
}
