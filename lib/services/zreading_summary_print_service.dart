import 'dart:async';
import 'package:bir_pos/models/zreading_reprint.dart';
import 'package:bir_pos/models/zreading_summary.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:intl/intl.dart';

class ZReadingSummaryPrintService {
  final PrinterManager printerManager = PrinterManager.instance;

  Future<void> printReceipt({required ZReadingSummary? zReading}) async {
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

            // ✅ Filter supported printer models (Xprinter / XP-58)
            final name = device.name.toLowerCase();
            if (!name.contains('xprinter') &&
                !name.contains('xp-58') &&
                !name.contains('pos58') &&
                !name.contains('pos58 printer')) {
              print("⛔ Skipped unsupported printer: ${device.name}");
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

              print(
                "✅ Printing Z-Reading Reprint to: ${selectedPrinter!.deviceName}",
              );

              await _printReceiptToDevice(selectedPrinter!, zReading);

              await subscription?.cancel();
            }
          },
          onError: (e) {
            print("❌ Printer discovery error: $e");
          },
        );

    // Give discovery a few seconds
    await Future.delayed(const Duration(seconds: 3));
    await subscription.cancel();

    if (!isPrinted) {
      print("⚠️ No supported printer found (Xprinter/XP-58).");
    }
  }

  Future<void> _printReceiptToDevice(
    BluetoothPrinter printer,
    ZReadingSummary? zReading,
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
      '2286 Marconi St., Brgy. San Isidro, Makati City',
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
      'Z-READING SUMMARY',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'Report Date:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.reportDate ?? 'N/A',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Report Time:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.reportTime ?? 'N/A',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'Start Date:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.startDate ?? 'N/A',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'End Date:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.endDate ?? 'N/A',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(
        text: 'Total Invoices:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: zReading?.totalInvoices.toString() ?? 'N/A',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'Beg. SI #:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.beginningOR ?? 'N/A',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'End. SI #:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.endingOR ?? 'N/A',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Beg. VOID #:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.beginningVoid ?? 'N/A',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'End. VOID #:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.endingVoid ?? 'N/A',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.feed(1);
    bytes += generator.text('--------------------------------');
    bytes += generator.row([
      PosColumn(
        text: 'Present Accumulated Sales:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: zReading?.presentAccumulatedSales ?? '0.00',
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
        text: zReading?.previousAccumulatedSales ?? '0.00',
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
        text: zReading?.salesForTheDay ?? '0.00',
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
        text: zReading?.vatableSales ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'VAT AMOUNT:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.vat ?? '0.00',
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
        text: zReading?.vatExemptSales ?? '0.00',
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
        text: zReading?.zeroRatedSales ?? '0.00',
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
        text: zReading?.grossAmount ?? '0.00',
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
        text: zReading?.lessDiscount ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Less Void:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.lessVoid ?? '0.00',
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
        text: zReading?.lessVatAdjust ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Net Amount:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.netAmount ?? '0.00',
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
        text: zReading?.scDiscounts ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'PWD Disc. :', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.pwdDiscounts ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'NAAC Disc. :', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.naacDiscounts ?? '0.00',
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
        text: zReading?.spDiscounts ?? '0.00',
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
        text: zReading?.otherDiscounts ?? '0.00',
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
        text: zReading?.voidAmount ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'RETURN :', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.returns ?? '0.00',
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
        text: zReading?.scAdjustments ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'PWD TRANS. :', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.pwdAdjustments ?? '0.00',
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
        text: zReading?.regDiscountAdjustments ?? '0.00',
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
        text: zReading?.zeroRatedAdjustments ?? '0.00',
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
        text: zReading?.vatOnReturn ?? '0.00',
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
        text: zReading?.otherVatAdjustments ?? '0.00',
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
        text: 'CASH IN DRAWER:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: zReading?.cashInDrawer ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'GCASH PAYMENTS:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: zReading?.gcashPayments ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'MAYA PAYMENTS:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: zReading?.mayaPayments ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'DEBIT CARD:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.debitPayments ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'CREDIT CARD:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.creditPayments ?? '0.00',
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
        text: zReading?.openingFund ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'WITHDRAWAL', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.withdrawal ?? '0.00',
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
        text: zReading?.lessWithdrawal ?? '0.00',
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
        text: zReading?.paymentsReceived ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.text('--------------------------------');
    bytes += generator.row([
      PosColumn(text: 'SHORT/OVER:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.shortOver ?? '0.00',
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
