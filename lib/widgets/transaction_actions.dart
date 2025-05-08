import 'package:bir_pos/widgets/terminal_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:bir_pos/widgets/payment_method_buttons.dart';
import 'package:bir_pos/widgets/discount_buttons.dart';

class TransactionActions extends StatelessWidget {
  final ValueChanged setTransactionMethod;
  final ValueChanged addToTransactionsDiscount;
  final ValueChanged addGovDiscountDetails;
  final ValueChanged setCashTendered;

  final VoidCallback processTransactions;
  final VoidCallback resetTransactionData;
  final VoidCallback toggleIsFirstPrint;
  final VoidCallback printReceipt;

  final isFirstPrint;

  TransactionActions({
    Key? key,
    required this.setTransactionMethod,
    required this.addToTransactionsDiscount,
    required this.addGovDiscountDetails,
    required this.processTransactions,
    required this.setCashTendered,
    required this.resetTransactionData,
    required this.toggleIsFirstPrint,
    required this.printReceipt,
    required this.isFirstPrint,
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
                Tab(text: 'Discounts'),
                Tab(text: 'Payment Method'),
                Tab(text: 'Actions'),
              ],
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                children: [
                  // Discounts Tab
                  DiscountSelector(
                    addToTransactionDiscounts: addToTransactionsDiscount,
                    addGovDiscountDetails: addGovDiscountDetails,
                  ),

                  // Payment Methods Tab
                  PaymentMethodButtons(
                    setCashTendered: setCashTendered,
                    setTransactionMethod: setTransactionMethod,
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
