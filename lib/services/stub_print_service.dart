import 'dart:async';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:intl/intl.dart';

class StubPrintService {
  final PrinterManager printerManager = PrinterManager.instance;

  Future<void> printStub() async {
    BluetoothPrinter? selectedPrinter;
    bool isPrinted = false;

    StreamSubscription<PrinterDevice>? subscription;
    subscription = printerManager.discovery(type: PrinterType.usb).listen((
      device,
    ) async {
      if (isPrinted) return;

      selectedPrinter = BluetoothPrinter(
        deviceName: device.name,
        address: device.address,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: PrinterType.usb,
      );

      if (selectedPrinter != null && !isPrinted) {
        isPrinted = true;
        subscription?.cancel();
        await _printStaticText(selectedPrinter!);
      }
    });

    await Future.delayed(const Duration(seconds: 2));
    subscription.cancel();
  }

  Future<void> _printStaticText(BluetoothPrinter printer) async {
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(PaperSize.mm58, profile);
    final String formattedDate = DateFormat(
      'MMMM dd, yyyy',
    ).format(DateTime.now());

    List<int> bytes = [];
    bytes += generator.text(
      '----- CLAIM STUB -----',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);
    bytes += generator.row([
      PosColumn(text: 'Date:', width: 6, styles: PosStyles(bold: false)),
      PosColumn(
        text: formattedDate,
        width: 6,
        styles: PosStyles(bold: false, align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: 'Processed by:',
        width: 6,
        styles: PosStyles(bold: false),
      ),
      PosColumn(
        text: 'Angelo Marquez',
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
    bytes += generator.text(
      '------- ITEMS -------',
      styles: PosStyles(align: PosAlign.center, bold: true),
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
      'THIS STUB HAS BEEN CLAIMED',
      styles: PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);
    bytes += generator.cut();

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
