class AppConstants {
  static const double maxWeightKg = 9999;
  static const double minWeightKg = 0.1;
  static const int maxWeightDecimals = 1;
  static const int maxNotesLength = 500;
  static const int maxEditReasonLength = 200;
  static const int maxSupplierNameLength = 50;
  static const int minSupplierNameLength = 2;
  static const int maxVillageLength = 30;
  static const int maxAddressLength = 100;
  static const int highWeightThreshold = 500;
  static const int absenceAlertDays = 3;
  static const int absenceBadgeDays = 2;
  static const int undoToastSeconds = 30;
  static const double missingEntriesWarningPercent = 0.20;
  static const int finalizationCountdownSeconds = 3;
  static const int deviceTimeDriftHours = 1;

  // Firestore collections (under users/{uid}/)
  static const String suppliersCollection = 'suppliers';
  static const String entriesCollection = 'milk_entries';
  static const String reportsCollection = 'weekly_reports';
}
