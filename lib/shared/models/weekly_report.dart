import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportStatus { draft, finalized }

class WeeklyReport {
  final String id;
  final String weekKey;
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final double totalWeightKg;
  final int missingEntriesCount;
  final int noMilkEntriesCount;
  final int editedEntriesCount;
  final int supplierCount;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? finalizedAt;
  final String? finalizedBy;

  const WeeklyReport({
    required this.id,
    required this.weekKey,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.totalWeightKg,
    required this.missingEntriesCount,
    required this.noMilkEntriesCount,
    required this.editedEntriesCount,
    required this.supplierCount,
    required this.status,
    required this.createdAt,
    this.finalizedAt,
    this.finalizedBy,
  });

  bool get isFinalized => status == ReportStatus.finalized;

  factory WeeklyReport.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return WeeklyReport(
      id: doc.id,
      weekKey: d['weekKey'] as String,
      weekStartDate: (d['weekStartDate'] as Timestamp).toDate(),
      weekEndDate: (d['weekEndDate'] as Timestamp).toDate(),
      totalWeightKg: (d['totalWeightKg'] as num?)?.toDouble() ?? 0,
      missingEntriesCount: (d['missingEntriesCount'] as num?)?.toInt() ?? 0,
      noMilkEntriesCount: (d['noMilkEntriesCount'] as num?)?.toInt() ?? 0,
      editedEntriesCount: (d['editedEntriesCount'] as num?)?.toInt() ?? 0,
      supplierCount: (d['supplierCount'] as num?)?.toInt() ?? 0,
      status: d['status'] == 'finalized'
          ? ReportStatus.finalized
          : ReportStatus.draft,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      finalizedAt: (d['finalizedAt'] as Timestamp?)?.toDate(),
      finalizedBy: d['finalizedBy'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'weekKey': weekKey,
        'weekStartDate': Timestamp.fromDate(weekStartDate),
        'weekEndDate': Timestamp.fromDate(weekEndDate),
        'totalWeightKg': totalWeightKg,
        'missingEntriesCount': missingEntriesCount,
        'noMilkEntriesCount': noMilkEntriesCount,
        'editedEntriesCount': editedEntriesCount,
        'supplierCount': supplierCount,
        'status': status == ReportStatus.finalized ? 'finalized' : 'draft',
        'createdAt': Timestamp.fromDate(createdAt),
        'finalizedAt':
            finalizedAt != null ? Timestamp.fromDate(finalizedAt!) : null,
        'finalizedBy': finalizedBy,
      };

  WeeklyReport copyWith({
    double? totalWeightKg,
    int? missingEntriesCount,
    int? noMilkEntriesCount,
    int? editedEntriesCount,
    int? supplierCount,
    ReportStatus? status,
    DateTime? finalizedAt,
    String? finalizedBy,
  }) =>
      WeeklyReport(
        id: id,
        weekKey: weekKey,
        weekStartDate: weekStartDate,
        weekEndDate: weekEndDate,
        totalWeightKg: totalWeightKg ?? this.totalWeightKg,
        missingEntriesCount: missingEntriesCount ?? this.missingEntriesCount,
        noMilkEntriesCount: noMilkEntriesCount ?? this.noMilkEntriesCount,
        editedEntriesCount: editedEntriesCount ?? this.editedEntriesCount,
        supplierCount: supplierCount ?? this.supplierCount,
        status: status ?? this.status,
        createdAt: createdAt,
        finalizedAt: finalizedAt ?? this.finalizedAt,
        finalizedBy: finalizedBy ?? this.finalizedBy,
      );
}
