
const Duration retryLoadingMinDuration = Duration(milliseconds: 400);

Future<void> retryLoadingDelay({required bool isRetry}) => isRetry
    ? Future<void>.delayed(retryLoadingMinDuration)
    : Future<void>.value();
