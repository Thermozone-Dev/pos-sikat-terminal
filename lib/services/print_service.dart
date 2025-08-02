import 'dart:async';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';

class PrinterService {
  final PrinterManager printerManager = PrinterManager.instance;

  Future<void> printReceipt({
    required String storeName,
    required String storeAddress,
    required String storePhone,
    required Map<String, String> userData,
    required String invoiceId,
    required String methodName,
    required List<dynamic> items,
    required Map<String, String> accountingData,
    required String dateTime,
  }) async {
    var devices = <BluetoothPrinter>[];
    BluetoothPrinter? selectedPrinter;
    bool isPrinted = false; // Flag to check if printed already

    // Discover USB printers
    StreamSubscription<PrinterDevice>? subscription;
    subscription = printerManager.discovery(type: PrinterType.usb).listen((
      device,
    ) async {
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

      // Once a printer is selected, proceed to print and stop the stream
      if (selectedPrinter != null && !isPrinted) {
        isPrinted = true;
        await _printReceiptToDevice(
          selectedPrinter!,
          storeName,
          storeAddress,
          storePhone,
          userData,
          invoiceId,
          methodName,
          items,
          accountingData,
          dateTime,
        );
        subscription?.cancel(); // Cancel the discovery stream after printing
      }
    });

    // Wait for the printer to be detected
    await Future.delayed(const Duration(seconds: 2));

    // Cancel the subscription after it's no longer needed
    subscription.cancel();
  }

