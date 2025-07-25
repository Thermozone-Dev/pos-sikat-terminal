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
import 'package:bir_pos/widgets/total_change.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:bir_pos/services/shift_service.dart';
import 'package:intl/intl.dart';

class Terminal extends StatefulWidget {
  final String? token;

  const Terminal({Key? key, required this.token}) : super(key: key);

  @override
  _TerminalState createState() => _TerminalState();
}

class _TerminalState extends State<Terminal> {
  bool isInitialized = false;
  bool isLoading = false;
  bool shiftActive = false;

  String openingBalance = "0.0";
  String? error;

  Future<void> showOpeningBalanceModal(
    BuildContext context,
    Future<void> Function(String) onSubmit,
  ) async {
    final TextEditingController controller = TextEditingController();
    String userInput = '';

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Enter Opening Balance'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(hintText: 'e.g., 100.00'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  userInput = controller.text;
                  Navigator.pop(context);
                },
                child: Text('Submit'),
              ),
            ],
          ),
    );

    if (userInput.isNotEmpty) {
      await onSubmit(userInput); // This calls initializePage(userInput)
    }
  }

  Future<void> initializePage(String openingBalance) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final result = await initializeShift(openingBalance);

    setState(() {
      isLoading = false;
      if (result.success) {
        isInitialized = true;
      } else {
        error = result.error;
      }
    });
  }

  Future<void> checkShift() async {
    final valid = await isTodayShiftValid();
    setState(() {
      showContinueShiftButton = valid;
    });
  }

  Map<String, dynamic> transactionData = {
    'items': [],
    'transaction_method': null,
    'transaction_is_digital': false,
    'transaction_fee': 0.0,
    'cash_tendered': 0.0,
    'total_sales': 0.0,
    'change': 0.0,
    'gross_sales': 0.0,
    'vatable_sales': 0.0,
    'vat': 0.0,
    'vat_exempt_sales': 0.0,
    'vat_deduction': 0.0,
    'vat_adjustment': 0.0,
    'zero_rated_sales': 0.0,
    'transaction_discounts': {},
    'gov_discount_details': {},
    'discount_value': 0.0,
  };

  String transactionMethodName = "";
  String invoiceId = "";
  bool isDigitalPayment = false;
  bool isFirstPrint = true;
  bool itemsHasDiscount = false;
  bool transactionHasDiscount = false;
  bool showContinueShiftButton = false;

  late Future<List<Product>> _productsFuture;
  late Future<List<Package>> _packagesFuture;
  late Future<User> _userFuture;
  late Future<List<Discount>> _discountsFuture;
  late Future<List<PaymentMethod>> _transactionMethodsFuture;
  late Future<List<dynamic>> _cartItemsFuture;

  void initState() {
    super.initState();
    checkShift();
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
        'transaction_fee': 0.0,
        'cash_tendered': 0.0,
        'total_sales': 0.0,
        'change': 0.0,
        'gross_sales': 0.0,
        'vatable_sales': 0.0,
        'vat': 0.0,
        'vat_exempt_sales': 0.0,
        'vat_adjustment': 0.0,
        'vat_deduction': 0.0,
        'zero_rated_sales': 0.0,
        'gov_discount_details': {},
        'discount_value': 0.0,
      };
      isFirstPrint = true;
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
          if (itemData['data']['item_discounts'] != null) {
            if (item['data']['item_discounts'] != null) {
              if (itemData['data']['item_discounts']['id'] !=
                  item['data']['item_discounts']['id']) {
                continue;
              }
            } else {
              continue;
            }
          }
          item['quantity'] += 1;
          canAdd = false;
          break;
        }
      }

      if (canAdd) {
        transactionData['items'].add(itemData);
      }

      calculateValues();
      checkDiscount();
    });
  }

  void removeItem(index) {
    setState(() {
      transactionData['items'].removeAt(index);
      calculateValues();
      checkDiscount();
    });
  }

  void increaseQuantity(index) {
    final item = transactionData['items'][index];
    setState(() {
      item['quantity'] += 1;
      calculateValues();
      checkDiscount();
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
      checkDiscount();
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
    transactionMethodName = transactionMethod.name;
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

        if (data['data'].containsKey('product_id')) {
          Map<String, dynamic> discountedItem = {
            'data': {
              'id': data['data']['id'],
              'product_id': data['data']['product_id'],
              'name': data['data']['name'],
              'price': data['data']['price'],
              'pax': data['data']['pax'],
              'product_tax_category': data['data']['product_tax_category'],
              'vat_exempt': data['data']['vat_exempt'],
              'image_url': data['data']['image_url'],
              'discount_value': item['discount_value'],
              'total_value': item['total_value'],
              'item_discounts': {
                'id': item['discount_id'],
                'value': item['discount_value'],
                'is_government_discount': item['discount_is_gov'],
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
              'pax': data['data']['pax'],
              'product_tax_category': data['data']['product_tax_category'],
              'vat_exempt': data['data']['vat_exempt'],
              'image_url': data['data']['image_url'],
              'discount_value': item['discount_value'],
              'total_value': item['total_value'],
              'item_discounts': {
                'id': item['discount_id'],
                'value': item['discount_value'],
                'is_government_discount': item['discount_is_gov'],
                'is_percentage': item['discount_is_percentage'],
              },
            },
            'quantity': item['quantity'],
          };

          addItem(discountedItem);
        }

        initialItem['quantity'] -= item['quantity'];
        if (initialItem['quantity'] < 1) {
          removeItem(item['index']);
        }
      }
      calculateValues();
    });
  }

  void addToTransactionDiscounts(transactionDiscount) {
    setState(() {
      transactionData['transaction_discounts'] = {
        'id': transactionDiscount['discount_id'],
        'value': transactionDiscount['discount_value'],
        'is_percentage': transactionDiscount['discount_is_percentage'],
      };
      calculateValues();
      checkDiscount();
    });
  }

  void addGovDiscountDetails(govDiscountDetails) {
    String? error;
    setState(() {
      for (var discount in govDiscountDetails.keys) {
        if (transactionData['gov_discount_details'].containsKey(discount)) {
          error = 'Discount info is already set';
        } else {
          transactionData['gov_discount_details'][discount] =
              govDiscountDetails[discount];
        }
      }
    });
    // print('Gov discount details: ${transactionData['gov_discount_details']}');
    // print((error != null) ? error : 'Discount info added successfully');
    // print('Transaction Data: ${transactionData}');
  }

  void calculateValues() {
    setState(() {
      transactionData = TransactionService.processCalculations(transactionData);
    });
  }

  void processTransactions() {
    calculateValues();
    // print('Processing transactions...');
    // print('Transaction Data: $transactionData');
    final formattedData = TransactionService.formatTransactionData(
      transactionData,
    );
    // print('Formatting transactions...');
    // print('Formatted Transaction Data: $formattedData');
    TransactionService.saveTransactionData(formattedData).then((id) {
      setInvoice(id);
      printReceipt();
    });
  }

  void checkDiscount() {
    itemsHasDiscount = false;
    transactionHasDiscount = false;

    if (transactionData['transaction_discounts'] != null &&
        !transactionData['transaction_discounts'].isEmpty) {
      transactionHasDiscount = true;
    }

    for (var item in transactionData['items']) {
      if (item['item_discounts'] == null || item['item_discounts'].isEmpty) {
        continue;
      }
      itemsHasDiscount = true;
    }
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
                'price': data['data']['price'].roundToDouble(),
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
      'vat_deduction': transactionData['vat_deduction'].toString(),
      'vat_adjustment': transactionData['vat_adjustment'].toString(),
      'zero_rated_sales': transactionData['zero_rated_sales'].toString(),
      'discount_value': transactionData['discount_value'].toString(),
    };

    user.then((data) {
      final userData = {
        'id': data.id.toString(),
        'name': data.name,
        'email': data.email.toString(),
      };

      String formattedDate = DateFormat('MMMM d, y').format(DateTime.now());

      printerService.printReceipt(
        storeName: 'Thermozone Philippines Corp.',
        storeAddress: '2280 Marconi St., Brgy. San Isidro, Makati City',
        storePhone: 'TIN: 223 661 818 0000',
        userData: userData,
        invoiceId: invoiceId,
        accountingData: accountingData,
        methodName: transactionMethodName,
        items: items,
        dateTime: formattedDate,
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
            Image.asset('assets/img/dino-logo.png', height: 40),
            const SizedBox(width: 10),
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
          builder:
              (context) => IconButton(
                color: Colors.white,
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      drawer: const MainDrawer(),
      backgroundColor: Colors.grey[300],
      body:
          isInitialized
              ? Center(
                child: Row(
                  children: [
                    // Left Panel
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                  return const Center(
                                    child: Text('No user found'),
                                  );
                                }
                                return Greeter(user: snapshot.data!);
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
                                  return const SizedBox.shrink();
                                }
                                final packages = snapshot.data!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SectionHeader(title: 'Packages'),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                        20,
                                        0,
                                        0,
                                        20,
                                      ),
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
                                        itemBuilder:
                                            (context, index) => PackageCard(
                                              package: packages[index],
                                              onPressed: addItem,
                                            ),
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
                                  return const SizedBox.shrink();
                                }
                                final products = snapshot.data!;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SectionHeader(title: 'Products'),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                        20,
                                        0,
                                        0,
                                        20,
                                      ),
                                      child: GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: crossAxisCount,
                                              crossAxisSpacing: 10,
                                              mainAxisSpacing: 10,
                                              childAspectRatio: 0.75,
                                            ),
                                        itemCount: products.length,
                                        itemBuilder:
                                            (context, index) => ProductCard(
                                              product: products[index],
                                              onPressed: addItem,
                                            ),
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.55,
                            child: ShoppingCart(
                              transactionData: transactionData,
                              increaseQuantity: increaseQuantity,
                              decreaseQuantity: decreaseQuantity,
                              addGovDiscountDetails: addGovDiscountDetails,
                              addItemDiscount: addItemDiscount,
                              removeItem: removeItem,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                            child: TotalSummary(
                              totalCost: transactionData['total_sales'],
                              totalChange:
                                  transactionData['change'] < 0
                                      ? 0.00
                                      : transactionData['change'],
                            ),
                          ),
                          Flexible(
                            child: TransactionActions(
                              futureDiscounts: _discountsFuture,
                              transactionDiscountData:
                                  transactionData['transaction_discounts'] ??
                                  {},
                              addGovDiscountDetails: addGovDiscountDetails,
                              addToTransactionsDiscount:
                                  addToTransactionDiscounts,
                              setTransactionMethod: setTransactionMethod,
                              setCashTendered: setCashTendered,
                              setTransactionFee: setTransactionFee,
                              processTransactions: processTransactions,
                              resetTransactionData: resetTransactionData,
                              toggleIsFirstPrint: toggleIsFirstPrint,
                              printReceipt: printReceipt,
                              isFirstPrint: isFirstPrint,
                              itemsHasDiscount: itemsHasDiscount,
                              total: transactionData['total_sales'],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              : Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!showContinueShiftButton)
                      ElevatedButton(
                        onPressed:
                            () => showOpeningBalanceModal(
                              context,
                              initializePage,
                            ),
                        child: const Text('Start Shift'),
                      ),
                    const SizedBox(width: 10),
                    if (showContinueShiftButton)
                      ElevatedButton(
                        onPressed: () async {
                          final result = await continueShift();
                          if (result.success) {
                            setState(() => isInitialized = true);
                          } else {
                            setState(() => error = result.error);
                          }
                        },
                        child: const Text('Continue Shift'),
                      ),
                  ],
                ),
              ),
    );
  }
}
