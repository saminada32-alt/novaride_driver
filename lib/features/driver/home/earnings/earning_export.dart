import 'package:intl/intl.dart';
import 'model/earning_model.dart';

String buildEarningsCsv(EarningModel e) {
  final dateFmt = DateFormat('yyyy-MM-dd HH:mm');
  final buf = StringBuffer()
    ..writeln('NovaRide Driver Earnings Statement')
    ..writeln('Generated,${dateFmt.format(DateTime.now())}')
    ..writeln()
    ..writeln('Summary')
    ..writeln('Total,${e.total.toStringAsFixed(2)}')
    ..writeln('Today,${e.today.toStringAsFixed(2)}')
    ..writeln('Week,${e.week.toStringAsFixed(2)}')
    ..writeln('Month,${e.month.toStringAsFixed(2)}')
    ..writeln('Trips,${e.trips}')
    ..writeln()
    ..writeln('Recent Rides')
    ..writeln('RideId,Amount,Date');

  for (final r in e.recentRides) {
    buf.writeln(
      '${r.rideId},${r.amount.toStringAsFixed(2)},${dateFmt.format(r.date)}',
    );
  }

  return buf.toString();
}
