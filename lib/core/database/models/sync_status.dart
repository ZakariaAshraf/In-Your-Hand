enum SyncStatus {
  synced(0),
  pending(1);

  const SyncStatus(this.code);

  final int code;

  static SyncStatus fromCode(int? code) =>
      (code ?? 1) == 0 ? SyncStatus.synced : SyncStatus.pending;
}

