import 'package:bir_pos/models/user.dart';
import 'package:bir_pos/services/auth_service.dart';
import 'package:bir_pos/services/transaction_service.dart';
import 'package:bir_pos/widgets/greeter.dart';
import 'package:flutter/material.dart';
import 'models/product.dart';
import 'models/package.dart';
import 'package:bir_pos/services/package_service.dart';
import 'package:bir_pos/services/product_service.dart';
import 'package:bir_pos/widgets/section_header.dart';
import 'package:bir_pos/widgets/package_card.dart';
import 'package:bir_pos/widgets/product_card.dart';
import 'package:bir_pos/widgets/drawer.dart';
import 'package:bir_pos/widgets/shopping_cart.dart';
import 'package:bir_pos/widgets/total_cost.dart';
import 'package:bir_pos/widgets/transaction_actions.dart';
import 'package:bir_pos/utils/responsive_util.dart';

class Terminal extends StatefulWidget {
  final String token;

  const Terminal({Key? key, required this.token}) : super(key: key);

  @override
  State<Terminal> createState() => _TerminalState();
}

class _TerminalState extends State<Terminal> {
  Map<String, dynamic> transactionData = {
    'items': [],
    'transaction_method': null,
    'transaction_is_digital': false,
    'transaction_fee': null,
    'cash_tendered': 0.0,
    'total_sales': 0.0,
    'change': 0.0,
    'gross_sales': 0.0,
    'vatable_sales': 0.0,
    'vat': 0.0,
    'vat_exempt_sales': 0.0,
    'zero_rated_sales': 0.0,
    'transaction_discounts': [],
    'gov_discount_details': {},
  };

  bool isDigitalPayment = false;
  bool isFirstPrint = true;

  void toggleIsFirstPrint() {
    setState(() {
      isFirstPrint = !isFirstPrint;
    });
  }

  void resetTransactionData() {
    setState(() {
      transactionData = {
        'items': [],
        'transaction_method': null,
        'transaction_is_digital': false,
        'transaction_fee': null,
        'cash_tendered': 0.0,
        'total_sales': 0.0,
        'change': 0.0,
        'gross_sales': 0.0,
        'vatable_sales': 0.0,
        'vat': 0.0,
        'vat_exempt_sales': 0.0,
        'zero_rated_sales': 0.0,
        'transaction_discounts': [],
        'gov_discount_details': {},
      };
    });
  }

  void addItem(itemData) {
    setState(() {
      bool canAdd = true;

      if (!transactionData['items'].isEmpty) {
        for (var item in transactionData['items']) {
          if (item['data']['id'] == itemData['data']['id']) {
            if (itemData['data']['item_discounts'] == null ||
                itemData['data']['item_discounts'].isEmpty) {
              item['quantity'] += 1;
              canAdd = false;
              break;
            }
          }
        }
      }

      if (canAdd) {
        transactionData['items'].add(itemData);
      }

      calculateValues();
    });
  }

  void removeItem(index) {
    setState(() {
      transactionData['items'].removeAt(index);
      calculateValues();
    });
  }

  void increaseQuantity(index) {
    final item = transactionData['items'][index];
    setState(() {
      item['quantity'] += 1;
      calculateValues();
    });
  }

  void decreaseQuantity(index) {
    final item = transactionData['items'][index];
    setState(() {
      item['quantity'] -= 1;
      if (item['quantity'] < 1) {
        removeItem(index);
      }
      calculateValues();
    });
  }

  void setCashTendered(cashTendered) {
    transactionData['cash_tendered'] = cashTendered;
    calculateValues();
  }

  void setTransactionMethod(transactionMethod) {
    transactionData['transaction_method'] = transactionMethod.id;
    transactionData['transaction_is_digital'] = transactionMethod.isDigital;
    calculateValues();
  }

  void setTransactionFee(transactionFee) {
    transactionData['transaction_fee'] = transactionFee;
    calculateValues();
  }

