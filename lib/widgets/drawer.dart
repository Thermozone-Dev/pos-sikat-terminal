import 'package:bir_pos/services/shift_service.dart';
import 'package:bir_pos/services/summary_print_service.dart';
import 'package:bir_pos/services/x_print_service.dart';
import 'package:bir_pos/services/z_print_service.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  // String endingBalance = "0.0";

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.brown[500]),
            child: Center(child: Image.asset('assets/img/banner-dark.png')),
          ),
          ListTile(
            leading: const Icon(Icons.print, color: Colors.black),
            title: const Text(
              'Summary Report',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () async {
              final printerService = SummaryPrintService();
              await printerService.printReceipt();
              Navigator.pop(context);
            },
          ),

          ListTile(
            leading: const Icon(Icons.print, color: Colors.black),
            title: const Text(
              'X-Reading',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () async {
              final printerService = XReadingPrintService();
              await printerService.printReceipt();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.print, color: Colors.black),
            title: const Text(
              'Z-Reading',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () async {
              final printerService = ZReadingPrintService();
              await printerService.printReceipt();
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text(
              'End Shift',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            leading: Icon(
              Icons.logout,
            ), // You can change the icon to match your use case
            onTap: () {
              String endingBalance = "0.0";
              endShift(endingBalance);
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.black),
            title: const Text(
              'Sign Out',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              String endingBalance = "0.0";
              AuthService.signOut(context);
              endShift(endingBalance);
            },
          ),
        ],
      ),
    );
  }
}
