import 'dart:async';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:intl/intl.dart';
import 'package:bir_pos/models/xreading.dart';
import 'package:bir_pos/services/xreading_service.dart';

class XReadingPrintService {
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
    final service = XReadingService(
      baseUrl: dotenv.env['POS_API_URL'] ?? '',
      token: dotenv.env['POS_API_TOKEN'] ?? '',
    );
    final xReading = await service.fetchXReading();
    if (xReading == null) return;

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
      'X-READING REPORT',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'Report Date:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.reportDate,
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Report Time:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.reportTime,
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'Start Time:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.timeIn,
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'End Time:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.timeOut,
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'Cashier:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.user,
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'Beg. OR #:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.beginningOR,
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'End. OR #:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.endingOR,
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(
        text: 'Opening Fund:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: xReading.openingFund.toStringAsFixed(2),
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.text('================================');
    bytes += generator.text(
      'PAYMENTS RECEIVED',
      styles: PosStyles(align: PosAlign.left, bold: true),
    );
    bytes += generator.row([
      PosColumn(text: 'CASH:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.totalCashPayment.toStringAsFixed(2),
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'DIGITAL:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.totalDigitalPayment.toStringAsFixed(2),
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'CREDIT CARD:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.totalCreditPayment.toStringAsFixed(2),
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Total Payments:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: xReading.totalPayments.toStringAsFixed(2),
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.text('================================');
    bytes += generator.row([
      PosColumn(text: 'VOID:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.voidValue.toStringAsFixed(2),
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.text('================================');
    bytes += generator.row([
      PosColumn(text: 'REFUND:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.refundValue.toStringAsFixed(2),
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.text('================================');
    bytes += generator.row([
      PosColumn(text: 'WITHDRAWAL:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.text('================================');
    bytes += generator.text(
      'TRANSACTION SUMMARY',
      styles: PosStyles(align: PosAlign.left, bold: true),
    );
    bytes += generator.row([
      PosColumn(
        text: 'Cash In Drawer:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: xReading.endingFund.toStringAsFixed(2),
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'DIGITAL:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.totalDigitalPayment.toStringAsFixed(2),
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'CREDIT CARD:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.totalCreditPayment.toStringAsFixed(2),
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
        text: xReading.openingFund.toStringAsFixed(2),
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
        text: xReading.totalPayments.toStringAsFixed(2),
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.text('================================');
    bytes += generator.row([
      PosColumn(text: 'SHORT/OVER:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
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
