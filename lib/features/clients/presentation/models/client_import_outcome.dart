/// Result of an import-from-picker flow initiated from UI.
enum ClientImportResult { success, cancelled, failure }

class ClientImportOutcome {
  const ClientImportOutcome._({
    required this.result,
    this.importedCount = 0,
    this.errorMessage,
  });

  factory ClientImportOutcome.success(int count) =>
      ClientImportOutcome._(result: ClientImportResult.success, importedCount: count);

  factory ClientImportOutcome.cancelled() =>
      const ClientImportOutcome._(result: ClientImportResult.cancelled);

  factory ClientImportOutcome.failure(String message) =>
      ClientImportOutcome._(result: ClientImportResult.failure, errorMessage: message);

  final ClientImportResult result;
  final int importedCount;
  final String? errorMessage;
}
