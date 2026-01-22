//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'related_film_response_items.g.dart';

/// RelatedFilmResponseItems
///
/// Properties:
/// * [kinopoiskId]
/// * [nameRu]
/// * [nameEn]
/// * [nameOriginal]
/// * [posterUrl]
/// * [posterUrlPreview]
/// * [relationType]
@BuiltValue()
abstract class RelatedFilmResponseItems
    implements
        Built<RelatedFilmResponseItems, RelatedFilmResponseItemsBuilder> {
  @BuiltValueField(wireName: r'kinopoiskId')
  int? get kinopoiskId;

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
  RelatedFilmResponseItemsRelationTypeEnum? get relationType;
  // enum relationTypeEnum {  SEQUEL,  PREQUEL,  REMAKE,  SIMILAR,  VERSION,  SPOOFS,  SPOOFED,  SPIN_OFF,  SPUN_OFF_FROM,  REFERENCES,  REFERENCES_IN,  EDITED_FROM,  EDITED_INTO,  ALTERNATE_LANGUAGE,  };

  RelatedFilmResponseItems._();

  factory RelatedFilmResponseItems(
          [void updates(RelatedFilmResponseItemsBuilder b)]) =
      _$RelatedFilmResponseItems;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RelatedFilmResponseItemsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RelatedFilmResponseItems> get serializer =>
      _$RelatedFilmResponseItemsSerializer();
}

class _$RelatedFilmResponseItemsSerializer
    implements PrimitiveSerializer<RelatedFilmResponseItems> {
  @override
  final Iterable<Type> types = const [
    RelatedFilmResponseItems,
    _$RelatedFilmResponseItems
  ];

  @override
  final String wireName = r'RelatedFilmResponseItems';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RelatedFilmResponseItems object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.kinopoiskId != null) {
      yield r'kinopoiskId';
      yield serializers.serialize(
        object.kinopoiskId,
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
        specifiedType: const FullType(RelatedFilmResponseItemsRelationTypeEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RelatedFilmResponseItems object, {
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
    required RelatedFilmResponseItemsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'kinopoiskId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.kinopoiskId = valueDes;
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
                const FullType(RelatedFilmResponseItemsRelationTypeEnum),
          ) as RelatedFilmResponseItemsRelationTypeEnum;
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
  RelatedFilmResponseItems deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RelatedFilmResponseItemsBuilder();
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

class RelatedFilmResponseItemsRelationTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'SEQUEL')
  static const RelatedFilmResponseItemsRelationTypeEnum SEQUEL =
      _$relatedFilmResponseItemsRelationTypeEnum_SEQUEL;
  @BuiltValueEnumConst(wireName: r'PREQUEL')
  static const RelatedFilmResponseItemsRelationTypeEnum PREQUEL =
      _$relatedFilmResponseItemsRelationTypeEnum_PREQUEL;
  @BuiltValueEnumConst(wireName: r'REMAKE')
  static const RelatedFilmResponseItemsRelationTypeEnum REMAKE =
      _$relatedFilmResponseItemsRelationTypeEnum_REMAKE;
  @BuiltValueEnumConst(wireName: r'SIMILAR')
  static const RelatedFilmResponseItemsRelationTypeEnum SIMILAR =
      _$relatedFilmResponseItemsRelationTypeEnum_SIMILAR;
  @BuiltValueEnumConst(wireName: r'VERSION')
  static const RelatedFilmResponseItemsRelationTypeEnum VERSION =
      _$relatedFilmResponseItemsRelationTypeEnum_VERSION;
  @BuiltValueEnumConst(wireName: r'SPOOFS')
  static const RelatedFilmResponseItemsRelationTypeEnum SPOOFS =
      _$relatedFilmResponseItemsRelationTypeEnum_SPOOFS;
  @BuiltValueEnumConst(wireName: r'SPOOFED')
  static const RelatedFilmResponseItemsRelationTypeEnum SPOOFED =
      _$relatedFilmResponseItemsRelationTypeEnum_SPOOFED;
  @BuiltValueEnumConst(wireName: r'SPIN_OFF')
  static const RelatedFilmResponseItemsRelationTypeEnum SPIN_OFF =
      _$relatedFilmResponseItemsRelationTypeEnum_SPIN_OFF;
  @BuiltValueEnumConst(wireName: r'SPUN_OFF_FROM')
  static const RelatedFilmResponseItemsRelationTypeEnum SPUN_OFF_FROM =
      _$relatedFilmResponseItemsRelationTypeEnum_SPUN_OFF_FROM;
  @BuiltValueEnumConst(wireName: r'REFERENCES')
  static const RelatedFilmResponseItemsRelationTypeEnum REFERENCES =
      _$relatedFilmResponseItemsRelationTypeEnum_REFERENCES;
  @BuiltValueEnumConst(wireName: r'REFERENCES_IN')
  static const RelatedFilmResponseItemsRelationTypeEnum REFERENCES_IN =
      _$relatedFilmResponseItemsRelationTypeEnum_REFERENCES_IN;
  @BuiltValueEnumConst(wireName: r'EDITED_FROM')
  static const RelatedFilmResponseItemsRelationTypeEnum EDITED_FROM =
      _$relatedFilmResponseItemsRelationTypeEnum_EDITED_FROM;
  @BuiltValueEnumConst(wireName: r'EDITED_INTO')
  static const RelatedFilmResponseItemsRelationTypeEnum EDITED_INTO =
      _$relatedFilmResponseItemsRelationTypeEnum_EDITED_INTO;
  @BuiltValueEnumConst(wireName: r'ALTERNATE_LANGUAGE')
  static const RelatedFilmResponseItemsRelationTypeEnum ALTERNATE_LANGUAGE =
      _$relatedFilmResponseItemsRelationTypeEnum_ALTERNATE_LANGUAGE;

  static Serializer<RelatedFilmResponseItemsRelationTypeEnum> get serializer =>
      _$relatedFilmResponseItemsRelationTypeEnumSerializer;

  const RelatedFilmResponseItemsRelationTypeEnum._(String name) : super(name);

  static BuiltSet<RelatedFilmResponseItemsRelationTypeEnum> get values =>
      _$relatedFilmResponseItemsRelationTypeEnumValues;
  static RelatedFilmResponseItemsRelationTypeEnum valueOf(String name) =>
      _$relatedFilmResponseItemsRelationTypeEnumValueOf(name);
}
