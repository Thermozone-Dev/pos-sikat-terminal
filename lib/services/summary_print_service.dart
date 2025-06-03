import 'dart:async';
import 'package:bir_pos/models/product.dart';
import 'package:bir_pos/models/product_summary.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';

class SummaryPrintService {
  final PrinterManager printerManager = PrinterManager.instance;

  Future<void> printReceipt({required List<ProductSummary> products}) async {
    var devices = <BluetoothPrinter>[];
    BluetoothPrinter? selectedPrinter;
    bool isPrinted = false; // Flag to check if printed already

    // Discover USB printers
    StreamSubscription<PrinterDevice>? subscription;
    subscription = printerManager.discovery(type: PrinterType.usb).listen((
      device,
    ) async {
      if (isPrinted) return; // Prevent multiple prints if already printed

      final newPrinter = BluetoothPrinter(
        deviceName: device.name,
        address: device.address,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: PrinterType.usb,
      );

      devices.add(newPrinter);

      // Auto-select the first detected printer
      selectedPrinter = selectedPrinter ?? newPrinter;

      // Once a printer is selected, proceed to print and stop the stream
      if (selectedPrinter != null && !isPrinted) {
        isPrinted = true;
        await _printReceiptToDevice(selectedPrinter!, products);
        subscription?.cancel(); // Cancel the discovery stream after printing
      }
    });

    // Wait for the printer to be detected
    await Future.delayed(const Duration(seconds: 2));

    // Cancel the subscription after it's no longer needed
    subscription.cancel();
  }

  Future<void> _printReceiptToDevice(BluetoothPrinter printer, products) async {
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];
    bytes += generator.feed(1);
    bytes += generator.text(
      '----- SUMMARY REPORT -----',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'NAME', width: 4, styles: PosStyles(bold: true)),
      PosColumn(
        text: 'PRICE',
        width: 3,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
      PosColumn(
        text: 'QTY',
        width: 2,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
      PosColumn(
        text: 'TOTAL',
        width: 3,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    bytes += generator.feed(1);
    for (var product in products) {
      bytes += generator.row([
        PosColumn(text: product.name, width: 4, styles: PosStyles(bold: true)),
        PosColumn(
          text: (product.price as double).toStringAsFixed(2),
          width: 3,
          styles: PosStyles(align: PosAlign.right, bold: true),
        ),
        PosColumn(
          text: (product.quantity as double).toStringAsFixed(2),
          width: 2,
          styles: PosStyles(align: PosAlign.right, bold: true),
        ),
        PosColumn(
          text: (product.total as double).toStringAsFixed(2),
          width: 3,
          styles: PosStyles(align: PosAlign.right, bold: true),
        ),
      ]);
    }
    bytes += generator.feed(2);
    bytes += generator.text(
      '.',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );

    await _sendToPrinter(printer, bytes);
  }

  Future<void> _sendToPrinter(BluetoothPrinter printer, List<int> bytes) async {
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
