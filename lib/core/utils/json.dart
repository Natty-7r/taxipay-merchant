/// Small helpers so model mappers stay readable.
typedef Json = Map<String, dynamic>;

List<T> listOf<T>(Object? value, T Function(Json) item) =>
    ((value as List?) ?? const []).map((e) => item(e as Json)).toList();

num numOf(Object? value) => value is num ? value : num.tryParse('$value') ?? 0;

Json? objOf(Object? value) => value as Json?;
