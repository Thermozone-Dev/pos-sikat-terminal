import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DiscountInfoForm extends StatefulWidget {
  final int selectedDiscount;
  final ValueChanged addGovDiscountDetails;

  const DiscountInfoForm({
    Key? key,
    required this.selectedDiscount,
    required this.addGovDiscountDetails,
  }) : super(key: key);

  @override
  State<DiscountInfoForm> createState() => _DiscountInfoFormState();
}

class _DiscountInfoFormState extends State<DiscountInfoForm> {
  int? selectedDiscount;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDiscount = widget.selectedDiscount;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? discountInfoData = {};

    return AlertDialog(
      title: Text('Add Discount'),
      scrollable: true,
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (widget.selectedDiscount == 1)
              Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      discountInfoData['sc'] = {'name': value};
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'OSCA ID Number',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      discountInfoData['sc']['id'] = value;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'TIN ID Number',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      discountInfoData['sc']['tin'] = value;
                    },
                  ),
                ],
              ),
            if (widget.selectedDiscount == 2)
              Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      discountInfoData['pwd'] = {'name': value};
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'PWD ID Number',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      discountInfoData['pwd']['id'] = value;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'TIN ID Number',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      discountInfoData['pwd']['tin'] = value;
                    },
                  ),
                ],
              ),
            if (widget.selectedDiscount == 3)
              Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      discountInfoData['nac'] = {'name': value};
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'PNSTM ID Number',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      discountInfoData['nac']['id'] = value;
                    },
                  ),
                ],
              ),
            if (widget.selectedDiscount == 4)
              Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      discountInfoData['sp'] = {'name': value};
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'SPIC ID Number',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      discountInfoData['sp']['id'] = value;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Child Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      discountInfoData['sp']['child_name'] = value;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Child Age',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      discountInfoData['sp']['child_age'] = value;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Child Birthday',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    controller: _textEditingController,
                    onTap:
                        () => showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(
                            DateTime.now().year - 18,
                            DateTime.now().month,
                            DateTime.now().day,
                          ),
                          lastDate: DateTime.now(),
                        ).then((value) {
                          if (value != null) {
                            final formattedDate = DateFormat(
                              'yyyy-MM-dd',
                            ).format(value);
                            _textEditingController.text = formattedDate;
                            discountInfoData['sp']['child_birthday'] =
                                formattedDate;
                          }
                        }),
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Handle the discount application logic here
            widget.addGovDiscountDetails(discountInfoData);
            Navigator.of(context).pop();
          },
          child: Text('Apply Discount'),
        ),
      ],
    );
  }
}
