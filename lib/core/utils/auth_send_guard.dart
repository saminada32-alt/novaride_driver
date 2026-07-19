/// Minimum loading on login — brief spinner so UI does not flash.
Future<T> withMinAuthLoading<T>(
  Future<T> task, {
  Duration min = const Duration(milliseconds: 400),
}) async {
  final sw = Stopwatch()..start();
  final result = await task;
  final left = min - sw.elapsed;
  if (left > Duration.zero) await Future.delayed(left);
  return result;
}
