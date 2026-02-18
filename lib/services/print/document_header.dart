import 'package:esc_pos_utils/esc_pos_utils.dart';

List<int> buildReceiptHeader(Generator generator) {
  List<int> bytes = [];

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

  return bytes;
}
