// Forces to implement all functions that Exception has.
  // This allows us to override calls of .toString() on exceptions to now printe a stringed message
class HttpException implements Exception {
  final String message;

  HttpException(this.message);

  // Overrides the source to string for exception
  @override
  String toString() {
    return message;
    // return super.toString(); // Instance of HttpException
   }
}