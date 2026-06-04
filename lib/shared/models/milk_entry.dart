import 'package:cloud_firestore/cloud_firestore.dart';

enum EntryStatus { recorded, noMilk }

enum SyncStatus { synced, pending, failed }

class MilkEntry {
  final String id;
  final String supplierId;
  final String supplierName;
  final DateTime date;
  final String dateKey;
  final String weekKey;
  final double? originalWeightKg;
  final double? currentWeightKg;
  final EntryStatus entryStatus;
  final int editCount;
  final String? editReason;
  final DateTime createdAt;
  final DateTime? editedAt;
  final String? editedBy;
  final SyncStatus syncStatus;

  const MilkEntry({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.date,
    required this.dateKey,
    required this.weekKey,
    this.originalWeightKg,
    this.currentWeightKg,
    required this.entryStatus,
    this.editCount = 0,
    this.editReason,
    required this.createdAt,
    this.editedAt,
    this.editedBy,
    this.syncStatus = SyncStatus.synced,
  });

  bool get isEdited => editCount > 0;
  bool get canEdit => editCount < 1;

  factory MilkEntry.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MilkEntry(
      id: doc.id,
      supplierId: d['supplierId'] as String,
      supplierName: d['supplierName'] as String? ?? '',
      date: (d['date'] as Timestamp).toDate(),
      dateKey: d['dateKey'] as String,
      weekKey: d['weekKey'] as String? ?? '',
      originalWeightKg: (d['originalWeightKg'] as num?)?.toDouble(),
      currentWeightKg: (d['currentWeightKg'] as num?)?.toDouble(),
      entryStatus: d['entryStatus'] == 'no_milk'
          ? EntryStatus.noMilk
          : EntryStatus.recorded,
      editCount: (d['editCount'] as num?)?.toInt() ?? 0,
      editReason: d['editReason'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      editedAt: (d['editedAt'] as Timestamp?)?.toDate(),
      editedBy: d['editedBy'] as String?,
      syncStatus: SyncStatus.synced,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'supplierId': supplierId,
        'supplierName': supplierName,
        'date': Timestamp.fromDate(date),
        'dateKey': dateKey,
        'weekKey': weekKey,
        'originalWeightKg': originalWeightKg,
        'currentWeightKg': currentWeightKg,
        'entryStatus':
            entryStatus == EntryStatus.noMilk ? 'no_milk' : 'recorded',
        'editCount': editCount,
        'editReason': editReason,
        'createdAt': Timestamp.fromDate(createdAt),
        'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
        'editedBy': editedBy,
      };

  MilkEntry copyWith({
    double? currentWeightKg,
    int? editCount,
    String? editReason,
    DateTime? editedAt,
    String? editedBy,
    SyncStatus? syncStatus,
  }) =>
      MilkEntry(
        id: id,
        supplierId: supplierId,
        supplierName: supplierName,
        date: date,
        dateKey: dateKey,
        weekKey: weekKey,
        originalWeightKg: originalWeightKg,
        currentWeightKg: currentWeightKg ?? this.currentWeightKg,
        entryStatus: entryStatus,
        editCount: editCount ?? this.editCount,
        editReason: editReason ?? this.editReason,
        createdAt: createdAt,
        editedAt: editedAt ?? this.editedAt,
        editedBy: editedBy ?? this.editedBy,
        syncStatus: syncStatus ?? this.syncStatus,
      );
}
