class DashboardData {
  final double totalAmount;
  final double totalPaid;
  final double totalUnpaid;
  final int totalOrders;
  final int clientsWithDebt;
  final List<String> clientsIds;

  DashboardData({
    required this.clientsWithDebt,
    required this.totalAmount,
    required this.totalPaid,
    required this.totalUnpaid,
    required this.totalOrders,
    required this.clientsIds,
  });
}