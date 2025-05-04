import 'package:bir_pos/models/user.dart';
import 'package:bir_pos/services/auth_service.dart';
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

  void addItem(itemData) {
    bool canAdd = true;

    if (!transactionData['items'].isEmpty) {
      for (var item in transactionData['items']) {
        if (item['data']['id'] == itemData['data']['id']) {
          item['quantity'] += 1;
          canAdd = false;
          break;
        }
      }
    }

    if (canAdd) {
      transactionData['items'].add(itemData);
    }
  }

  void removeItem(itemData) {
    transactionData['items'].removeWhere(
      (item) => item['data']['id'] == itemData['data']['id'],
    );
  }

  void increaseQuantity(itemData) {
    for (var item in transactionData['items']) {
      if (item['data']['id'] == itemData['data']['id']) {
        item['quantity'] += 1;
        break;
      }
    }
  }

  void decreaseQuantity(itemData) {
    for (var item in transactionData['items']) {
      if (item['data']['id'] == itemData['data']['id']) {
        if (item['quantity'] > 1) {
          item['quantity'] -= 1;
        } else {
          removeItem(itemData);
        }
        break;
      }
    }
  }

  void setCashTendered(cashTendered) {
    transactionData['cash_tendered'] = cashTendered;
  }

  void setTransactionMethod(transactionMethod) {
    transactionData['transaction_method'] = transactionMethod;
  }

  void setTransactionFee(transactionFee) {
    transactionData['transaction_fee'] = transactionFee;
  }

  void addToTransactionDiscounts(transactionDiscount) {
    transactionData['transaction_discounts'].add(transactionDiscount);
  }

  void addGovDiscountDetails(govDiscountDetails) {
    transactionData['gov_discount_details'].add(govDiscountDetails);
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

                    // Packages Label
                    SectionHeader(title: 'Packages'),

                    // Horizontal GridView for Packages
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 0, 20),
                      height: 330,
                      child: FutureBuilder<List<Package>>(
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
                            return const Center(
                              child: Text('No packages found'),
                            );
                          }
                          final packages = snapshot.data!;

                          return GridView.builder(
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

                              // Package Card
                              return PackageCard(
                                package: package,
                                onPressed: addItem,
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // Products Label
                    SectionHeader(title: 'Products'),

                    // GridView for Products
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 0, 20),
                      child: FutureBuilder<List<Product>>(
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
                            return const Center(
                              child: Text('No products found'),
                            );
                          }

                          final products = snapshot.data!;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  crossAxisCount, // Make sure this is defined above
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];

                              // Product Card
                              return ProductCard(
                                product: product,
                                onPressed: addItem,
                              );
                            },
                          );
                        },
                      ),
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
                    ),
                  ),

                  // Total Cost Container
                  Expanded(flex: 1, child: TotalCost(totalCost: 1000.00)),

                  // Payment Methods, Discounts, and Actions Container
                  Expanded(
                    flex: 3,
                    child: TransactionActions(
                      setTransactionMethod: setTransactionMethod,
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
