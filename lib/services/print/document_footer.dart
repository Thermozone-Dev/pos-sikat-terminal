import 'package:esc_pos_utils/esc_pos_utils.dart';

List<int> buildReceiptFooter(Generator generator) {
  List<int> bytes = [];

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
    'Date Issued: MM/DD/YYYY',
    styles: PosStyles(align: PosAlign.center),
  );
  bytes += generator.text(
    'Valid Until: MM/DD/YYYY',
    styles: PosStyles(align: PosAlign.center),
  );
  bytes += generator.text(
    'PTU No: XXXXXXXX',
    styles: PosStyles(align: PosAlign.center),
  );
  bytes += generator.text(
    'Date Issued: MM/DD/YYYY',
    styles: PosStyles(align: PosAlign.center),
  );
  bytes += generator.feed(2);
  bytes += generator.text('.', styles: PosStyles(align: PosAlign.right));

  return bytes;
}
