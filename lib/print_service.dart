import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';

class PrinterService {
  final PrinterManager printerManager = PrinterManager.instance;

  Future<void> printReceipt({
    required String storeName,
    required String storeAddress,
    required String storePhone,
    required List<Map<String, String>> items,
    required double total,
  }) async {
    var devices = <BluetoothPrinter>[];
    BluetoothPrinter? selectedPrinter;
    List<int> bytes = [];
    bool isPrinted = false; // Flag to check if printed already

    // Discover USB printers
    StreamSubscription<PrinterDevice>? _subscription;
    _subscription = printerManager.discovery(type: PrinterType.usb).listen((
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
      if (selectedPrinter == null) {
        selectedPrinter = newPrinter;
      }

      // Once a printer is selected, proceed to print and stop the stream
      if (selectedPrinter != null && !isPrinted) {
        isPrinted = true;
        await _printReceiptToDevice(
          selectedPrinter!,
          storeName,
          storeAddress,
          storePhone,
          items,
          total,
        );
        _subscription?.cancel(); // Cancel the discovery stream after printing
      }
    });

    // Wait for the printer to be detected
    await Future.delayed(const Duration(seconds: 2));

    // Cancel the subscription after it's no longer needed
    _subscription?.cancel();
  }

  Future<void> _printReceiptToDevice(
    BluetoothPrinter printer,
    String storeName,
    String storeAddress,
    String storePhone,
    List<Map<String, String>> items,
    double total,
  ) async {
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    bytes += generator.text(
      '-------- INVOICE --------',
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );

    bytes += generator.feed(1);

    // Business Details

    bytes += generator.text(
      'Thermozone Philippines Corp.',
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );
    bytes += generator.text(
      storeAddress,
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'VAT REG TIN: 223 661 818 0000',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(1);
    bytes += generator.hr();
    bytes += generator.feed(1);

    // Transaction Details

    bytes += generator.text(
      'Machine No: XXXXXXXXXX',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Hardware Serial: XXXXXXXXXX',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.feed(1);
    bytes += generator.text(
      'Issued by: Angelo S. Marquez',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'INVOICE NO: 000012',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Date: April 11, 2025 - 9:19 AM',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Payment Method: Cash',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.feed(1);
    bytes += generator.hr();
    bytes += generator.feed(1);

    // Customer Details
    bytes += generator.text(
      '----- CUSTOMER DETAILS -----',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'Name:', width: 2),
      PosColumn(
        text: 'Angelo San Mateo',
        width: 10,
        styles: PosStyles(bold: true),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Address:', width: 2),
      PosColumn(
        text: '2924 Finlandia St., Makati City',
        width: 10,
        styles: PosStyles(bold: true),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'TIN:', width: 2),
      PosColumn(
        text: 'XXX XXX XXX XXXX',
        width: 10,
        styles: PosStyles(bold: true),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Business Style:', width: 2),
      PosColumn(text: 'Lorem Ipsum', width: 10, styles: PosStyles(bold: true)),
    ]);
    bytes += generator.feed(1);
    bytes += generator.hr();
    bytes += generator.feed(1);

    // Item Breakdown
    bytes += generator.row([
      PosColumn(
        text: 'Qty',
        width: 3,
        styles: PosStyles(align: PosAlign.left, bold: true),
      ),
      PosColumn(text: 'Item', width: 6, styles: PosStyles(bold: true)),
      PosColumn(
        text: 'Price',
        width: 3,
        styles: PosStyles(align: PosAlign.left, bold: true),
      ),
    ]);
    bytes += generator.feed(1);
    for (var item in items) {
      bytes += generator.row([
        PosColumn(
          text: item['quantity']!,
          width: 3,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(text: item['name']!, width: 6),
        PosColumn(
          text: item['price']!,
          width: 3,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    bytes += generator.feed(1);
    bytes += generator.hr();
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(
        text: 'Discount:',
        width: 9,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: 'P 0.00',
        width: 3,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Transaction Fee:',
        width: 9,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: 'P 0.00',
        width: 3,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Cash Tendered:',
        width: 9,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: 'P 500.00',
        width: 3,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'VATable Sales:',
        width: 9,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: 'P 450.00',
        width: 3,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Change:',
        width: 9,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: 'P 50.00',
        width: 3,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'VAT:',
        width: 9,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: 'P 54.00',
        width: 3,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'VAT Exempt Sales:',
        width: 9,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: 'P 0.00',
        width: 3,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'VAT Exempt:',
        width: 9,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: 'P 0.00',
        width: 3,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Zero-Rated Sales:',
        width: 9,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: 'P 0.00',
        width: 3,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.feed(2);
    bytes += generator.text(
      'THIS DOCUMENT IS NOT VALID FOR CLAIM OF INPUT TAX',
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );
    bytes += generator.feed(2);
    bytes += generator.barcode(
      Barcode.upcA([1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2]),
      height: 40,
      textPos: BarcodeText.below,
    );
    bytes += generator.feed(2);
    bytes += generator.text(
      'THERMOZONE PHILIPPINES CORP.',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      '2280 Marconi St. Makati City',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'VAT REG TIN: 223-661-818-00000',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Accreditation Number: XXXXXXXX',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'ATG Number: XXXXXXXX',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(2);
    bytes += generator.text('.', styles: PosStyles(align: PosAlign.right));

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
