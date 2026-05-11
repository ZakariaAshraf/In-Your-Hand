import 'dart:typed_data';

import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

import 'repos/printer_repository_prefs.dart';

class PairedPrinterDevice {
  const PairedPrinterDevice({
    required this.name,
    required this.macAddress,
  });

  final String name;
  final String macAddress;
}

/// Thin wrapper around the Bluetooth thermal printer plugin.
///
/// v1 scope: pairing list + connect/disconnect + receipt image stub.
class ThermalPrinterService {
  ThermalPrinterService({
    PrinterRepositoryPrefs? prefs,
  }) : _prefs = prefs ?? const PrinterRepositoryPrefs();

  final PrinterRepositoryPrefs _prefs;

  static const String _permissionsDeniedError =
      'Bluetooth permissions are required';

  Future<bool> _requestBluetoothPermissions() async {
    // Android 12+: BLUETOOTH_SCAN / BLUETOOTH_CONNECT runtime permissions.
    // Older Android: scan often requires location.
    final scan = await Permission.bluetoothScan.request();
    final connect = await Permission.bluetoothConnect.request();

    final ok = scan.isGranted && connect.isGranted;
    if (ok) return true;

    // Fallback for older devices / vendor ROM behavior.
    final loc = await Permission.locationWhenInUse.request();
    return loc.isGranted && (await Permission.bluetoothConnect.request()).isGranted;
  }

  Future<List<PairedPrinterDevice>> getPairedDevices() async {
    final granted = await _requestBluetoothPermissions();
    if (!granted) {
      throw StateError(_permissionsDeniedError);
    }
    final list = await PrintBluetoothThermal.pairedBluetooths;
    return list
        .map(
          (d) => PairedPrinterDevice(
            name: d.name.trim().isEmpty ? d.macAdress : d.name.trim(),
            macAddress: d.macAdress,
          ),
        )
        .toList(growable: false);
  }

  Future<void> connect(String macAddress) async {
    final mac = macAddress.trim();
    if (mac.isEmpty) {
      throw ArgumentError.value(macAddress, 'macAddress', 'Must not be empty');
    }

    final ok = await PrintBluetoothThermal.connect(macPrinterAddress: mac);
    if (!ok) {
      throw StateError('Could not connect to printer');
    }
  }

  Future<void> disconnect() async {
    await PrintBluetoothThermal.disconnect;
  }

  Future<bool> isConnected() async {
    return PrintBluetoothThermal.connectionStatus;
  }

  /// Prints a receipt rendered as image bytes (Arabic-safe approach).
  ///
  /// TODO: Implement bytes conversion + ESC/POS sizing policies.
  Future<void> printReceiptAsImage(Uint8List imageBytes) async {
    final granted = await _requestBluetoothPermissions();
    if (!granted) {
      throw StateError(_permissionsDeniedError);
    }
    if (imageBytes.isEmpty) {
      throw ArgumentError.value(imageBytes, 'imageBytes', 'Must not be empty');
    }

    final connected = await isConnected();
    if (!connected) {
      final mac = _prefs.getSelectedMacAddress();
      if (mac == null || mac.isEmpty) {
        throw StateError('No saved printer MAC address');
      }
      await connect(mac);
    }

    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw FormatException('Could not decode receipt image (expected PNG)');
    }

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);

    final bytes = <int>[
      ...generator.reset(),
      ...generator.imageRaster(decoded, imageFn: PosImageFn.bitImageRaster),
      ...generator.feed(3),
    ];

    final ok = await PrintBluetoothThermal.writeBytes(bytes);
    if (!ok) {
      throw StateError('Failed to send bytes to printer');
    }
  }
}

