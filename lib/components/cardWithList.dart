import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_mobile_apps/screens/delivery_order/delivery_order_screen.dart';
import 'package:my_mobile_apps/service/api.dart';
import 'package:my_mobile_apps/service/auth/authService.dart';

class CardWithListAndText extends StatefulWidget {
  final List<Map<String, dynamic>> items;

  CardWithListAndText({Key? key, required this.items}) : super(key: key);

  @override
  State<CardWithListAndText> createState() => _CardWithListAndTextState();
}

class _CardWithListAndTextState extends State<CardWithListAndText> {
  bool _isLoading = false;
  _showModal(context, val) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String userInput = '';

        return AlertDialog(
          title: const Center(
            child: Text(
              'Approval',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 26,
                color: Colors.black,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              height: 300,
              child: Column(
                children: [
                  SizedBox(
                    child: Column(
                      children: [
                        Text(
                          '${val['item']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 23,
                            color: Colors.black,
                          ),
                        ),
                        Text('Qty: ${val['qty']} ${val['um']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 16,
                              color: Colors.black,
                            )),
                        Text('Ship To: ${val['ship_to']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 16,
                              color: Colors.black,
                            )),
                        Text('Price: ${val['price']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 16,
                              color: Colors.black,
                            )),
                        Text('Courier: ${val['courier']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 16,
                              color: Colors.black,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    onChanged: (value) {
                      userInput = value; // Update user input as it changes
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter your text here',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (userInput != "") {
                  final data = {
                    "id": val['id'],
                    "reason_approval": userInput.toString(),
                    "status": "revise",
                  };
                  _sendApproval(data);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter your reason...'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Reject'),
            ),
            TextButton(
              onPressed: () {
                if (userInput != "") {
                  final data = {
                    "id": val['id'],
                    "reason_approval": userInput.toString(),
                    "status": "revise",
                  };
                  _sendApproval(data);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter your reason...'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Revise'),
            ),
            TextButton(
              onPressed: () {
                final data = {
                  "id": val['id'],
                  "reason_approval": "No Reason",
                  "status": "approve",
                };
                _sendApproval(data);

                Navigator.of(context).pop();
              },
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );
  }

  _sendApproval(data) async {
    print(jsonEncode({
      'reasonApproval': data,
    }));
    if (data != "") {
      setState(() {
        _isLoading = false;
      });

      try {
        // Fetch API endpoint for login
        final url = Uri.parse("$myUrl/api/approval");
        final myToken = await AuthService.getToken();

        final response = await http.post(
          url,
          body: jsonEncode(data),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $myToken'
          },
        );
        setState(() {
          _isLoading = false;
        });
        print(response.body);
        // return;
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Update Success!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const DeliveryOrderScreen()),
          );
        } else {
          // Error handling for failed login
          // Show snackbar or dialog with error message
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
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widget.items.map((item) {
              print(item);
              return GestureDetector(
                onTap: () => _showModal(context, item),
                child: Card(
                  child: ListTile(
                    title: Text(
                      item['item'].toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Color.fromARGB(255, 100, 96, 96),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Qty: ${item['qty'].toString()} ${item['um'].toString()}'),
                        Text('to: ${item['ship_to'].toString()}'),
                      ],
                    ),
                    trailing: Column(
                      children: [
                        Text('Price Shipment: RP${item['price'].toString()}'),
                        Text('with ${item['courier'].toString()}')
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
