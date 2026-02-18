import 'dart:async';
import 'package:bir_pos/models/zreading_reprint.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:intl/intl.dart';
import 'print/document_header.dart';

class ZReadingReprintPrintService {
  final PrinterManager printerManager = PrinterManager.instance;

  Future<void> printReceipt({required ZReadingReprint? zReading}) async {
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
    ZReadingReprint? zReading,
  ) async {
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];
    bytes += generator.text(
      '-------- REPRINT --------',
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );
    bytes += generator.feed(1);

    // Get current date and time
    final date = DateTime.now();
    final formattedDate = DateFormat('MMMM d, y').format(date);

    final now = DateTime.now();
    final formattedTime = DateFormat('h:mm a').format(now);

    bytes += generator.row([
      PosColumn(
        text: 'Date:',
        width: 5,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: formattedDate,
        width: 7,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Time:',
        width: 5,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: formattedTime,
        width: 7,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.feed(1);

    // Business Details Header
    bytes += buildReceiptHeader(generator);

    bytes += generator.feed(1);
    bytes += generator.text(
      'Z-READING REPORT',
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
    bytes += generator.text(
      'Start Date & Time:',
      styles: PosStyles(align: PosAlign.left, bold: false),
    );
    bytes += generator.text(
      zReading?.startTime ?? 'N/A',
      styles: PosStyles(align: PosAlign.left, bold: false),
    );
    bytes += generator.feed(1);
    bytes += generator.text(
      'End Date & Time:',
      styles: PosStyles(align: PosAlign.left, bold: false),
    );
    bytes += generator.text(
      zReading?.endTime ?? 'N/A',
      styles: PosStyles(align: PosAlign.left, bold: false),
    );
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'Beg. SI #:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.beginningSi ?? 'N/A',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'End. SI #:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.endingSi ?? 'N/A',
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
    bytes += generator.row([
      PosColumn(
        text: 'Reset Counter No.',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: zReading!.resetCounter.toString().padLeft(12, '0'),
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
        text: zReading.counter.toString().padLeft(12, '0'),
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
        text: zReading?.presentAccumulatedSales.toStringAsFixed(2) ?? '0.00',
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
        text: zReading?.previousAccumulatedSales.toStringAsFixed(2) ?? '0.00',
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
        text: zReading?.salesForTheDay.toStringAsFixed(2) ?? '0.00',
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
        text: zReading?.vatableSales.toStringAsFixed(2) ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'VAT AMOUNT:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.vat.toStringAsFixed(2) ?? '0.00',
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
        text: zReading?.vatExemptSales.toStringAsFixed(2) ?? '0.00',
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
        text: zReading?.zeroRatedSales.toStringAsFixed(2) ?? '0.00',
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
        text: zReading?.grossAmount.toStringAsFixed(2) ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Total Discounts:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: zReading?.totalDiscounts.toStringAsFixed(2) ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Total Void:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.voidAmount.toStringAsFixed(2) ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Total VAT Adjustments:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: zReading?.totalVatAdjustments.toStringAsFixed(2) ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Net Amount:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.netAmount.toStringAsFixed(2) ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);

    // LESS DETAILS - REMOVED AS PER REQUEST
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Gross Amount:',
    //     width: 6,
    //     styles: PosStyles(bold: false),
    //   ),
    //   PosColumn(
    //     text: zReading?.grossAmount.toStringAsFixed(2) ?? '0.00',
    //     width: 6,
    //     styles: PosStyles(bold: false, align: PosAlign.right),
    //   ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Less Discount:',
    //     width: 6,
    //     styles: PosStyles(bold: false),
    //   ),
    //   PosColumn(
    //     text: zReading?.lessDiscount.toStringAsFixed(2) ?? '0.00',
    //     width: 6,
    //     styles: PosStyles(bold: false, align: PosAlign.right),
    //   ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(text: 'Less Void:', width: 6, styles: PosStyles(bold: false)),
    //   PosColumn(
    //     text: zReading?.lessVoid.toStringAsFixed(2) ?? '0.00',
    //     width: 6,
    //     styles: PosStyles(bold: false, align: PosAlign.right),
    //   ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Less VAT Adjustment:',
    //     width: 6,
    //     styles: PosStyles(bold: false),
    //   ),
    //   PosColumn(
    //     text: zReading?.lessVatAdjust.toStringAsFixed(2) ?? '0.00',
    //     width: 6,
    //     styles: PosStyles(bold: false, align: PosAlign.right),
    //   ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(text: 'Net Amount:', width: 6, styles: PosStyles(bold: false)),
    //   PosColumn(
    //     text: zReading?.netAmount.toStringAsFixed(2) ?? '0.00',
    //     width: 6,
    //     styles: PosStyles(bold: false, align: PosAlign.right),
    //   ),
    // ]);
    bytes += generator.text('--------------------------------');
    bytes += generator.text(
      'DISCOUNT SUMMARY',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'SC Disc. :', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.scDiscounts.toStringAsFixed(2) ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'PWD Disc. :', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.pwdDiscounts.toStringAsFixed(2) ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'NAAC Disc. :', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.naacDiscounts.toStringAsFixed(2) ?? '0.00',
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
        text: zReading?.spDiscounts.toStringAsFixed(2) ?? '0.00',
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
        text: zReading?.otherDiscounts.toStringAsFixed(2) ?? '0.00',
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
        text: zReading?.voidAmount.toStringAsFixed(2) ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'RETURN :', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.returns.toStringAsFixed(2) ?? '0.00',
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
        text: zReading?.scAdjustments.toStringAsFixed(2) ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'PWD TRANS. :', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.pwdAdjustments.toStringAsFixed(2) ?? '0.00',
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
        text: zReading?.regDiscountAdjustments.toStringAsFixed(2) ?? '0.00',
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
        text: zReading?.zeroRatedAdjustments.toStringAsFixed(2) ?? '0.00',
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
        text: zReading?.vatOnReturn.toStringAsFixed(2) ?? '0.00',
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
        text: zReading?.otherVatAdjustments.toStringAsFixed(2) ?? '0.00',
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
        text: zReading?.cashInDrawer.toStringAsFixed(2) ?? '0.00',
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
        text: zReading?.gcashPayments.toStringAsFixed(2) ?? '0.00',
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
        text: zReading?.mayaPayments.toStringAsFixed(2) ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'DEBIT CARD:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.debitPayments.toStringAsFixed(2) ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'CREDIT CARD:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.creditPayments.toStringAsFixed(2) ?? '0.00',
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
        text: zReading?.openingFund.toStringAsFixed(2) ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'WITHDRAWAL', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.withdrawal.toStringAsFixed(2) ?? '0.00',
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
        text: zReading?.lessWithdrawal.toStringAsFixed(2) ?? '0.00',
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
        text: zReading?.paymentsReceived.toStringAsFixed(2) ?? '0.00',
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.text('--------------------------------');
    bytes += generator.row([
      PosColumn(text: 'SHORT/OVER:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: zReading?.shortOver.toStringAsFixed(2) ?? '0.00',
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
