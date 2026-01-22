//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:generated/src/model/similar_film_response_items.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'similar_film_response.g.dart';

/// SimilarFilmResponse
///
/// Properties:
/// * [total]
/// * [items]
@BuiltValue()
abstract class SimilarFilmResponse
    implements Built<SimilarFilmResponse, SimilarFilmResponseBuilder> {
  @BuiltValueField(wireName: r'total')
  int get total;

  @BuiltValueField(wireName: r'items')
  BuiltList<SimilarFilmResponseItems> get items;

  SimilarFilmResponse._();

  factory SimilarFilmResponse([void updates(SimilarFilmResponseBuilder b)]) =
      _$SimilarFilmResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SimilarFilmResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SimilarFilmResponse> get serializer =>
      _$SimilarFilmResponseSerializer();
}

class _$SimilarFilmResponseSerializer
    implements PrimitiveSerializer<SimilarFilmResponse> {
  @override
  final Iterable<Type> types = const [
    SimilarFilmResponse,
    _$SimilarFilmResponse
  ];

  @override
  final String wireName = r'SimilarFilmResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SimilarFilmResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType:
          const FullType(BuiltList, [FullType(SimilarFilmResponseItems)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SimilarFilmResponse object, {
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
    required SimilarFilmResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.total = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(SimilarFilmResponseItems)]),
          ) as BuiltList<SimilarFilmResponseItems>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SimilarFilmResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SimilarFilmResponseBuilder();
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
