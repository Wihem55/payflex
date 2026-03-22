// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:payflexx/Controllers/providers/fullorder_provider.dart';
import 'invoicePage.dart';
import 'orders_widget.dart';

class OrdersPage extends StatefulWidget {
  final String routename = '/orders'; // Route name for navigation

  const OrdersPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final OrderProvider _orderProvider =
      OrderProvider(); // Order provider instance

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vos commandes'), // App bar title
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _orderProvider.fetchOrders(), // Fetch orders from the provider
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Show loading indicator while fetching data
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    'Error: ${snapshot.error}')); // Show error message if there's an error
          } else {
            final List<Map<String, dynamic>> orders =
                snapshot.data ?? []; // Fetch orders data
            return ListView.builder(
              itemCount: orders.length, // Number of orders
              itemBuilder: (context, index) {
                final orderData =
                    orders[index]; // Order data for the current index
                return OrderWidget(
                  orderData: orderData, // Pass order data to OrderWidget
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InvoicePage(
                            orderData:
                                orderData), // Navigate to InvoicePage with order data
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
