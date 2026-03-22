import 'package:flutter/material.dart';

class OrderWidget extends StatelessWidget {
  final Map<String, dynamic> orderData; // Data for the order
  final VoidCallback onTap; // Callback function for when the widget is tapped

  const OrderWidget({
    required this.orderData,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Handle tap on the widget
      child: Card(
        elevation: 5, // Shadow depth for the card
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Card margin
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners for the card
        ),
        child: Padding(
          padding: const EdgeInsets.all(16), // Padding inside the card
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start of the column
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space out the children evenly
                children: [
                  Expanded(
                    child: Text(
                      'Order ID: ${orderData['orderID']}', // Display order ID
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis, // Handle overflow text
                    ),
                  ),
                  const Icon(Icons.arrow_forward), // Arrow icon
                ],
              ),
              const SizedBox(height: 8), // Space between rows
              Text(
                'Nom Du Produit: ${orderData['productName']}', // Display product name
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                overflow: TextOverflow.ellipsis, // Handle overflow text
              ),
              const SizedBox(height: 4), // Space between rows
              Text(
                'Prix: ${orderData['price']}', // Display price
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                overflow: TextOverflow.ellipsis, // Handle overflow text
              ),
              const SizedBox(height: 4), // Space between rows
              Text(
                'Quantit\u00E9: ${orderData['quantity']}', // Display quantity
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                overflow: TextOverflow.ellipsis, // Handle overflow text
              ),
            ],
          ),
        ),
      ),
    );
  }
}
