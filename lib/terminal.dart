import 'package:bir_pos/models/discount.dart';
import 'package:bir_pos/models/payment_method.dart';
import 'package:bir_pos/models/user.dart';
import 'package:bir_pos/services/cart_service.dart';
import 'package:bir_pos/services/discount_service.dart';
import 'package:bir_pos/services/payment_method_service.dart';
import 'package:bir_pos/services/print_service.dart';
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
    'vat_adjust_sales': 0.0,
    'zero_rated_sales': 0.0,
    'transaction_discounts': {},
    'gov_discount_details': {},
  };

  String invoiceId = "";
  bool isDigitalPayment = false;
  bool isFirstPrint = true;

  late Future<List<Product>> _productsFuture;
  late Future<List<Package>> _packagesFuture;
  late Future<User> _userFuture;
  late Future<List<Discount>> _discountsFuture;
  late Future<List<PaymentMethod>> _transactionMethodsFuture;
  late Future<List<dynamic>> _cartItemsFuture;

  void initState() {
    super.initState();
    _userFuture = AuthService.getUser(context);
    _productsFuture = ProductService.getProducts();
    _packagesFuture = PackageService.getPackages();
    _discountsFuture = DiscountService.getDiscounts();
    _transactionMethodsFuture = PaymentMethodService.getMethods();
    _cartItemsFuture = CartService.getCartItems(transactionData);
  }

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
        'vat_adjust_sales': 0.0,
        'zero_rated_sales': 0.0,
        'transaction_discounts': {},
        'gov_discount_details': {},
      };
    });
  }

  void setInvoice(id) {
    invoiceId = id.toString();
  }

  void addItem(itemData) {
    setState(() {
      bool canAdd = true;

      if (!transactionData['items'].isEmpty) {
        for (var item in transactionData['items']) {
          if (item['data']['id'] != itemData['data']['id']) {
            continue;
          }
          print('Product same id');
          if (itemData['data']['item_discounts'] != null &&
              item['data']['item_discounts'] != null) {
            print('Product Has Discount');
            if (itemData['data']['item_discounts']['id'] !=
                item['data']['item_discounts']['id']) {
              continue;
            }
          }
          print('Product Discount Checked');

          item['quantity'] += 1;
          canAdd = false;
          break;
        }
      }

      if (canAdd) {
        transactionData['items'].add(itemData);
      }

      calculateValues();
    });
  }

  void removeItem(index) {
    print(transactionData);
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

  void setTransactionFee(transactionFee) {
    transactionData['transaction_fee'] = transactionFee;
    calculateValues();
  }

  void setTransactionMethod(transactionMethod) {
    transactionData['transaction_method'] = transactionMethod.id;
    transactionData['transaction_is_digital'] = transactionMethod.isDigital;
    calculateValues();
    print(transactionData);
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

        if (data['data'].containsKey('product_id')) {
          Map<String, dynamic> discountedItem = {
            'data': {
              'id': data['data']['id'],
              'product_id': data['data']['product_id'],
              'name': data['data']['name'],
              'price': data['data']['price'],
              'image_url': data['data']['image_url'],
              'discount_value': item['discount_value'],
              'total_value': item['total_value'],
              'item_discounts': {
                'id': item['discount_id'],
                'value': item['discount_value'],
                'is_percentage': item['discount_is_percentage'],
              },
            },
            'quantity': item['quantity'],
          };
          addItem(discountedItem);
        } else {
          Map<String, dynamic> discountedItem = {
            'data': {
              'id': data['data']['id'],
              'package_id': data['data']['package_id'],
              'name': data['data']['name'],
              'price': data['data']['price'],
              'image_url': data['data']['image_url'],
              'discount_value': item['discount_value'],
              'total_value': item['total_value'],
              'item_discounts': {
                'id': item['discount_id'],
                'value': item['discount_value'],
                'is_percentage': item['discount_is_percentage'],
              },
            },
            'quantity': item['quantity'],
          };

          addItem(discountedItem);
        }

        initialItem['quantity'] -= item['quantity'];
        // print(initialItem['quantity']);
        if (initialItem['quantity'] < 1) {
          removeItem(item['index']);
        }
      }
      calculateValues();
    });
  }

  void addToTransactionDiscounts(transactionDiscount) {
    transactionData['transaction_discounts'] = {
      'id': transactionDiscount['discount_id'],
      'value': transactionDiscount['discount_value'],
      'is_percentage': transactionDiscount['discount_is_percentage'],
    };
    calculateValues();
    print(transactionData);
  }

  void addGovDiscountDetails(govDiscountDetails) {
    String error;
    setState(() {
      for (var discount in govDiscountDetails.keys) {
        (!transactionData['gov_discount_details'].containsKey(discount))
            ? transactionData['gov_discount_details'] = {
              discount: govDiscountDetails[discount],
            }
            : error = 'Discount info is already set';
      }
    });
    // print('Gov discount details: ${transactionData['gov_discount_details']}');
    // print((error != null) ? error : 'Discount info added successfully');
  }

  void calculateValues() {
    setState(() {
      transactionData = TransactionService.processCalculations(transactionData);
    });
    print(transactionData);
  }

  void processTransactions() {
    calculateValues();
    // print('Processing transactions...');
    // print('Transaction Data: $transactionData');
    final formattedData = TransactionService.formatTransactionData(
      transactionData,
    );
    TransactionService.saveTransactionData(
      formattedData,
    ).then((id) => setInvoice(id));
  }

  void printReceipt() {
    final printerService = PrinterService();
    final user = AuthService.getUser(context);

    final items =
        transactionData['items']
            .map(
              (data) => {
                'name': data['data']['name'],
                'quantity': data['quantity'],
                'price': data['data']['price'],
              },
            )
            .toList();

    final accountingData = {
      'transaction_method': transactionData['transaction_method'].toString(),
      'transaction_fee': transactionData['transaction_fee'].toString(),
      'cash_tendered': transactionData['cash_tendered'].toString(),
      'total_sales': transactionData['total_sales'].toString(),
      'change': transactionData['change'].toString(),
      'gross_sales': transactionData['gross_sales'].toString(),
      'vatable_sales': transactionData['vatable_sales'].toString(),
      'vat': transactionData['vat'].toString(),
      'vat_exempt_sales': transactionData['vat_exempt_sales'].toString(),
      'vat_adjust_sales': transactionData['vat_adjust_sales'].toString(),
      'zero_rated_sales': transactionData['zero_rated_sales'].toString(),
    };

    user.then((data) {
      final userData = {
        'id': data.id.toString(),
        'name': data.name,
        'email': data.email.toString(),
      };

      printerService.printReceipt(
        storeName: 'Thermozone Philippines Corp.',
        storeAddress: '2280 Marconi St., Brgy. San Isidro, Makati City',
        storePhone: 'TIN: 223 661 818 0000',
        userData: userData,
        invoiceId: invoiceId,
        accountingData: accountingData,
        items: items,
        dateTime: DateTime.now().toIso8601String().toString(),
      );
    });
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
                      future: _userFuture,
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
                      future: _packagesFuture,
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
                      future: _productsFuture,
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
                      futureCartItems: _cartItemsFuture,
                      increaseQuantity: increaseQuantity,
                      decreaseQuantity: decreaseQuantity,
                      addGovDiscountDetails: addGovDiscountDetails,
                      addItemDiscount: addItemDiscount,
                      removeItem: removeItem,
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
                      futureTransactionMethods: _transactionMethodsFuture,
                      futureDiscounts: _discountsFuture,
                      addGovDiscountDetails: addGovDiscountDetails,
                      addToTransactionsDiscount: addToTransactionDiscounts,
                      setTransactionMethod: setTransactionMethod,
                      setCashTendered: setCashTendered,
                      setTransactionFee: setCashTendered,
                      processTransactions: processTransactions,
                      resetTransactionData: resetTransactionData,
                      toggleIsFirstPrint: toggleIsFirstPrint,
                      printReceipt: printReceipt,
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
