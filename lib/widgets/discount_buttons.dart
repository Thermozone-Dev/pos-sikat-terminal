import 'package:bir_pos/widgets/discount_info_form.dart';
import 'package:flutter/material.dart';
import '../models/discount.dart';
import '../services/discount_service.dart';

class DiscountSelector extends StatelessWidget {
  final int selectedDiscount;

  final ValueChanged addToTransactionDiscounts;
  final ValueChanged addGovDiscountDetails;

  const DiscountSelector({
    Key? key,
    required this.addToTransactionDiscounts,
    required this.selectedDiscount,
    required this.addGovDiscountDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      height: 120,
      child: FutureBuilder<List<Discount>>(
        future: DiscountService.getDiscounts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No discounts found'));
          }

          final discounts = snapshot.data!;

          return GridView.builder(
            scrollDirection: Axis.horizontal,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.4,
            ),
            itemCount: discounts.length,
            itemBuilder: (context, index) {
              final discount = discounts[index];

              return AspectRatio(
                aspectRatio: 1,
                child: ElevatedButton(
                  onPressed: () {
                    if (discount.id > 0 && discount.id < 4) {
                      DiscountInfoForm(
                        selectedDiscount: selectedDiscount,
                        addGovDiscountDetails: addGovDiscountDetails,
                      );
                    } // Handle other discount types if needed
                    addToTransactionDiscounts(discount.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    iconColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        discount.name,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
