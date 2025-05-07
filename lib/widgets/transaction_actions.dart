import 'dart:ffi';

import 'package:bir_pos/widgets/terminal_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:bir_pos/widgets/payment_method_buttons.dart';
import 'package:bir_pos/widgets/discount_buttons.dart';
import '../print_service.dart';

class TransactionActions extends StatelessWidget {
  final ValueChanged setTransactionMethod;
  final ValueChanged addToTransactionsDiscount;
  final ValueChanged addGovDiscountDetails;

  final VoidCallback processTransactions;
  final VoidCallback resetTransactionData;
  final VoidCallback toggleIsFirstPrint;

  bool isFirstPrint;

  TransactionActions({
    Key? key,
    required this.setTransactionMethod,
    required this.addToTransactionsDiscount,
    required this.addGovDiscountDetails,
    required this.processTransactions,
    required this.resetTransactionData,
    required this.toggleIsFirstPrint,
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
                    selectedDiscount: 0,
                    addToTransactionDiscounts: addToTransactionsDiscount,
                    addGovDiscountDetails: addGovDiscountDetails,
                  ),

                  // Payment Methods Tab
                  PaymentMethodButtons(
                    setTransactionMethod: setTransactionMethod,
                  ),

                  // Actions Tab
                  TerminalActionButtons(
                    setTransactionMethod: setTransactionMethod,
                    processTransactions: processTransactions,
                    resetTransactionData: resetTransactionData,
                    toggleIsFirstPrint: toggleIsFirstPrint,
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
