// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'similar_film_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SimilarFilmResponse extends SimilarFilmResponse {
  @override
  final int total;
  @override
  final BuiltList<SimilarFilmResponseItems> items;

  factory _$SimilarFilmResponse(
          [void Function(SimilarFilmResponseBuilder)? updates]) =>
      (SimilarFilmResponseBuilder()..update(updates))._build();

  _$SimilarFilmResponse._({required this.total, required this.items})
      : super._();
  @override
  SimilarFilmResponse rebuild(
          void Function(SimilarFilmResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SimilarFilmResponseBuilder toBuilder() =>
      SimilarFilmResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SimilarFilmResponse &&
        total == other.total &&
        items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SimilarFilmResponse')
          ..add('total', total)
          ..add('items', items))
        .toString();
  }
}

class SimilarFilmResponseBuilder
    implements Builder<SimilarFilmResponse, SimilarFilmResponseBuilder> {
  _$SimilarFilmResponse? _$v;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  ListBuilder<SimilarFilmResponseItems>? _items;
  ListBuilder<SimilarFilmResponseItems> get items =>
      _$this._items ??= ListBuilder<SimilarFilmResponseItems>();
  set items(ListBuilder<SimilarFilmResponseItems>? items) =>
      _$this._items = items;

  SimilarFilmResponseBuilder() {
    SimilarFilmResponse._defaults(this);
  }

  SimilarFilmResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _total = $v.total;
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SimilarFilmResponse other) {
    _$v = other as _$SimilarFilmResponse;
  }

  @override
  void update(void Function(SimilarFilmResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SimilarFilmResponse build() => _build();

  _$SimilarFilmResponse _build() {
    _$SimilarFilmResponse _$result;
    try {
      _$result = _$v ??
          _$SimilarFilmResponse._(
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'SimilarFilmResponse', 'total'),
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'SimilarFilmResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
