/// Минимальная длительность состояния загрузки при повторе упавшего запроса:
/// спиннер или скелетоны должны успеть появиться и не мелькнуть на быстром
/// ответе.
const Duration retryLoadingMinDuration = Duration(milliseconds: 400);

/// Таймер минимальной длительности загрузки: на повторе — [retryLoadingMinDuration],
/// на первой загрузке — уже завершённый, чтобы не задерживать экран.
Future<void> retryLoadingDelay({required bool isRetry}) => isRetry
    ? Future<void>.delayed(retryLoadingMinDuration)
    : Future<void>.value();
