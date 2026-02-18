import 'dart:async';
import 'package:bir_pos/models/customer.dart';
import 'package:bir_pos/models/reprint_receipt.dart';
import 'package:bir_pos/services/customer_details_service.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'print/document_header.dart';
import 'print/document_footer.dart';

class PrinterService {
  final PrinterManager printerManager = PrinterManager.instance;

  Future<void> printReceipt({
    required BuildContext context,
    required TransactionResponse transaction,
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
            print("🖨️ Found device: ${device.name}");

            // ✅ Filter by name: Match only if contains "xprinter" or "xp-58"
            final name = device.name.toLowerCase();
            if (!name.contains('xprinter') &&
                !name.contains('xp-58') &&
                !name.contains('pos58') &&
                !name.contains('pos58 printer')) {
              print("⛔ Skipped non-Xprinter: ${device.name}");
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

              print("✅ Printing to: ${selectedPrinter!.deviceName}");

              await _printReceiptToDevice(
                selectedPrinter!,
                transaction,
                customer,
                // stubDetails,
              );

              await subscription?.cancel();
            }
          },
          onError: (e) {
            print("❌ Printer discovery error: $e");
          },
        );

    await Future.delayed(const Duration(seconds: 3));
    await subscription.cancel();

    if (!isPrinted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No supported printer found (Xprinter/XP-58).'),
        ),
      );
      return;
    }
  }

  Future<void> _printReceiptToDevice(
    BluetoothPrinter printer,
    TransactionResponse transaction,
    Customer? customer,
  ) async {
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // // DINO FORMAT
    // bytes += generator.feed(1);
    // bytes += generator.text(
    //   '-------- CASHIER\'S COPY --------',
    //   styles: PosStyles(
    //     align: PosAlign.center,
    //     bold: true,
    //     height: PosTextSize.size1,
    //     width: PosTextSize.size1,
    //   ),
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
    // bytes += generator.feed(1);
    // // // Item Breakdown
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
    //       text: item['price'].roundToDouble()!.toString(),
    //       width: 3,
    //       styles: PosStyles(align: PosAlign.right),
    //     ),
    //   ]);
    // }
    // bytes += generator.feed(1);
    // bytes += generator.row([
    //   PosColumn(
    //     text: 'Discount:',
    //     width: 9,
    //     styles: PosStyles(align: PosAlign.left),
    //   ),
    //   PosColumn(
    //     text:
    //         accountingData['discount_value'] == null
    //             ? 'P 0.00'
    //             : 'P ${accountingData['discount_value']}',
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
    //   Barcode.ean13(barcodeData),
    //   height: 40,
    //   textPos: BarcodeText.below,
    // );
    // bytes += generator.feed(2);
    // bytes += generator.text('.', styles: PosStyles(align: PosAlign.right));

    // //     ),
    // //     PosColumn(text: item['name']!, width: 6),
    // //     PosColumn(
    // //       text: item['price']!.toString(),
    // //       width: 3,
    // //       styles: PosStyles(align: PosAlign.right),
    // //     ),
    // //   ]);
    // // }

    // // POS Dino Gaters Copy
    // bytes += generator.feed(2);
    // // bytes += generator.text(
    // //   '-------- GATER\'S COPY --------',
    // //   styles: PosStyles(
    // //     align: PosAlign.center,
    // //     bold: true,
    // //     height: PosTextSize.size1,
    // //     width: PosTextSize.size1,
    // //   ),
    // // );
    // // bytes += generator.feed(1);
    // // bytes += generator.text(
    // //   'Issued by: ${userData['name']}',
    // //   styles: PosStyles(align: PosAlign.left),
    // // );
    // // bytes += generator.text(
    // //   'Date: $dateTime',
    // //   styles: PosStyles(align: PosAlign.left),
    // // );
    // // bytes += generator.feed(1);
    // // // // Item Breakdown
    // // bytes += generator.row([
    // //   PosColumn(
    // //     text: 'Qty',
    // //     width: 3,
    // //     styles: PosStyles(align: PosAlign.left, bold: true),
    // //   ),
    // //   PosColumn(text: 'Item', width: 6, styles: PosStyles(bold: true)),
    // //   PosColumn(
    // //     text: 'Price',
    // //     width: 3,
    // //     styles: PosStyles(align: PosAlign.left, bold: true),
    // //   ),
    // // ]);
    // // bytes += generator.feed(1);
    // // for (var item in items) {
    // //   bytes += generator.row([
    // //     PosColumn(
    // //       text: item['quantity']!.toString(),
    // //       width: 3,
    // //       styles: PosStyles(align: PosAlign.left),
    // //     ),
    // //     PosColumn(text: item['name']!, width: 6),
    // //     PosColumn(
    // //       text: item['price']!.toString(),
    // //       width: 3,
    // //       styles: PosStyles(align: PosAlign.right),
    // //     ),
    // //   ]);
    // // }
    // // bytes += generator.feed(1);
    // // bytes += generator.barcode(
    // //   Barcode.upcA(barcodeData),
    // //   height: 40,
    // //   textPos: BarcodeText.below,
    // // );
    // // bytes += generator.feed(2);
    // // bytes += generator.text('.', styles: PosStyles(align: PosAlign.right));
    // print(stubDetails);

    // if (stubDetails['has_inclusive'] == true) {
    //   for (var stub in stubDetails['stubs']) {
    //     bytes += generator.text(
    //       '----- CLAIM STUB -----',
    //       styles: PosStyles(align: PosAlign.center, bold: true),
    //     );
    //     bytes += generator.feed(1);
    //     final date = DateTime.now();
    //     final formattedDate = DateFormat('MMMM d, y').format(date);

    //     final now = DateTime.now();
    //     final formattedTime = DateFormat('h:mm a').format(now);
    //     bytes += generator.row([
    //       PosColumn(text: 'Date:', width: 5, styles: PosStyles(bold: false)),
    //       PosColumn(
    //         text: formattedDate,
    //         width: 7,
    //         styles: PosStyles(bold: false, align: PosAlign.right),
    //       ),
    //     ]);
    //     bytes += generator.row([
    //       PosColumn(text: 'Time:', width: 6, styles: PosStyles(bold: false)),
    //       PosColumn(
    //         text: formattedTime,
    //         width: 6,
    //         styles: PosStyles(bold: false, align: PosAlign.right),
    //       ),
    //     ]);
    //     bytes += generator.row([
    //       PosColumn(text: 'Stub No:', width: 4, styles: PosStyles(bold: false)),
    //       PosColumn(
    //         text: stub['stub_no'],
    //         width: 8,
    //         styles: PosStyles(bold: false, align: PosAlign.right),
    //       ),
    //     ]);
    //     bytes += generator.text(
    //       '-------------------------------',
    //       styles: PosStyles(align: PosAlign.center, bold: false),
    //     );
    //     bytes += generator.feed(1);
    //     bytes += generator.row([
    //       PosColumn(
    //         text: 'Qty',
    //         width: 2,
    //         styles: PosStyles(bold: false, align: PosAlign.left),
    //       ),
    //       PosColumn(
    //         text: 'Name',
    //         width: 6,
    //         styles: PosStyles(bold: false, align: PosAlign.left),
    //       ),
    //       PosColumn(
    //         text: 'Price',
    //         width: 4,
    //         styles: PosStyles(bold: false, align: PosAlign.left),
    //       ),
    //     ]);
    //     bytes += generator.feed(1);
    //     bytes += generator.row([
    //       PosColumn(
    //         text: stub['quantity'].toString(),
    //         width: 2,
    //         styles: PosStyles(bold: false, align: PosAlign.left),
    //       ),
    //       PosColumn(
    //         text: stub['name'],
    //         width: 6,
    //         styles: PosStyles(bold: false, align: PosAlign.left),
    //       ),
    //       PosColumn(
    //         text: stub['price'].toString(),
    //         width: 4,
    //         styles: PosStyles(bold: false, align: PosAlign.left),
    //       ),
    //     ]);
    //     bytes += generator.feed(1);

    //     for (var item in stub['items']) {
    //       final qty = item['qty'] ?? 0;
    //       final name = item['name'] ?? '';
    //       bytes += generator.text(
    //         '     x $qty $name',
    //         styles: PosStyles(align: PosAlign.left),
    //       );
    //     }
    //   }
    //   bytes += generator.feed(2);
    //   bytes += generator.text(
    //     'PRESENT THIS STUB TO TEREKEN',
    //     styles: PosStyles(align: PosAlign.center, bold: false),
    //   );
    //   bytes += generator.feed(2);
    //   bytes += generator.text(
    //     '.',
    //     styles: PosStyles(align: PosAlign.right, bold: false),
    //   );
    // }

    // BIR FORMAT

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
    bytes += buildReceiptHeader(generator);

    bytes += generator.feed(1);
    bytes += generator.hr();
    bytes += generator.feed(1);

    // Transaction Details
    bytes += generator.text(
      'Issued by: ${transaction.transactionDetails.processedBy}',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'SI NO: ${transaction.transactionDetails.siNo}',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Date: ${transaction.transactionDetails.date}',
      styles: PosStyles(align: PosAlign.left),
    );
    bytes += generator.text(
      'Time: ${transaction.transactionDetails.time}',
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
    num totalItems = 0;
    for (var item in transaction.items) {
      totalItems += item.quantity;
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
          text: '@${item.price.toStringAsFixed(2)}',
          width: 3,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: (item.quantity * item.price).toStringAsFixed(2),
          width: 3,
          styles: PosStyles(align: PosAlign.left),
        ),
      ]);
    }

    // for (var paymentMethod in transaction.paymentMethods) {
    //   print(paymentMethod.paymentMethodName);
    //   print(paymentMethod.cashTendered);
    // }

    // Discounted Items Breakdown

    // for (var item in transaction.discountedItems) {
    //   bytes += generator.row([
    //     PosColumn(
    //       text: item.quantity.toString(),
    //       width: 3,
    //       styles: PosStyles(align: PosAlign.left),
    //     ),
    //     PosColumn(
    //       text: item.name,
    //       width: 3,
    //       styles: PosStyles(align: PosAlign.left),
    //     ),
    //     PosColumn(
    //       text: item.price.toStringAsFixed(2),
    //       width: 3,
    //       styles: PosStyles(align: PosAlign.left),
    //     ),
    //     PosColumn(
    //       text: (item.quantity * item.price).toStringAsFixed(2),
    //       width: 3,
    //       styles: PosStyles(align: PosAlign.left),
    //     ),
    //   ]);
    // }
    bytes += generator.feed(1);
    bytes += generator.hr();
    if (transaction.discountedItems.isNotEmpty) {
      bytes += generator.feed(1);
      bytes += generator.text(
        '$totalItems Item(s)',
        styles: PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      );
      bytes += generator.row([
        PosColumn(
          text: 'Subtotal:',
          width: 7,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text:
              'P ${(transaction.transactionDetails.grossSales + transaction.transactionDetails.vatAdjustments).toStringAsFixed(2)}',
          width: 5,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.feed(1);
      bytes += generator.hr();
      bytes += generator.feed(1);
      bytes += generator.row([
        PosColumn(
          text: 'Less Disc VAT:',
          width: 7,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text:
              'P ${transaction.transactionDetails.vatAdjustments.toStringAsFixed(2)}',
          width: 5,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.row([
        PosColumn(
          text: 'Gross Total:',
          width: 7,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text:
              'P ${transaction.transactionDetails.grossSales.toStringAsFixed(2)}',
          width: 5,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
      bytes += generator.feed(1);
      bytes += generator.hr();
    }
    for (var item in transaction.discountedItems) {
      if (transaction.transactionDetails.is_sc == true) {
        bytes += generator.row([
          PosColumn(
            text: 'Less SC @ 20%:',
            width: 7,
            styles: PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: 'P ${item.discountValue.toStringAsFixed(2)}',
            width: 5,
            styles: PosStyles(align: PosAlign.right),
          ),
        ]);
      } else if (transaction.transactionDetails.is_pwd == true) {
        bytes += generator.row([
          PosColumn(
            text: 'Less PWD @ 20%:',
            width: 7,
            styles: PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: 'P ${item.discountValue.toStringAsFixed(2)}',
            width: 5,
            styles: PosStyles(align: PosAlign.right),
          ),
        ]);
      } else if (transaction.transactionDetails.is_nac == true) {
        bytes += generator.row([
          PosColumn(
            text: 'Less NAAC @ 20%:',
            width: 7,
            styles: PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: 'P ${item.discountValue.toStringAsFixed(2)}',
            width: 5,
            styles: PosStyles(align: PosAlign.right),
          ),
        ]);
      } else if (transaction.transactionDetails.is_soloparent == true) {
        bytes += generator.row([
          PosColumn(
            text: 'Less SP @ 10%:',
            width: 7,
            styles: PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: 'P ${item.discountValue.toStringAsFixed(2)}',
            width: 5,
            styles: PosStyles(align: PosAlign.right),
          ),
        ]);
      } else {}
    }
    if (transaction.discountedItems.isEmpty) {
      bytes += generator.row([
        PosColumn(
          text: 'Gross Total:',
          width: 7,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text:
              'P ${transaction.transactionDetails.grossSales.toStringAsFixed(2)}',
          width: 5,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
    }
    for (var paymentMethod in transaction.paymentMethods) {
      bytes += generator.row([
        PosColumn(
          text: '${paymentMethod.paymentMethodName} Payment:',
          width: 8,
          styles: PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: 'P ${paymentMethod.cashTendered.toStringAsFixed(2)}',
          width: 4,
          styles: PosStyles(align: PosAlign.right),
        ),
      ]);
      // print(paymentMethod.paymentMethodName);
      // print(paymentMethod.cashTendered);
    }
    bytes += generator.row([
      PosColumn(
        text: 'Total Amount Paid:',
        width: 7,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text:
            'P ${transaction.transactionDetails.cashTendered.toStringAsFixed(2)}',
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
        text: 'P ${transaction.transactionDetails.change.toStringAsFixed(2)}',
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
        text:
            'P ${transaction.transactionDetails.vatableSales.toStringAsFixed(2)}',
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
        text: 'P ${transaction.transactionDetails.vat.toStringAsFixed(2)}',
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
        text:
            'P ${transaction.transactionDetails.vatExemptSales.toStringAsFixed(2)}',
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
        text:
            'P ${transaction.transactionDetails.zeroRatedSales.toStringAsFixed(2)}',
        width: 5,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Amount Due:',
        width: 7,
        styles: PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text:
            'P ${transaction.transactionDetails.totalSales.toStringAsFixed(2)}',
        width: 5,
        styles: PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.feed(2);
    List<int> barcodeData =
        transaction.transactionDetails.siNo.split('').map(int.parse).toList();
    bytes += generator.barcode(
      Barcode.ean13(barcodeData),
      height: 40,
      textPos: BarcodeText.below,
    );
    bytes += generator.feed(2);

    bytes += buildReceiptFooter(generator);

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
