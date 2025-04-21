import 'package:bir_pos/models/discount.dart';
import 'package:flutter/material.dart';
import 'print_service.dart';
import 'models/product.dart';
import 'models/package.dart';
import 'package:bir_pos/services/auth_service.dart';
import 'package:bir_pos/services/package_service.dart';
import 'package:bir_pos/services/product_service.dart';
import 'package:bir_pos/services/discount_service.dart';
import 'package:bir_pos/widgets/section_header.dart';
import 'package:bir_pos/widgets/package_card.dart';
import 'package:bir_pos/widgets/product_card.dart';

class Terminal extends StatefulWidget {
  const Terminal({Key? key, required this.token}) : super(key: key);
  final String token;

  @override
  State<Terminal> createState() => _TerminalState();
}

class _TerminalState extends State<Terminal> {
  int quantity = 0;

  void increaseQuantity() {
    setState(() {
      quantity = quantity + 1;
    });
  }

  void decreaseQuantity() {
    setState(() {
      quantity = quantity - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // Determine the number of columns based on the screen size
    int crossAxisCount;
    if (screenWidth < 640) {
      crossAxisCount = 1;
    } else if (screenWidth < 768) {
      crossAxisCount = 2;
    } else if (screenWidth < 1024) {
      crossAxisCount = 3;
    } else if (screenWidth < 1280) {
      crossAxisCount = 4;
    } else if (screenWidth < 1368) {
      crossAxisCount = 5;
    } else {
      crossAxisCount = 6;
    }

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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.brown[500]),
              child: Center(
                child: Image(image: AssetImage('assets/img/banner-dark.png')),
              ),
            ),
            ListTile(
              leading: Icon(Icons.print, color: Colors.black),
              title: const Text(
                'X-Reading',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                print('X - Reading Print');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.print, color: Colors.black),
              title: const Text(
                'Z-Reading',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                print('Z - Reading Print');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.black),
              title: const Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                AuthService.signOut(context);
              },
            ),
          ],
        ),
      ),
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
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.fromLTRB(20, 20, 0, 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi Angelo Marquez',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Ready to start receiving orders?',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
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
                                onPressed: () {
                                  print("Product pressed: ${package.name}");
                                },
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
                                onPressed: () {
                                  print("Product pressed: ${product.name}");
                                },
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
                  Expanded(
                    flex: 6,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(30),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 5,
                              children: [
                                Icon(Icons.shopping_bag),
                                Text(
                                  'ITEMS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),

                            Text(
                              '04/08/2025 5:16 PM',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),

                            // Spacing & Border
                            SizedBox(height: 20),
                            Container(color: Colors.grey[300], height: 2),
                            SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.asset(
                                          'assets/img/DM1.jpg',
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            'DM1',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            '₱150',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0D7C66),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove_circle),
                                        onPressed: decreaseQuantity,
                                      ),
                                      Text(
                                        '$quantity',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add_circle),
                                        onPressed: increaseQuantity,
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.discount),
                                        onPressed: () {
                                          print("Assign Product Discount");
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL :',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '₱ 0',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: Colors.brown[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
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
                                Tab(text: 'Payment Method'),
                                Tab(text: 'Discounts'),
                                Tab(text: 'Actions'),
                              ],
                            ),

                            // Tab content
                            Expanded(
                              child: TabBarView(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: AspectRatio(
                                            aspectRatio:
                                                1, // Ensure square aspect ratio (width == height)
                                            child: ElevatedButton(
                                              onPressed: () {
                                                print('Payment Method: Cash');
                                              },
                                              style: ElevatedButton.styleFrom(
                                                iconColor: Colors.white,
                                                backgroundColor:
                                                    Colors.brown[500],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12,
                                                      ), // Rounded corners
                                                ),
                                                padding:
                                                    EdgeInsets
                                                        .zero, // No padding to keep it square
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.money),
                                                  Text(
                                                    'Cash',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ), // Space between buttons
                                        Expanded(
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                print(
                                                  'Payment Method: Debit Card',
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                iconColor: Colors.black,
                                                backgroundColor:
                                                    Colors.grey[300],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding: EdgeInsets.zero,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.credit_card),
                                                  Text(
                                                    'Debit',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                print(
                                                  'Payment Method: Credit Card',
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.amber,
                                                iconColor: Colors.black,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding: EdgeInsets.zero,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.credit_card),
                                                  Text(
                                                    'Credit',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                print('Payment Method: GCash');
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.blue[900],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding: EdgeInsets.zero,
                                              ),
                                              child: Text(
                                                'GCash',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: AspectRatio(
                                            aspectRatio: 1,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                print('Payment Method: Maya');
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding: EdgeInsets.zero,
                                              ),
                                              child: Text(
                                                'Maya',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.green[300],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                      ],
                                    ),
                                  ),

                                  // Second tab: Still showing discounts text
                                  Container(
                                    margin: const EdgeInsets.fromLTRB(
                                      10,
                                      10,
                                      10,
                                      10,
                                    ),
                                    height:
                                        120, // Optional: Controls vertical size of horizontal GridView
                                    child: FutureBuilder<List<Discount>>(
                                      future: DiscountService.getDiscounts(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        } else if (snapshot.hasError) {
                                          return Center(
                                            child: Text(
                                              'Error: ${snapshot.error}',
                                            ),
                                          );
                                        } else if (!snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return const Center(
                                            child: Text('No discounts found'),
                                          );
                                        }

                                        final discounts = snapshot.data!;

                                        return GridView.builder(
                                          scrollDirection: Axis.horizontal,
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
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
                                                  print(
                                                    'Discount: ${discount.name}',
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.grey[300],
                                                  iconColor: Colors.black,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '${discount.name}',
                                                      style: const TextStyle(
                                                        fontSize: 9,
                                                        color: Colors.black,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),

                                  ElevatedButton(
                                    onPressed: () async {
                                      final printerService = PrinterService();

                                      // Sample receipt data
                                      final items = [
                                        {
                                          'name': 'Apple',
                                          'quantity': '2',
                                          'price': '\$1.00',
                                        },
                                        {
                                          'name': 'Banana',
                                          'quantity': '5',
                                          'price': '\$2.50',
                                        },
                                      ];

                                      await printerService.printReceipt(
                                        storeName:
                                            'Thermozone Philippines Corp.',
                                        storeAddress:
                                            '2280 Marconi St., Brgy. San Isidro, Makati City',
                                        storePhone: 'TIN: 223 661 818 0000',
                                        items: items,
                                        total: 3.50,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[400],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Text(
                                      'Test Print',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),

                                  SizedBox(width: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