  Future<void> _printReceiptToDevice(
    BluetoothPrinter printer,
    String storeName,
    String storeAddress,
    String storePhone,
    Map<String, String> userData,
    String invoiceId,
    String methodName,
    List<dynamic> items,
    Map<String, String> accountingData,
    String dateTime,
  ) async {
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // DINO FORMAT
    bytes += generator.feed(1);
    bytes += generator.text(
      '-------- CASHIER\'S COPY --------',
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );
    bytes += generator.feed(1);
    bytes += generator.text(
      'Issued by: ${userData['name']}',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'INVOICE NO: ${invoiceId.padLeft(8 - invoiceId.length, '0')}',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Date: $dateTime',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.feed(1);
    // // Item Breakdown
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
          text: item['quantity']!.toString(),
          width: 3,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(text: item['name']!, width: 6),
        PosColumn(
          text: item['price'].roundToDouble()!.toString(),
          width: 3,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(
        text: 'Discount:',
        width: 9,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text:
            accountingData['discount_value'] == null
                ? 'P 0.00'
                : 'P ${accountingData['discount_value']}',
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
        text:
            accountingData['transaction_fee'] == null
                ? 'P 0.00'
                : 'P ${accountingData['transaction_fee']}',
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
        text: 'P ${accountingData['cash_tendered']}',
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
        text: 'P ${accountingData['vatable_sales']}',
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
        text: 'P ${accountingData['change']}',
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
        text: 'P ${accountingData['vat']}',
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
        text: 'P ${accountingData['vat_exempt_sales']}',
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
        text: 'P ${accountingData['zero_rated_sales']}',
        width: 3,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Total Sales:',
        width: 9,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: 'P ${accountingData['total_sales']}',
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
    String formattedInvoiceId = invoiceId.padLeft(6, '0');
    String fullUpc = formattedInvoiceId.padLeft(12, '0');
    List<int> barcodeData = fullUpc.split('').map(int.parse).toList();
    bytes += generator.barcode(
      Barcode.upcA(barcodeData),
      height: 40,
      textPos: BarcodeText.below,
    );
    bytes += generator.feed(2);
    bytes += generator.text('.', styles: PosStyles(align: PosAlign.right));

    //     ),
    //     PosColumn(text: item['name']!, width: 6),
    //     PosColumn(
    //       text: item['price']!.toString(),
    //       width: 3,
    //       styles: PosStyles(align: PosAlign.right),
    //     ),
    //   ]);
    // }

    // POS Dino Gaters Copy
    bytes += generator.feed(3);
    bytes += generator.text(
      '-------- GATER\'S COPY --------',
      styles: PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );
    bytes += generator.feed(1);
    bytes += generator.text(
      'Issued by: ${userData['name']}',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Date: $dateTime',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.feed(1);
    // // Item Breakdown
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
          text: item['quantity']!.toString(),
          width: 3,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(text: item['name']!, width: 6),
        PosColumn(
          text: item['price']!.toString(),
          width: 3,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    bytes += generator.feed(1);
    bytes += generator.barcode(
      Barcode.upcA(barcodeData),
      height: 40,
      textPos: BarcodeText.below,
    );
    bytes += generator.feed(2);
    bytes += generator.text('.', styles: PosStyles(align: PosAlign.right));

    dynamic test = 1;
    if (test == 1) {
      bytes += generator.text(
        '----- CLAIM STUB -----',
        styles: PosStyles(align: PosAlign.center, bold: true),
      );
      bytes += generator.feed(1);
      bytes += generator.row([
        PosColumn(text: 'Date:', width: 5, styles: PosStyles(bold: false)),
        PosColumn(
          text: 'January 29, 2002',
          width: 7,
          styles: PosStyles(bold: false, align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Time:', width: 6, styles: PosStyles(bold: false)),
        PosColumn(
          text: '11:09 PM',
          width: 6,
          styles: PosStyles(bold: false, align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: 'Transaction No:',
          width: 6,
          styles: PosStyles(bold: false),
        ),
        PosColumn(
          text: '000001',
          width: 6,
          styles: PosStyles(bold: false, align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(text: 'Stub No:', width: 6, styles: PosStyles(bold: false)),
        PosColumn(
          text: '000001',
          width: 6,
          styles: PosStyles(bold: false, align: PosAlign.right),
        ),
      ]);
      bytes += generator.text(
        '-------------------------------',
        styles: PosStyles(align: PosAlign.center, bold: false),
      );
      bytes += generator.feed(1);
      bytes += generator.row([
        PosColumn(
          text: 'Qty',
          width: 2,
          styles: PosStyles(bold: false, align: PosAlign.left),
        ),
        PosColumn(
          text: 'Name',
          width: 6,
          styles: PosStyles(bold: false, align: PosAlign.left),
        ),
        PosColumn(
          text: 'Price',
          width: 4,
          styles: PosStyles(bold: false, align: PosAlign.left),
        ),
      ]);
      bytes += generator.feed(1);
      bytes += generator.row([
        PosColumn(
          text: '1',
          width: 2,
          styles: PosStyles(bold: true, align: PosAlign.left),
        ),
        PosColumn(
          text: 'Barkada',
          width: 6,
          styles: PosStyles(bold: true, align: PosAlign.left),
        ),
        PosColumn(
          text: 'P 3500',
          width: 4,
          styles: PosStyles(bold: true, align: PosAlign.left),
        ),
      ]);
      bytes += generator.feed(1);
      bytes += generator.text(
        '     x 5 DM1',
        styles: PosStyles(align: PosAlign.left, bold: false),
      );
      bytes += generator.text(
        '     x 5 DM2',
        styles: PosStyles(align: PosAlign.left, bold: false),
      );
      bytes += generator.text(
        '     x 5 DM3',
        styles: PosStyles(align: PosAlign.left, bold: false),
      );
      bytes += generator.feed(2);
      bytes += generator.text(
        'PRESENT THIS STUB TO TEREKEN',
        styles: PosStyles(align: PosAlign.center, bold: false),
      );
      bytes += generator.feed(2);
      bytes += generator.text(
        '.',
        styles: PosStyles(align: PosAlign.right, bold: false),
      );
    }

    // BIR FORMAT

    // bytes += generator.text(
    //   '-------- INVOICE --------',
    //   styles: PosStyles(
    //     align: PosAlign.center,
    //     bold: true,
    //     height: PosTextSize.size1,
    //     width: PosTextSize.size1,
    //   ),
    // );

    // bytes += generator.feed(1);

    // // Business Details

    // bytes += generator.text(
    //   'Thermozone Philippines Corp.',
    //   styles: PosStyles(
    //     align: PosAlign.center,
    //     bold: true,
    //     height: PosTextSize.size1,
    //     width: PosTextSize.size1,
    //   ),
    // );
    // bytes += generator.text(
    //   storeAddress,
    //   styles: PosStyles(align: PosAlign.center),
    // );
    // bytes += generator.text(
    //   'VAT REG TIN: 223 661 818 0000',
    //   styles: PosStyles(align: PosAlign.center),
    // );
    // bytes += generator.feed(1);
    // bytes += generator.hr();
    // bytes += generator.feed(1);

    // // Transaction Details

    // bytes += generator.text(
    //   'Machine No: XXXXXXXXXX',
    //   styles: PosStyles(align: PosAlign.left),
    // );
    // bytes += generator.text(
    //   'Hardware Serial: XXXXXXXXXX',
    //   styles: PosStyles(align: PosAlign.left),
    // );
    // bytes += generator.feed(1);
    // bytes += generator.text(
    //   'Issued by: ${userData['name']}',
    //   styles: PosStyles(align: PosAlign.left),
    // );
    // bytes += generator.text(
    //   'INVOICE NO: ${invoiceId.padLeft(8 - invoiceId.length, '0')}',
    //   styles: PosStyles(align: PosAlign.left),
    // );
    // bytes += generator.text(
    //   'Date: $dateTime',
    //   styles: PosStyles(align: PosAlign.left),
    // );
    // bytes += generator.text(
    //   'Payment Method: ${methodName.toUpperCase()}',
    //   styles: PosStyles(align: PosAlign.left),
    // );
    // bytes += generator.feed(1);
    // bytes += generator.hr();
    // bytes += generator.feed(1);

    // // Customer Details
    // bytes += generator.text(
    //   '----- CUSTOMER DETAILS -----',
    //   styles: PosStyles(align: PosAlign.center, bold: true),
    // );
    // bytes += generator.feed(1);
    // bytes += generator.row([
    //   PosColumn(text: 'Name:', width: 2),
    //   PosColumn(
    //     text: '................',
    //     width: 10,
    //     styles: PosStyles(bold: true),
    //   ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(text: 'Address:', width: 2),
    //   PosColumn(
    //     text: '...............................',
    //     width: 10,
    //     styles: PosStyles(bold: true),
    //   ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(text: 'TIN:', width: 2),
    //   PosColumn(
    //     text: 'XXX XXX XXX XXXX',
    //     width: 10,
    //     styles: PosStyles(bold: true),
    //   ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(text: 'Business Style:', width: 2),
    //   PosColumn(text: '...........', width: 10, styles: PosStyles(bold: true)),
    // ]);
    // bytes += generator.feed(1);
    // bytes += generator.hr();
    // bytes += generator.feed(1);

    // // Item Breakdown
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Qty',
    //     width: 3,
    //     styles: PosStyles(align: PosAlign.left, bold: true),
    //   ),
    //   PosColumn(text: 'Item', width: 6, styles: PosStyles(bold: true)),
    //   PosColumn(
    //     text: 'Price',
    //     width: 3,
    //     styles: PosStyles(align: PosAlign.left, bold: true),
    //   ),
    // ]);
    // bytes += generator.feed(1);
    // for (var item in items) {
    //   bytes += generator.row([
    //     PosColumn(
    //       text: item['quantity']!.toString(),
    //       width: 3,
    //       styles: PosStyles(align: PosAlign.left),
    //     ),
    //     PosColumn(text: item['name']!, width: 6),
    //     PosColumn(
    //       text: item['price']!.toString(),
    //       width: 3,
    //       styles: PosStyles(align: PosAlign.right),
    //     ),
    //   ]);
    // }
    // bytes += generator.feed(1);
    // bytes += generator.hr();
    // bytes += generator.feed(1);
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Discount:',
    //     width: 9,
    //     styles: PosStyles(align: PosAlign.left),
    //   ),
    //   PosColumn(
    //     text: 'P 0.00',
    //     width: 3,
    //     styles: PosStyles(align: PosAlign.right),
    //   ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Transaction Fee:',
    //     width: 9,
    //     styles: PosStyles(align: PosAlign.left),
    //   ),
    //   PosColumn(
    //     text:
    //         accountingData['transaction_fee'] == null
    //             ? 'P 0.00'
    //             : 'P ${accountingData['transaction_fee']}',
    //     width: 3,
    //     styles: PosStyles(align: PosAlign.right),
    //   ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Cash Tendered:',
    //     width: 9,
    //     styles: PosStyles(align: PosAlign.left),
    //   ),
    //   PosColumn(
    //     text: 'P ${accountingData['cash_tendered']}',
    //     width: 3,
    //     styles: PosStyles(align: PosAlign.right),
    //   ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'VATable Sales:',
    //     width: 9,
    //     styles: PosStyles(align: PosAlign.left),
    //   ),
    //   PosColumn(
    //     text: 'P ${accountingData['vatable_sales']}',
    //     width: 3,
    //     styles: PosStyles(align: PosAlign.right),
    //   ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Change:',
    //     width: 9,
    //     styles: PosStyles(align: PosAlign.left),
    //   ),
    //   PosColumn(
    //     text: 'P ${accountingData['change']}',
    //     width: 3,
    //     styles: PosStyles(align: PosAlign.right),
    //   ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'VAT:',
    //     width: 9,
    //     styles: PosStyles(align: PosAlign.left),
    //   ),
    //   PosColumn(
    //     text: 'P ${accountingData['vat']}',
    //     width: 3,
    //     styles: PosStyles(align: PosAlign.right),
    //   ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'VAT Exempt Sales:',
    //     width: 9,
    //     styles: PosStyles(align: PosAlign.left),
    //   ),
    //   PosColumn(
    //     text: 'P ${accountingData['vat_exempt_sales']}',
    //     width: 3,
    //     styles: PosStyles(align: PosAlign.right),
    //   ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Zero-Rated Sales:',
    //     width: 9,
    //     styles: PosStyles(align: PosAlign.left),
    //   ),
    //   PosColumn(
    //     text: 'P ${accountingData['zero_rated_sales']}',
    //     width: 3,
    //     styles: PosStyles(align: PosAlign.right),
    //   ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Total Sales:',
    //     width: 9,
    //     styles: PosStyles(align: PosAlign.left),
    //   ),
    //   PosColumn(
    //     text: 'P ${accountingData['total_sales']}',
    //     width: 3,
    //     styles: PosStyles(align: PosAlign.right),
    //   ),
    // ]);
    // bytes += generator.feed(2);
    // bytes += generator.text(
    //   'THIS DOCUMENT IS NOT VALID FOR CLAIM OF INPUT TAX',
    //   styles: PosStyles(
    //     align: PosAlign.center,
    //     bold: true,
    //     height: PosTextSize.size1,
    //     width: PosTextSize.size1,
    //   ),
    // );
    // bytes += generator.feed(2);
    // String formattedInvoiceId = invoiceId.padLeft(6, '0');
    // String fullUpc = formattedInvoiceId.padLeft(12, '0');
    // List<int> barcodeData = fullUpc.split('').map(int.parse).toList();
    // bytes += generator.barcode(
    //   Barcode.upcA(barcodeData),
    //   height: 40,
    //   textPos: BarcodeText.below,
    // );
    // bytes += generator.feed(2);
    // bytes += generator.text(
    //   'THERMOZONE PHILIPPINES CORP.',
    //   styles: PosStyles(align: PosAlign.center),
    // );
    // bytes += generator.text(
    //   '2280 Marconi St. Makati City',
    //   styles: PosStyles(align: PosAlign.center),
    // );
    // bytes += generator.text(
    //   'VAT REG TIN: 223-661-818-00000',
    //   styles: PosStyles(align: PosAlign.center),
    // );
    // bytes += generator.text(
    //   'Accreditation Number: XXXXXXXX',
    //   styles: PosStyles(align: PosAlign.center),
    // );
    // bytes += generator.text(
    //   'ATG Number: XXXXXXXX',
    //   styles: PosStyles(align: PosAlign.center),
    // );
    // bytes += generator.feed(2);
    // bytes += generator.text('.', styles: PosStyles(align: PosAlign.right));

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
