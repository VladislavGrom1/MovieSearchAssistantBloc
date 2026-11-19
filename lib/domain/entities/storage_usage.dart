import 'package:equatable/equatable.dart';

/// Сколько места занимают две разные вещи: кэш сетевых постеров (его можно
/// очистить без потерь) и библиотека фильмов (её пользователь сохранял).
class StorageUsage extends Equatable {
  /// Размер кэша в байтах.
  final int cacheBytes;

  /// Размер библиотеки в байтах: постеры, скриншоты и обложки коллекций.
  final int libraryBytes;

  const StorageUsage({
    required this.cacheBytes,
    required this.libraryBytes,
  });

  @override
  List<Object?> get props => [cacheBytes, libraryBytes];
}
