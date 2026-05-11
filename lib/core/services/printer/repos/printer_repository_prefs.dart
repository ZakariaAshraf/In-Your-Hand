import '../../../cache/cache_helper.dart';

class PrinterRepositoryPrefs {
  const PrinterRepositoryPrefs();

  String? getSelectedMacAddress() =>
      CacheHelper.getString(key: CacheKeys.selectedPrinterMacAddress)?.trim();

  Future<void> saveSelectedMacAddress(String macAddress) async {
    final v = macAddress.trim();
    if (v.isEmpty) return;
    await CacheHelper.set(key: CacheKeys.selectedPrinterMacAddress, value: v);
  }

  Future<void> clearSelectedMacAddress() async {
    await CacheHelper.remove(key: CacheKeys.selectedPrinterMacAddress);
  }
}

