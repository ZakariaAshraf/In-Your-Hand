/// Single row extracted from CSV / Excel for bulk client onboarding.
class ClientImportRow {
  const ClientImportRow({
    required this.name,
    this.phone,
    this.notes,
  });

  /// Column A (required).
  final String name;

  /// Column B (optional).
  final String? phone;

  /// Column C — notes or starting balance text (optional).
  final String? notes;
}
