import 'dart:convert';

import 'package:bir_pos/models/void_transaction.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VoidTransactionForm extends StatefulWidget {
  const VoidTransactionForm({super.key});

  @override
  State<VoidTransactionForm> createState() => _VoidTransactionFormState();
}

class _VoidTransactionFormState extends State<VoidTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _transactionIdController =
      TextEditingController();

  bool _isLoading = false;
  String? _feedback;

  Future<void> _voidTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _feedback = null;
    });

    final id = _transactionIdController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
    final String apiUri = dotenv.env['POS_API_URL'] ?? "";
    final url = Uri.parse('$apiUri/api/v1/void/$id');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Pos-Secret-key': apiSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // ✅ Parse JSON into your model
        final transaction = VoidTransactionResponse.fromJson(data);

        setState(() {
          _feedback = '✅ ${transaction.message}';
        });

        print("Transaction No: ${transaction.transactionDetails.siNo}");
        print("Processed by: ${transaction.transactionDetails.processedBy}");
        print("Items: ${transaction.items.map((e) => e.name).toList()}");
        print(
          "Discounted: ${transaction.discountedItems.map((e) => e.name).toList()}",
        );
      } else {
        setState(() => _feedback = '⚠️ Failed: ${response.body}');
      }

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _feedback = null);
        }
      });
    } catch (e) {
      setState(() => _feedback = '❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _feedback = null;
    });

    final id = _transactionIdController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final String apiSecret = dotenv.env['POS_API_SECRET'] ?? "";
    final String apiUri = dotenv.env['POS_API_URL'] ?? "";
    final url = Uri.parse('$apiUri/api/v1/restore/$id');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Pos-Secret-key': apiSecret,
        },
      );

      if (response.statusCode == 200) {
        setState(() => _feedback = '✅ Transaction restored successfully!');
      } else {
        setState(() => _feedback = '⚠️ Failed: ${response.body}');
      }
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _feedback = null);
        }
      });
    } catch (e) {
      setState(() => _feedback = '❌ Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Material(
          borderRadius: BorderRadius.circular(12),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Void a Transaction',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _transactionIdController,
                    decoration: const InputDecoration(
                      labelText: 'Transaction Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.confirmation_number),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Enter a transaction number'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _voidTransaction,
                        icon:
                            _isLoading
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.cancel),
                        label: Text(
                          _isLoading ? 'Voiding...' : 'Void Transaction',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 15,
                          ),
                          textStyle: const TextStyle(fontSize: 15),
                          backgroundColor: Colors.brown[500],
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _restoreTransaction,
                        icon:
                            _isLoading
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.check_circle),
                        label: Text(
                          _isLoading ? 'Restoring...' : 'Restore Transaction',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 15,
                          ),
                          textStyle: const TextStyle(fontSize: 15),
                          backgroundColor: Colors.brown[500],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (_feedback != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _feedback!,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            _feedback!.startsWith('✅')
                                ? Colors.green
                                : _feedback!.startsWith('⚠️')
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
