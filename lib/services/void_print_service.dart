import 'dart:async';
import 'package:bir_pos/models/customer.dart';
import 'package:bir_pos/models/void_transaction.dart';
import 'package:bir_pos/services/customer_details_service.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';

class VoidPrintService {
  final PrinterManager printerManager = PrinterManager.instance;

  Future<void> printReceipt({
    required VoidTransactionResponse transaction,
  }) async {
    var devices = <BluetoothPrinter>[];
    BluetoothPrinter? selectedPrinter;
    bool isPrinted = false;

    Customer? customer = await CustomerDetailsService().fetchCustomerDetails(
      int.parse(transaction.transactionDetails.id.toString()),
    );

    // Discover USB printers
    StreamSubscription<PrinterDevice>? subscription;
    subscription = printerManager
        .discovery(type: PrinterType.usb)
        .listen(
          (device) async {
            final name = device.name.toLowerCase();
            print("🖨️ Found device: ${device.name}");

            // Only use Xprinter devices
            if (!name.contains('xprinter') && !name.contains('xp-58')) {
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
              await _printReceiptToDevice(
                selectedPrinter!,
                transaction,
                customer,
              );
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

  Future<void> _printReceiptToDevice(
    BluetoothPrinter printer,
    VoidTransactionResponse transaction,
    Customer? customer,
  ) async {
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm58, profile);

    List<int> bytes = [];

    bytes += generator.feed(1);
    bytes += generator.text(
      '------ VOID INVOICE ------',
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
      '2286 Marconi St., Brgy. San Isidro, Makati City',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'VAT REG TIN: 223-661-818-00000',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.feed(1);
    bytes += generator.hr();
    bytes += generator.feed(1);

    // Transaction Details

    bytes += generator.text(
      'MIN: XXXXXXXXXX',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Serial No: XXXXXXXXXX',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.feed(1);
    bytes += generator.text(
      'Void No: ${transaction.transactionDetails.voidId}',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Void Date: ${transaction.transactionDetails.voidDate}',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Void Time: ${transaction.transactionDetails.voidTime}',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.feed(1);
    bytes += generator.text(
      'Issued by: ${transaction.transactionDetails.processedBy}',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'SI NO: ${transaction.transactionDetails.siNo}',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Trans Date: ${transaction.transactionDetails.date}',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Trans Time: ${transaction.transactionDetails.time}',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Payment Method: ${transaction.transactionDetails.paymentMethod.toUpperCase()}',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.feed(1);

    // Customer Details

    if (customer != null) {
      bytes += generator.hr();
      bytes += generator.feed(1);

      // Customer Details
      bytes += generator.text(
        '----- CUSTOMER DETAILS -----',
        styles: PosStyles(align: PosAlign.center, bold: true),
      );
      bytes += generator.feed(1);
      bytes += generator.row([
        PosColumn(text: 'Name:', width: 5),
        PosColumn(
          text:
              customer != null
                  ? customer.name
                  : '...............................',
          width: 7,
          styles: PosStyles(bold: true),
        ),
      ]);
      bytes += generator.row([
        PosColumn(text: 'ID Number:', width: 5),
        PosColumn(
          text:
              customer != null
                  ? customer.id.toString()
                  : '...............................',
          width: 7,
          styles: PosStyles(bold: true),
        ),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Signature:', width: 5),
        PosColumn(
          text: '___________________________________',
          width: 7,
          styles: PosStyles(bold: true),
        ),
      ]);
      bytes += generator.feed(1);
    } else {
      bytes += generator.hr();
      bytes += generator.feed(1);

      // Blank Customer Details
      bytes += generator.text(
        '----- CUSTOMER DETAILS -----',
        styles: PosStyles(align: PosAlign.center, bold: true),
      );
      bytes += generator.feed(1);
      bytes += generator.row([
        PosColumn(text: 'Name:', width: 5),
        PosColumn(
          text: '___________________________________',
          width: 7,
          styles: PosStyles(bold: true),
        ),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Address:', width: 5),
        PosColumn(
          text: '___________________________________',
          width: 7,
          styles: PosStyles(bold: true),
        ),
      ]);
      bytes += generator.row([
        PosColumn(text: 'TIN:', width: 5),
        PosColumn(
          text: '___________________________________',
          width: 7,
          styles: PosStyles(bold: true),
        ),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Signature:', width: 5),
        PosColumn(
          text: '___________________________________',
          width: 7,
          styles: PosStyles(bold: true),
        ),
      ]);
      bytes += generator.feed(1);
    }

    bytes += generator.hr();
    bytes += generator.feed(1);

    // Item Breakdown
    bytes += generator.text(
      '----- ITEM BREAKDOWN -----',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(
        text: 'Qty',
        width: 3,
        styles: PosStyles(align: PosAlign.left, bold: true),
      ),
      PosColumn(text: 'Item', width: 3, styles: PosStyles(bold: true)),
      PosColumn(
        text: 'Price',
        width: 3,
        styles: PosStyles(align: PosAlign.left, bold: true),
      ),
      PosColumn(
        text: 'Total',
        width: 3,
        styles: PosStyles(align: PosAlign.left, bold: true),
      ),
    ]);
    bytes += generator.feed(1);

    for (var item in transaction.items) {
      bytes += generator.row([
        PosColumn(
          text: item.quantity.toString(),
          width: 3,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: item.name,
          width: 3,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '-${(item.price).toStringAsFixed(2)}',
          width: 3,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '-${(item.quantity * item.price).toStringAsFixed(2)}',
          width: 3,
          styles: PosStyles(align: PosAlign.left),
        ),
      ]);
    }
    for (var item in transaction.discountedItems) {
      bytes += generator.row([
        PosColumn(
          text: item.quantity.toString(),
          width: 3,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: item.name,
          width: 3,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '-${(item.price).toStringAsFixed(2)}',
          width: 3,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '-${(item.quantity * item.price).toStringAsFixed(2)}',
          width: 3,
          styles: PosStyles(align: PosAlign.left),
        ),
      ]);
    }
    bytes += generator.feed(1);
    bytes += generator.hr();
    bytes += generator.feed(1);
    for (var item in transaction.discountedItems) {
      if (transaction.transactionDetails.isSc == true) {
        bytes += generator.row([
          PosColumn(
            text: 'SC Discount @ 20%:',
            width: 7,
            styles: PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: '- P ${item.discountValue}',
            width: 5,
            styles: PosStyles(align: PosAlign.right),
          ),
        ]);
      } else if (transaction.transactionDetails.isPwd == true) {
        bytes += generator.row([
          PosColumn(
            text: 'PWD Discount @ 20%:',
            width: 7,
            styles: PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: '- P ${item.discountValue}',
            width: 5,
            styles: PosStyles(align: PosAlign.right),
          ),
        ]);
      } else if (transaction.transactionDetails.isNac == true) {
        bytes += generator.row([
          PosColumn(
            text: 'NAC Discount @ 20%:',
            width: 7,
            styles: PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: '- P ${item.discountValue}',
            width: 5,
            styles: PosStyles(align: PosAlign.right),
          ),
        ]);
      } else if (transaction.transactionDetails.isSoloParent == true) {
        bytes += generator.row([
          PosColumn(
            text: 'Solo Parent Discount @ 10%:',
            width: 7,
            styles: PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: '- P ${item.discountValue}',
            width: 5,
            styles: PosStyles(align: PosAlign.right),
          ),
        ]);
      } else {}
    }
    bytes += generator.row([
      PosColumn(
        text: 'Gross Sales:',
        width: 7,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '- P ${transaction.transactionDetails.grossSales}',
        width: 5,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Cash Tendered:',
        width: 7,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '- P ${transaction.transactionDetails.cashTendered}',
        width: 5,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'VATable Sales:',
        width: 7,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '- P ${transaction.transactionDetails.vatableSales}',
        width: 5,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Change:',
        width: 7,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '- P ${transaction.transactionDetails.change}',
        width: 5,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'VAT:',
        width: 7,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '- P ${transaction.transactionDetails.vat}',
        width: 5,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'VAT Exempt Sales:',
        width: 7,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '- P ${transaction.transactionDetails.vatExemptSales}',
        width: 5,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Zero-Rated Sales:',
        width: 7,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '- P ${transaction.transactionDetails.zeroRatedSales}',
        width: 5,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Net Total:',
        width: 7,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '- P ${transaction.transactionDetails.totalSales}',
        width: 5,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.feed(2);
    List<int> barcodeData =
        transaction.transactionDetails.siNo.split('').map(int.parse).toList();
    bytes += generator.barcode(
      Barcode.upcA(barcodeData),
      height: 40,
      textPos: BarcodeText.below,
    );
    bytes += generator.feed(2);
    bytes += generator.text(
      'THERMOZONE PHILIPPINES CORP.',
      styles: PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      '2286 Marconi St. Makati City',
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
