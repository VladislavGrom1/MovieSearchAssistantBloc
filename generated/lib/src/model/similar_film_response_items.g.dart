// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'similar_film_response_items.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const SimilarFilmResponseItemsRelationTypeEnum
    _$similarFilmResponseItemsRelationTypeEnum_SIMILAR =
    const SimilarFilmResponseItemsRelationTypeEnum._('SIMILAR');

SimilarFilmResponseItemsRelationTypeEnum
    _$similarFilmResponseItemsRelationTypeEnumValueOf(String name) {
  switch (name) {
    case 'SIMILAR':
      return _$similarFilmResponseItemsRelationTypeEnum_SIMILAR;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<SimilarFilmResponseItemsRelationTypeEnum>
    _$similarFilmResponseItemsRelationTypeEnumValues = BuiltSet<
        SimilarFilmResponseItemsRelationTypeEnum>(const <SimilarFilmResponseItemsRelationTypeEnum>[
  _$similarFilmResponseItemsRelationTypeEnum_SIMILAR,
]);

Serializer<SimilarFilmResponseItemsRelationTypeEnum>
    _$similarFilmResponseItemsRelationTypeEnumSerializer =
    _$SimilarFilmResponseItemsRelationTypeEnumSerializer();

class _$SimilarFilmResponseItemsRelationTypeEnumSerializer
    implements PrimitiveSerializer<SimilarFilmResponseItemsRelationTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'SIMILAR': 'SIMILAR',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'SIMILAR': 'SIMILAR',
  };

  @override
  final Iterable<Type> types = const <Type>[
    SimilarFilmResponseItemsRelationTypeEnum
  ];
  @override
  final String wireName = 'SimilarFilmResponseItemsRelationTypeEnum';

  @override
  Object serialize(Serializers serializers,
          SimilarFilmResponseItemsRelationTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  SimilarFilmResponseItemsRelationTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      SimilarFilmResponseItemsRelationTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$SimilarFilmResponseItems extends SimilarFilmResponseItems {
  @override
  final int? filmId;
  @override
  final String? nameRu;
  @override
  final String? nameEn;
  @override
  final String? nameOriginal;
  @override
  final String? posterUrl;
  @override
  final String? posterUrlPreview;
  @override
  final SimilarFilmResponseItemsRelationTypeEnum? relationType;

  factory _$SimilarFilmResponseItems(
          [void Function(SimilarFilmResponseItemsBuilder)? updates]) =>
      (SimilarFilmResponseItemsBuilder()..update(updates))._build();

  _$SimilarFilmResponseItems._(
      {this.filmId,
      this.nameRu,
      this.nameEn,
      this.nameOriginal,
      this.posterUrl,
      this.posterUrlPreview,
      this.relationType})
      : super._();
  @override
  SimilarFilmResponseItems rebuild(
          void Function(SimilarFilmResponseItemsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SimilarFilmResponseItemsBuilder toBuilder() =>
      SimilarFilmResponseItemsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SimilarFilmResponseItems &&
        filmId == other.filmId &&
        nameRu == other.nameRu &&
        nameEn == other.nameEn &&
        nameOriginal == other.nameOriginal &&
        posterUrl == other.posterUrl &&
        posterUrlPreview == other.posterUrlPreview &&
        relationType == other.relationType;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, filmId.hashCode);
    _$hash = $jc(_$hash, nameRu.hashCode);
    _$hash = $jc(_$hash, nameEn.hashCode);
    _$hash = $jc(_$hash, nameOriginal.hashCode);
    _$hash = $jc(_$hash, posterUrl.hashCode);
    _$hash = $jc(_$hash, posterUrlPreview.hashCode);
    _$hash = $jc(_$hash, relationType.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SimilarFilmResponseItems')
          ..add('filmId', filmId)
          ..add('nameRu', nameRu)
          ..add('nameEn', nameEn)
          ..add('nameOriginal', nameOriginal)
          ..add('posterUrl', posterUrl)
          ..add('posterUrlPreview', posterUrlPreview)
          ..add('relationType', relationType))
        .toString();
  }
}

class SimilarFilmResponseItemsBuilder
    implements
        Builder<SimilarFilmResponseItems, SimilarFilmResponseItemsBuilder> {
  _$SimilarFilmResponseItems? _$v;

  int? _filmId;
  int? get filmId => _$this._filmId;
  set filmId(int? filmId) => _$this._filmId = filmId;

  String? _nameRu;
  String? get nameRu => _$this._nameRu;
  set nameRu(String? nameRu) => _$this._nameRu = nameRu;

  String? _nameEn;
  String? get nameEn => _$this._nameEn;
  set nameEn(String? nameEn) => _$this._nameEn = nameEn;

  String? _nameOriginal;
  String? get nameOriginal => _$this._nameOriginal;
  set nameOriginal(String? nameOriginal) => _$this._nameOriginal = nameOriginal;

  String? _posterUrl;
  String? get posterUrl => _$this._posterUrl;
  set posterUrl(String? posterUrl) => _$this._posterUrl = posterUrl;

  String? _posterUrlPreview;
  String? get posterUrlPreview => _$this._posterUrlPreview;
  set posterUrlPreview(String? posterUrlPreview) =>
      _$this._posterUrlPreview = posterUrlPreview;

  SimilarFilmResponseItemsRelationTypeEnum? _relationType;
  SimilarFilmResponseItemsRelationTypeEnum? get relationType =>
      _$this._relationType;
  set relationType(SimilarFilmResponseItemsRelationTypeEnum? relationType) =>
      _$this._relationType = relationType;

  SimilarFilmResponseItemsBuilder() {
    SimilarFilmResponseItems._defaults(this);
  }

  SimilarFilmResponseItemsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _filmId = $v.filmId;
      _nameRu = $v.nameRu;
      _nameEn = $v.nameEn;
      _nameOriginal = $v.nameOriginal;
      _posterUrl = $v.posterUrl;
      _posterUrlPreview = $v.posterUrlPreview;
      _relationType = $v.relationType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SimilarFilmResponseItems other) {
    _$v = other as _$SimilarFilmResponseItems;
  }

  @override
  void update(void Function(SimilarFilmResponseItemsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SimilarFilmResponseItems build() => _build();

  _$SimilarFilmResponseItems _build() {
    final _$result = _$v ??
        _$SimilarFilmResponseItems._(
          filmId: filmId,
          nameRu: nameRu,
          nameEn: nameEn,
          nameOriginal: nameOriginal,
          posterUrl: posterUrl,
          posterUrlPreview: posterUrlPreview,
          relationType: relationType,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
