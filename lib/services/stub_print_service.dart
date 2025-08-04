import 'dart:async';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:intl/intl.dart';

class StubPrintService {
  final PrinterManager printerManager = PrinterManager.instance;

  Future<void> printStub(Map<String, dynamic> stubData) async {
    BluetoothPrinter? selectedPrinter;
    bool isPrinted = false;

    StreamSubscription<PrinterDevice>? subscription;

    subscription = printerManager.discovery(type: PrinterType.usb).listen((
      device,
    ) async {
      if (isPrinted) return;

      selectedPrinter = BluetoothPrinter(
        deviceName: device.name,
        address: device.address,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: PrinterType.usb,
      );

      if (selectedPrinter != null) {
        isPrinted = true;
        await subscription?.cancel();
        await _printDynamicStub(selectedPrinter!, stubData);
      }
    });

    await Future.delayed(const Duration(seconds: 3));
    if (!isPrinted) {
      await subscription?.cancel();
    }
  }

  Future<void> _printDynamicStub(
    BluetoothPrinter printer,
    Map<String, dynamic> data,
  ) async {
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm58, profile);

    List<int> bytes = [];

    bytes += generator.text(
      '----- CLAIM STUB -----',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );

    bytes += generator.feed(1);

    bytes += generator.row([
      PosColumn(text: 'Date:', width: 6),
      PosColumn(
        text: data['date'] ?? '',
        width: 6,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: 'Time:', width: 6),
      PosColumn(
        text: data['time'] ?? '',
        width: 6,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: 'Transaction #:', width: 6),
      PosColumn(
        text: data['transaction_no']?.toString() ?? '',
        width: 6,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: 'Stub #:', width: 5),
      PosColumn(
        text: data['stub']?.toString() ?? '',
        width: 7,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.text(
      '-------------------------------',
      styles: PosStyles(align: PosAlign.center),
    );

    bytes += generator.text(
      '------- ITEMS -------',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );

    bytes += generator.feed(1);

    bytes += generator.row([
      PosColumn(text: 'Qty', width: 2),
      PosColumn(text: 'Name', width: 6),
      PosColumn(
        text: 'Price',
        width: 4,
        styles: PosStyles(align: PosAlign.left),
      ),
    ]);

    bytes += generator.feed(1);

    bytes += generator.row([
      PosColumn(
        text: data['quantity'].toString(),
        width: 2,
        styles: PosStyles(bold: true),
      ),
      PosColumn(
        text: data['pack_inclusive_name'] ?? '',
        width: 6,
        styles: PosStyles(bold: true),
      ),
      PosColumn(
        text: 'P ${NumberFormat('#,##0.00').format(data['price'] ?? 0)}',
        width: 4,
        styles: PosStyles(bold: true),
      ),
    ]);

    final List<dynamic> items = data['items'] ?? [];

    for (final item in items) {
      final qty = item['quantity'] ?? 0;
      final name = item['name'] ?? '';
      bytes += generator.text(
        '     x $qty $name',
        styles: PosStyles(align: PosAlign.left),
      );
    }

    bytes += generator.feed(2);

    bytes += generator.text(
      'THIS STUB HAS BEEN CLAIMED',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );

    bytes += generator.feed(1);
    bytes += generator.cut();

    await printerManager.connect(
      type: PrinterType.usb,
      model: UsbPrinterInput(
        name: printer.deviceName,
        productId: printer.productId,
        vendorId: printer.vendorId,
      ),
    );

    printerManager.send(type: PrinterType.usb, bytes: bytes);
  }
}

class BluetoothPrinter {
  String? deviceName;
  String? address;
  String? vendorId;
  String? productId;
  PrinterType typePrinter;

  BluetoothPrinter({
    this.deviceName,
    this.address,
    this.vendorId,
    this.productId,
    this.typePrinter = PrinterType.usb,
  });
}
