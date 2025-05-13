import 'dart:async';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';

class ZReadingPrintService {
  final PrinterManager printerManager = PrinterManager.instance;

  Future<void> printReceipt() async {
    var devices = <BluetoothPrinter>[];
    BluetoothPrinter? selectedPrinter;
    List<int> bytes = [];
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
        await _printReceiptToDevice(selectedPrinter!);
        subscription?.cancel(); // Cancel the discovery stream after printing
      }
    });

    // Wait for the printer to be detected
    await Future.delayed(const Duration(seconds: 2));

    // Cancel the subscription after it's no longer needed
    subscription.cancel();
  }

  Future<void> _printReceiptToDevice(BluetoothPrinter printer) async {
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];
    bytes += generator.feed(1);
    bytes += generator.text(
      'THERMOZONE PHILIPPINES CORP.',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      '2280 Marconi St., Brgy. San Isidro, Makati City',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'VAT REG TIN: 223-661-818-0000',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'MIN: XXXXXXXXXX',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'S/N: XXXXXXXXXX',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);
    bytes += generator.text(
      'Z-READING REPORT',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'Report Date:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: 'May 13, 2025',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Report Time:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '3:19 PM',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'Start Time:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '9:00 AM',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'End Time:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '11:30 AM',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'Beg. SI #:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '000001',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'End. SI #:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '000010',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Beg. VOID #:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '000001',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'End. VOID #:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '000010',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Beg. RETURN #:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '000010',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'End. RETURN #:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '000010',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(
        text: 'Reset Counter No.',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '0',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Z Counter No. :',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '1',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.text('--------------------------------');
    bytes += generator.row([
      PosColumn(
        text: 'Present Accumulated Sales:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Previous Accumulated Sales:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Sales for the Day:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.text('--------------------------------');
    bytes += generator.text(
      'BREAKDOWN OF SALES',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(
        text: 'VATABLE SALES:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'VAT AMOUNT:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'VAT EXEMPT SALES:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'ZERO RATED SALES:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.text('--------------------------------');
    bytes += generator.row([
      PosColumn(
        text: 'Gross Amount:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Less Discount:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Less Return:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Less Void:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Less VAT Adjustment:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Net Amount:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.text('--------------------------------');
    bytes += generator.text(
      'DISCOUNT SUMMARY',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'SC Disc. :', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'PWD Disc. :', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'NAAC Disc. :', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Solo Parent Disc. :',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Other Disc. :',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.text('--------------------------------');
    bytes += generator.text(
      'SALES ADJUSTMENT',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'VOID :', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'RETURN :', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.text('--------------------------------');
    bytes += generator.text(
      'VAT ADJUSTMENT',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'SC TRANS. :', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'PWD TRANS. :', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Reg.Disc. TRANS. :',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'ZERO-RATED TRANS. :',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'VAT on Return :',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Other VAT Adjustments :',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.text('--------------------------------');
    bytes += generator.text(
      'TRANSACTION SUMMARY',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(
        text: 'Cash In Drawer:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'CHEQUE:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'CREDIT CARD:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'GIFT CERTIFICATE:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Opening Fund:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Less Withdrawal:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Payments Received:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.text('--------------------------------');
    bytes += generator.row([
      PosColumn(text: 'SHORT/OVER:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.text('--------------------------------');
    bytes += generator.feed(2);
    bytes += generator.text(
      '.',
      styles: PosStyles(align: PosAlign.center, bold: false),
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
