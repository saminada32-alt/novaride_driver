class EarningModel {
  final double total, today, week, month;
  final int trips;

  final List<DailyEarning> daily;
  final List<DailyEarning> weekly;
  final List<DailyEarning> monthly;

  final List<RecentRide> recentRides;

  const EarningModel({
    required this.total,
    required this.today,
    required this.week,
    required this.month,
    required this.trips,
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.recentRides,
  });

  factory EarningModel.fromJson(Map<String, dynamic> json) {
    return EarningModel(
      total: _toDouble(json['totalEarnings']),
      today: _toDouble(json['todayEarnings']),
      week: _toDouble(json['weekEarnings']),
      month: _toDouble(json['monthEarnings']),
      trips: json['completedRides'] ?? 0,
      daily: _parseList(json['daily']),
      weekly: _parseList(json['weekly']),
      monthly: _parseList(json['monthly']),
      recentRides: (json['recentRides'] as List? ?? [])
          .map((e) => RecentRide.fromJson(e))
          .toList(),
    );
  }

  static double _toDouble(dynamic v) => double.tryParse(v.toString()) ?? 0.0;

  static List<DailyEarning> _parseList(dynamic list) {
    if (list is! List) return [];
    return list.map((e) {
      return DailyEarning(
        label: e['label'] ?? '',
        amount: _toDouble(e['amount']),
      );
    }).toList();
  }
}

class DailyEarning {
  final String label;
  final double amount;

  const DailyEarning({required this.label, required this.amount});
}

class RecentRide {
  final int rideId;
  final double amount;
  final DateTime date;

  const RecentRide({
    required this.rideId,
    required this.amount,
    required this.date,
  });

  factory RecentRide.fromJson(Map<String, dynamic> json) {
    return RecentRide(
      rideId: json['rideId'] ?? 0,
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      date: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
