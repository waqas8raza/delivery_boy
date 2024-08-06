import 'package:http/http.dart' as http;

abstract class Middleware<T, R> {
  T next(R response);
}