  void addItemDiscount(item) {
    setState(() {
      final initialItem = transactionData['items'][item['index']];
      if (initialItem['data']['item_discounts'] == null ||
          initialItem['data']['item_discounts'].isEmpty) {
        final data = {
          'data': initialItem['data'],
          'quantity': item['quantity'],
        };

        data['data']['item_discounts'] = [item['discount_id']];
        addItem(data);
        initialItem['quantity'] -= item['quantity'];
        print(initialItem['quantity']);
        if (initialItem['quantity'] < 1) {
          removeItem(item['index']);
        }
      } else if (initialItem['item_discounts'].contains(item['discount_id'])) {
        item['context'].showSnackBar(
          SnackBar(
            content: Text('Discount already applied to this item'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        final data = {
          'data': initialItem['data'],
          'quantity': item['quantity'],
        };

        data['data']['item_discounts'].add(item['discount_id']);
        addItem(data);
        initialItem['quantity'] -= item['quantity'];
        print(initialItem['quantity']);
        if (initialItem['quantity'] < 1) {
          removeItem(item['index']);
        }
      }
      calculateValues();
    });
  }

  void addToTransactionDiscounts(transactionDiscount) {
    transactionData['transaction_discounts'].add(transactionDiscount);
    calculateValues();
  }

  void addGovDiscountDetails(govDiscountDetails) {
    String? error;
    setState(() {
      for (var discount in govDiscountDetails.keys) {
        (!transactionData['gov_discount_details'].containsKey(discount))
            ? transactionData['gov_discount_details'] = {
              discount: govDiscountDetails[discount],
            }
            : error = 'Discount info is already set';
      }
    });
    print('Gov discount details: ${transactionData['gov_discount_details']}');
    print((error != null) ? error : 'Discount info added successfully');
  }

  void calculateValues() {
    setState(() {
      transactionData = TransactionService.processCalculations(transactionData);
    });
  }

  void processTransactions() {
    calculateValues();
    final formattedData = TransactionService.formatTransactionData(
      transactionData,
    );
    TransactionService.saveTransactionData(formattedData);
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = getResponsiveCrossAxisCount(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[500],
        title: Row(
          children: [
            Image.asset(
              'assets/img/logo.png', // Replace with your image path
              height: 40, // Adjust size as needed
            ),
            const SizedBox(width: 10), // Spacing between image and text
            const Text(
              'PoS Terminal',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              color: Colors.white,
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: const MainDrawer(),
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Row(
          children: [
            Expanded(
              flex: 7,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Container
                    FutureBuilder<User>(
                      future: AuthService.getUser(context),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData) {
                          return const Center(child: Text('No user found'));
                        }
                        final User user = snapshot.data!;

                        return Greeter(user: user);
                      },
                    ),

                    FutureBuilder<List<Package>>(
                      future: PackageService.getPackages(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const SizedBox.shrink(); // Hide section if no packages
                        }

                        final packages = snapshot.data!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(title: 'Packages'),
                            Container(
                              margin: const EdgeInsets.fromLTRB(20, 0, 0, 20),
                              height: 330,
                              child: GridView.builder(
                                scrollDirection: Axis.horizontal,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 1.4,
                                    ),
                                itemCount: packages.length,
                                itemBuilder: (context, index) {
                                  final package = packages[index];
                                  return PackageCard(
                                    package: package,
                                    onPressed: addItem,
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    FutureBuilder<List<Product>>(
                      future: ProductService.getProducts(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const SizedBox.shrink(); // Hides the section if empty
                        }

                        final products = snapshot.data!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(title: 'Products'),
                            Container(
                              margin: const EdgeInsets.fromLTRB(20, 0, 0, 20),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          crossAxisCount, // Ensure this is defined above
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 0.75,
                                    ),
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  final product = products[index];
                                  return ProductCard(
                                    product: product,
                                    onPressed: addItem,
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Right Panel
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  // Shopping Cart Container
                  Expanded(
                    flex: 6,
                    child: ShoppingCart(
                      transactionData: transactionData,
                      increaseQuantity: increaseQuantity,
                      decreaseQuantity: decreaseQuantity,
                      addGovDiscountDetails: addGovDiscountDetails,
                      addItemDiscount: addItemDiscount,
                    ),
                  ),

                  // Total Cost Container
                  Expanded(
                    flex: 1,
                    child: TotalCost(totalCost: transactionData['total_sales']),
                  ),

                  // Payment Methods, Discounts, and Actions Container
                  Expanded(
                    flex: 3,
                    child: TransactionActions(
                      setTransactionMethod: setTransactionMethod,
                      processTransactions: processTransactions,
                      resetTransactionData: resetTransactionData,
                      toggleIsFirstPrint: toggleIsFirstPrint,
                      isFirstPrint: isFirstPrint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
