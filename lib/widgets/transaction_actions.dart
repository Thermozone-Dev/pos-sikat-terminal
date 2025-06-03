import 'package:bir_pos/models/discount.dart';
import 'package:bir_pos/models/payment_method.dart';
import 'package:bir_pos/widgets/terminal_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:bir_pos/widgets/payment_method_buttons.dart';
import 'package:bir_pos/widgets/discount_buttons.dart';

class TransactionActions extends StatelessWidget {
  final ValueChanged setTransactionMethod;
  final ValueChanged addToTransactionsDiscount;
  final ValueChanged addGovDiscountDetails;
  final ValueChanged setCashTendered;
  final ValueChanged setTransactionFee;

  final Future<List<Discount>> futureDiscounts;
  // final Future<List<PaymentMethod>> futureTransactionMethods;

  final bool itemsHasDiscount;
  final Map<dynamic, dynamic> transactionDiscountData;

  final VoidCallback processTransactions;
  final VoidCallback resetTransactionData;
  final VoidCallback toggleIsFirstPrint;
  final VoidCallback printReceipt;

  final double total;
  final isFirstPrint;

  TransactionActions({
    Key? key,
    required this.futureDiscounts,
    // required this.futureTransactionMethods,
    required this.transactionDiscountData,
    required this.setTransactionMethod,
    required this.addToTransactionsDiscount,
    required this.addGovDiscountDetails,
    required this.processTransactions,
    required this.setCashTendered,
    required this.setTransactionFee,
    required this.resetTransactionData,
    required this.toggleIsFirstPrint,
    required this.printReceipt,
    required this.isFirstPrint,
    required this.itemsHasDiscount,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: DefaultTabController(
        length: 3, // Number of tabs
        child: Column(
          children: [
            // TabBar at the top
            const TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.brown,
              tabs: [
                // Tab(text: 'Discounts'),
                Tab(text: 'Payment Method'),
                Tab(text: 'Actions'),
              ],
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                children: [
                  // Discounts Tab
                  // if (!itemsHasDiscount)
                  //   DiscountSelector(
                  //     addToTransactionDiscounts: addToTransactionsDiscount,
                  //     addGovDiscountDetails: addGovDiscountDetails,
                  //     futureDiscounts: futureDiscounts,
                  //   ),

                  // Payment Methods Tab
                  PaymentMethodButtons(
                    setCashTendered: setCashTendered,
                    setTransactionFee: setTransactionFee,
                    setTransactionMethod: setTransactionMethod,
                    // futureTransactionMethods: futureTransactionMethods,
                    total: total,
                  ),

                  // Actions Tab
                  TerminalActionButtons(
                    setTransactionMethod: setTransactionMethod,
                    processTransactions: processTransactions,
                    resetTransactionData: resetTransactionData,
                    toggleIsFirstPrint: toggleIsFirstPrint,
                    printReceipt: printReceipt,
                    isFirstPrint: isFirstPrint,
                  ),

                  SizedBox(width: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
