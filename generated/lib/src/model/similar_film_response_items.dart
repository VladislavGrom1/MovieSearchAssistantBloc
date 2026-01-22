//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'similar_film_response_items.g.dart';

/// SimilarFilmResponseItems
///
/// Properties:
/// * [filmId]
/// * [nameRu]
/// * [nameEn]
/// * [nameOriginal]
/// * [posterUrl]
/// * [posterUrlPreview]
/// * [relationType]
@BuiltValue()
abstract class SimilarFilmResponseItems
    implements
        Built<SimilarFilmResponseItems, SimilarFilmResponseItemsBuilder> {
  @BuiltValueField(wireName: r'filmId')
  int? get filmId;

  @BuiltValueField(wireName: r'nameRu')
  String? get nameRu;

  @BuiltValueField(wireName: r'nameEn')
  String? get nameEn;

  @BuiltValueField(wireName: r'nameOriginal')
  String? get nameOriginal;

  @BuiltValueField(wireName: r'posterUrl')
  String? get posterUrl;

  @BuiltValueField(wireName: r'posterUrlPreview')
  String? get posterUrlPreview;

  @BuiltValueField(wireName: r'relationType')
  SimilarFilmResponseItemsRelationTypeEnum? get relationType;
  // enum relationTypeEnum {  SIMILAR,  };

  SimilarFilmResponseItems._();

  factory SimilarFilmResponseItems(
          [void updates(SimilarFilmResponseItemsBuilder b)]) =
      _$SimilarFilmResponseItems;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SimilarFilmResponseItemsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SimilarFilmResponseItems> get serializer =>
      _$SimilarFilmResponseItemsSerializer();
}

class _$SimilarFilmResponseItemsSerializer
    implements PrimitiveSerializer<SimilarFilmResponseItems> {
  @override
  final Iterable<Type> types = const [
    SimilarFilmResponseItems,
    _$SimilarFilmResponseItems
  ];

  @override
  final String wireName = r'SimilarFilmResponseItems';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SimilarFilmResponseItems object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.filmId != null) {
      yield r'filmId';
      yield serializers.serialize(
        object.filmId,
        specifiedType: const FullType(int),
      );
    }
    if (object.nameRu != null) {
      yield r'nameRu';
      yield serializers.serialize(
        object.nameRu,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.nameEn != null) {
      yield r'nameEn';
      yield serializers.serialize(
        object.nameEn,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.nameOriginal != null) {
      yield r'nameOriginal';
      yield serializers.serialize(
        object.nameOriginal,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.posterUrl != null) {
      yield r'posterUrl';
      yield serializers.serialize(
        object.posterUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.posterUrlPreview != null) {
      yield r'posterUrlPreview';
      yield serializers.serialize(
        object.posterUrlPreview,
        specifiedType: const FullType(String),
      );
    }
    if (object.relationType != null) {
      yield r'relationType';
      yield serializers.serialize(
        object.relationType,
        specifiedType: const FullType(SimilarFilmResponseItemsRelationTypeEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SimilarFilmResponseItems object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SimilarFilmResponseItemsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'filmId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.filmId = valueDes;
          break;
        case r'nameRu':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nameRu = valueDes;
          break;
        case r'nameEn':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nameEn = valueDes;
          break;
        case r'nameOriginal':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nameOriginal = valueDes;
          break;
        case r'posterUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.posterUrl = valueDes;
          break;
        case r'posterUrlPreview':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.posterUrlPreview = valueDes;
          break;
        case r'relationType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(SimilarFilmResponseItemsRelationTypeEnum),
          ) as SimilarFilmResponseItemsRelationTypeEnum;
          result.relationType = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SimilarFilmResponseItems deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SimilarFilmResponseItemsBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class SimilarFilmResponseItemsRelationTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'SIMILAR')
  static const SimilarFilmResponseItemsRelationTypeEnum SIMILAR =
      _$similarFilmResponseItemsRelationTypeEnum_SIMILAR;

  static Serializer<SimilarFilmResponseItemsRelationTypeEnum> get serializer =>
      _$similarFilmResponseItemsRelationTypeEnumSerializer;

  const SimilarFilmResponseItemsRelationTypeEnum._(String name) : super(name);

  static BuiltSet<SimilarFilmResponseItemsRelationTypeEnum> get values =>
      _$similarFilmResponseItemsRelationTypeEnumValues;
  static SimilarFilmResponseItemsRelationTypeEnum valueOf(String name) =>
      _$similarFilmResponseItemsRelationTypeEnumValueOf(name);
}
