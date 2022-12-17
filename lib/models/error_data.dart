class ErrorData {
  const ErrorData(this.exception, [this.stackTrace]);

  final Object exception;
  final StackTrace? stackTrace;
}
