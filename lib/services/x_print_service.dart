import 'dart:async';
import 'package:bir_pos/models/xreading.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';

class XReadingPrintService {
  final PrinterManager printerManager = PrinterManager.instance;

  Future<void> printReceipt({required XReading? xReading}) async {
    var devices = <BluetoothPrinter>[];
    BluetoothPrinter? selectedPrinter;
    bool isPrinted = false;

    // Discover USB printers
    StreamSubscription<PrinterDevice>? subscription;
    subscription = printerManager
        .discovery(type: PrinterType.usb)
        .listen(
          (device) async {
            print("🖨️ Found device: ${device.name}");

            // ✅ Filter by printer name (only allow "xprinter" or "xp-58")
            final name = device.name.toLowerCase();
            if (!name.contains('xprinter') &&
                !name.contains('xp-58') &&
                !name.contains('pos58') &&
                !name.contains('pos58 printer')) {
              print("⛔ Skipped non-supported printer: ${device.name}");
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

            // Auto-select the first detected printer
            selectedPrinter = selectedPrinter ?? newPrinter;

            if (selectedPrinter != null && !isPrinted) {
              isPrinted = true;
              print("✅ Printing to: ${selectedPrinter!.deviceName}");

              await _printReceiptToDevice(selectedPrinter!, xReading);

              await subscription?.cancel(); // Stop discovery after printing
            }
          },
          onError: (e) {
            print("❌ Printer discovery error: $e");
          },
        );

    // Give time for discovery
    await Future.delayed(const Duration(seconds: 3));
    await subscription.cancel();

    if (!isPrinted) {
      print("⚠️ No supported printer found (Xprinter/XP-58).");
    }
  }

  Future<void> _printReceiptToDevice(
    BluetoothPrinter printer,
    XReading? xReading,
  ) async {
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm58, profile);

    List<int> bytes = [];
    bytes += generator.feed(1);
    bytes += generator.text(
      'THERMOZONE PHILIPPINES CORP.',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      '2286 Marconi St., Brgy.',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'San Isidro, Makati City',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(
      'VAT REG. TIN: 223-661-818-00000',
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
        text: xReading!.reportDate,
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
    bytes += generator.text(
      'Start Date & Time:',
      styles: PosStyles(align: PosAlign.left, bold: false),
    );
    bytes += generator.text(
      xReading.timeIn,
      styles: PosStyles(align: PosAlign.left, bold: false),
    );
    bytes += generator.feed(1);
    bytes += generator.text(
      'End Date & Time:',
      styles: PosStyles(align: PosAlign.left, bold: false),
    );
    bytes += generator.text(
      xReading.timeOut,
      styles: PosStyles(align: PosAlign.left, bold: false),
    );
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'Cashier:', width: 5, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.user,
        width: 7,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'Beg. SI #:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.beginningOR,
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'End. SI #:', width: 6, styles: PosStyles(bold: false)),
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
      PosColumn(text: 'GCASH:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.totalGcashPayment.toStringAsFixed(2),
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'MAYA:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.totalMayaPayment.toStringAsFixed(2),
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'DEBIT CARD:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.totalDebitPayment.toStringAsFixed(2),
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
      PosColumn(text: 'WITHDRAWAL:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.withdrawal.toStringAsFixed(2),
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
        text: 'CASH IN DRAWER:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: xReading.cashInDrawer.toStringAsFixed(2),
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'GCASH:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.totalGcashPayment.toStringAsFixed(2),
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'MAYA:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.totalMayaPayment.toStringAsFixed(2),
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'DEBIT CARD:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: xReading.totalDebitPayment.toStringAsFixed(2),
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
        text: xReading.lessWithdrawal.toStringAsFixed(2),
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
        text: xReading.shortOrOver.toStringAsFixed(2),
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
