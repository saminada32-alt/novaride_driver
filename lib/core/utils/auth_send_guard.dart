/// Minimum loading on login — send-otp now waits for SMS (~35s max).
Future<T> withMinAuthLoading<T>(
  Future<T> task, {
  Duration min = const Duration(milliseconds: 800),
}) async {
  final sw = Stopwatch()..start();
  final result = await task;
  final left = min - sw.elapsed;
  if (left > Duration.zero) await Future.delayed(left);
  return result;
}
