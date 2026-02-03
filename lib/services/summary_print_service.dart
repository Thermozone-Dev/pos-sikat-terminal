import 'dart:async';
import 'package:bir_pos/models/product_summary.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SummaryPrintService {
  final PrinterManager printerManager = PrinterManager.instance;

  Future<void> printReceipt({required List<ProductSummary> products}) async {
    var devices = <BluetoothPrinter>[];
    BluetoothPrinter? selectedPrinter;
    bool isPrinted = false;

    // Discover USB printers
    StreamSubscription<PrinterDevice>? subscription;
    subscription = printerManager
        .discovery(type: PrinterType.usb)
        .listen(
          (device) async {
            final name = device.name.toLowerCase();
            print("🖨️ Found device: ${device.name}");

            // Only use Xprinter devices
            if (!name.contains('xprinter') &&
                !name.contains('xp-58') &&
                !name.contains('pos58') &&
                !name.contains('pos58 printer')) {
              print("⛔ Skipped non-Xprinter device: ${device.name}");
              return;
            }

            if (isPrinted) return;

            final newPrinter = BluetoothPrinter(
              deviceName: device.name,
              address: device.address,
              vendorId: device.vendorId,
              productId: device.productId,
              typePrinter: PrinterType.usb,
            );

            devices.add(newPrinter);
            selectedPrinter = selectedPrinter ?? newPrinter;

            if (selectedPrinter != null && !isPrinted) {
              isPrinted = true;
              await _printReceiptToDevice(selectedPrinter!, products);
              await subscription?.cancel();
            }
          },
          onError: (e) {
            print("❌ Printer discovery error: $e");
          },
        );

    // Give time for printer discovery
    await Future.delayed(const Duration(seconds: 3));

    if (!isPrinted) {
      await subscription?.cancel();
      print("⚠️ No Xprinter device found.");
    }
  }

  Future<void> _printReceiptToDevice(BluetoothPrinter printer, products) async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('user_name') ?? 'Missing User';

    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm58, profile);
    double grandTotal = 0;

    List<int> bytes = [];
    bytes += generator.feed(1);
    bytes += generator.text(
      '-- SUMMARY REPORT / CASHIER --',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'Cashier:', width: 5, styles: PosStyles(bold: false)),
      PosColumn(
        text: userName,
        width: 7,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    final String formattedData = DateFormat(
      'MMMM dd, yyyy',
    ).format(DateTime.now());

    bytes += generator.row([
      PosColumn(text: 'Date:', width: 5, styles: PosStyles(bold: false)),
      PosColumn(
        text: formattedData,
        width: 7,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
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
      grandTotal += product.total as double;
      bytes += generator.row([
        PosColumn(text: product.name, width: 4, styles: PosStyles(bold: false)),
        PosColumn(
          text: (product.price as double).toStringAsFixed(2),
          width: 3,
          styles: PosStyles(align: PosAlign.right, bold: false),
        ),
        PosColumn(
          text: (product.quantity as double).toStringAsFixed(0),
          width: 2,
          styles: PosStyles(align: PosAlign.right, bold: false),
        ),
        PosColumn(
          text: (product.total as double).toStringAsFixed(2),
          width: 3,
          styles: PosStyles(align: PosAlign.right, bold: false),
        ),
      ]);
    }
    bytes += generator.feed(1);
    final formatter = NumberFormat('#,##0.00', 'en_US');
    bytes += generator.row([
      PosColumn(text: 'Grand Total:', width: 5, styles: PosStyles(bold: false)),
      PosColumn(
        text: 'P ${formatter.format(grandTotal)}',
        width: 7,
        styles: PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
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
