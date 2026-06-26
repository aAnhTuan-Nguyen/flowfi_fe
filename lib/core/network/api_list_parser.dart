typedef JsonMap = Map<String, Object?>;

List<JsonMap> readApiList(Object? responseBody) {
  final list = _findList(responseBody);
  if (list == null) {
    throw const FormatException('API response does not contain a list.');
  }
  return list.map(_asJsonMap).toList(growable: false);
}

JsonMap readApiObject(Object? responseBody) {
  final source = _unwrapData(responseBody);
  if (source is Map<String, Object?>) {
    return source;
  }
  if (source is Map) {
    return JsonMap.from(source);
  }
  throw const FormatException('API response does not contain an object.');
}

Object? _unwrapData(Object? value) {
  if (value is Map<String, Object?> && value['data'] != null) {
    return value['data'];
  }
  if (value is Map && value['data'] != null) {
    return value['data'];
  }
  return value;
}

List<Object?>? _findList(Object? value) {
  final source = _unwrapData(value);
  if (source is List) {
    return source.cast<Object?>();
  }
  if (source is Map<String, Object?>) {
    final items = source['items'] ?? source['results'] ?? source['rows'];
    if (items is List) {
      return items.cast<Object?>();
    }
  }
  if (source is Map) {
    final items = source['items'] ?? source['results'] ?? source['rows'];
    if (items is List) {
      return items.cast<Object?>();
    }
  }
  return null;
}

JsonMap _asJsonMap(Object? value) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return JsonMap.from(value);
  }
  throw const FormatException('API list item is not an object.');
}
