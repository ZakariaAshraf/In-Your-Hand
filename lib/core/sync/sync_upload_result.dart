/// Aggregate outcome from [SyncEngine.uploadPendingData].
final class SyncUploadResult {
  const SyncUploadResult({
    required this.failureMessages,
    this.skippedDueToConcurrency = false,
  });

  final List<String> failureMessages;
  final bool skippedDueToConcurrency;

  bool get hasFailures => failureMessages.isNotEmpty;
}
