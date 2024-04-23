import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_mobile_apps/components/cardWithList.dart';
import 'package:my_mobile_apps/service/api.dart';
import 'package:http/http.dart' as http;
import 'package:my_mobile_apps/service/auth/authService.dart';
import '../auth/login_screen.dart';
import 'dart:convert';

// Your DeliveryOrderScreen widget
class DeliveryOrderScreen extends StatefulWidget {
  const DeliveryOrderScreen({Key? key}) : super(key: key);

  @override
  _DeliveryOrderScreenState createState() => _DeliveryOrderScreenState();
}

class _DeliveryOrderScreenState extends State<DeliveryOrderScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> items = [];
  Future<void> _fetchData() async {
    try {
      // Fetch API endpoint for login
      final url = Uri.parse("$myUrl/api/delivery_order_by_status/wait");
      final myToken = await AuthService.getToken();

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $myToken'
        },
      );
      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData != null && responseData['data'] != null) {
          final List<dynamic> dataList = responseData['data'];
          items.clear();
          dataList.forEach((item) {
            final id = item['id'] ?? '';
            final itemName = item['item'] ?? '';
            final itemQty = item['qty'] ?? 0;
            final itemUm = item['um'] ?? '';
            final itemShipmentPrice = item['price'] ?? '';
            final itemCourier = item['courier'] ?? '';
            final itemShipTo = item['ship_to'] ?? '';

            items.add({
              'id': id,
              'item': itemName,
              'qty': itemQty,
              'um': itemUm,
              'price': itemShipmentPrice,
              'courier': itemCourier,
              'ship_to': itemShipTo,
            });
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed...'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    init();
  }

  void init() {
    // Initialization tasks go here
    Future.delayed(const Duration(seconds: 3), () {});
  }

  void _logout() async {
    await AuthService.deleteToken();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("Delivery Order"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout();
              print("pressed");
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : !_isLoading && items.length == 0
                        ? const Center(
                            child: Text("Data Kosong"),
                          )
                        : CardWithListAndText(items: items),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
