class DashboardStats {
  final int totalSuppliers;
  final int receivedToday;
  final int pendingToday;
  final int noMilkToday;
  final int editedToday;
  final double todayWeight;
  final double weekWeight;

  const DashboardStats({
    required this.totalSuppliers,
    required this.receivedToday,
    required this.pendingToday,
    required this.noMilkToday,
    required this.editedToday,
    required this.todayWeight,
    required this.weekWeight,
  });
}
