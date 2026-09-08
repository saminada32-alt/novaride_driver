import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import 'model/earning_model.dart';

String buildEarningsCsv(EarningModel e, AppLocalizations t) {
  final dateFmt = DateFormat('yyyy-MM-dd HH:mm');
  final buf = StringBuffer()
    ..writeln('NovaRide Driver Earnings Statement')
    ..writeln('${t.csvGeneratedOn},${dateFmt.format(DateTime.now())}')
    ..writeln()
    ..writeln(t.csvSummary)
    ..writeln('${t.totalEarnings},${e.total.toStringAsFixed(2)}')
    ..writeln('${t.today},${e.today.toStringAsFixed(2)}')
    ..writeln('${t.weekly},${e.week.toStringAsFixed(2)}')
    ..writeln('${t.monthly},${e.month.toStringAsFixed(2)}')
    ..writeln('${t.trips},${e.trips}')
    ..writeln()
    ..writeln(t.csvRecentRides)
    ..writeln('${t.csvRideId},${t.csvAmount},${t.csvDate}');

  for (final r in e.recentRides) {
    buf.writeln(
      '${r.rideId},${r.amount.toStringAsFixed(2)},${dateFmt.format(r.date)}',
    );
  }

  return buf.toString();
}
