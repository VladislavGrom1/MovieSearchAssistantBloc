import 'package:equatable/equatable.dart';

class StorageUsage extends Equatable {
  final int cacheBytes;

  final int libraryBytes;

  const StorageUsage({
    required this.cacheBytes,
    required this.libraryBytes,
  });

  @override
  List<Object?> get props => [cacheBytes, libraryBytes];
}
