// ignore_for_file: unused_local_variable, avoid_print, unnecessary_nullable_for_final_variable_declarations, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import '../../models/fullOrder_model.dart';

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance
  String? _currentUserId; // Current user ID

  // Function to add order to Firebase
  Future<void> addOrderToFirebase(FullOrderModel order, String? orderid) async {
    final FirebaseAuth auth = FirebaseAuth.instance; // Firebase Auth instance
    User? user = auth.currentUser; // Get current user
    _currentUserId = user?.uid; // Get user ID

    var orderData = order.toJson(); // Convert order to JSON

    try {
      await _firestore
          .collection('users')
          .doc(order.clientId)
          .collection('orders')
          .doc(orderid)
          .set(orderData); // Add order to user's collection
      if (_currentUserId != null) {
        await _firestore
            .collection('providers')
            .doc(_currentUserId)
            .collection('orders')
            .doc(orderid)
            .set(orderData); // Add order to provider's collection
      } else {
        throw Exception(
            "Current user ID is null, can't save order under provider");
      }
    } catch (e) {
      print("Failed to add order: $e");
      rethrow;
    }
    notifyListeners(); // Notify listeners to update UI
  }

  // Function to fetch orders
  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final FirebaseAuth auth = FirebaseAuth.instance; // Firebase Auth instance
    final User? user = auth.currentUser; // Get current user

    if (user == null) {
      print('User not logged in');
      return [];
    }

    final String userId = user.uid; // Get user ID
    List<Map<String, dynamic>> ordersData = [];

    // Fetch orders from the users collection
    ordersData.addAll(await fetchOrdersFromCollection('users', userId));

    // Fetch orders from the providers collection
    ordersData.addAll(await fetchOrdersFromCollection('providers', userId));

    if (ordersData.isEmpty) {
      print('No orders found for the user');
    }

    return ordersData;
  }

  // Function to fetch orders from a specific collection
  Future<List<Map<String, dynamic>>> fetchOrdersFromCollection(
      String collectionPath, String userId) async {
    try {
      final QuerySnapshot orderSnapshot = await _firestore
          .collection(collectionPath)
          .doc(userId)
          .collection('orders')
          .get();

      if (orderSnapshot.docs.isEmpty) {
        print('No orders found in $collectionPath for user $userId');
        return [];
      } else {
        return orderSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      }
    } catch (e) {
      print('Failed to fetch orders from $collectionPath: $e');
      return [];
    }
  }

  // Function to get user type
  Future<String?> _getUserType(String userId) async {
    try {
      final DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(userId).get();
      if (userSnapshot.exists) {
        final Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        return userData['userType'];
      } else {
        return null;
      }
    } catch (e) {
      print('Failed to fetch user type: $e');
      return null;
    }
  }

  // Function to fetch order details as a map
  Future<Map<String, dynamic>> fetchOrderDetailsAsMap(String? orderId) async {
    final FirebaseAuth auth = FirebaseAuth.instance; // Firebase Auth instance
    final User? user = auth.currentUser; // Get current user
    try {
      final DocumentSnapshot orderDoc = await _firestore
          .collection('providers')
          .doc(user?.uid)
          .collection('orders')
          .doc(orderId)
          .get();
      if (!orderDoc.exists) {
        print("Order with ID $orderId not found.");
        throw Exception("Order not found");
      }
      return orderDoc.data() as Map<String, dynamic>;
    } catch (e) {
      print("Failed to fetch order: $e");
      rethrow; // Rethrow to handle it outside or log more details.
    }
  }

  // Function to fetch specific fields from order details
  Future<Map<String, dynamic>> fetchOrderFields(String? orderId) async {
    Map<String, dynamic> orderDetails = await fetchOrderDetailsAsMap(orderId!);

    return {
      'productName': orderDetails['productName'],
      'productDescription': orderDetails['productDescription'],
      'productRef': orderDetails['productRef'],
      'providerSelected': orderDetails['providerSelected'],
      'quantity': orderDetails['quantity'],
      'Price': orderDetails['price'],
      'Client Name': orderDetails['clientName'],
      'Client Address': orderDetails['adresse'],
      'clientSalary': orderDetails['clientSalary'],
    };
  }

  // Function to send order details by email
  Future<void> sendOrderDetailsByEmail(String orderId) async {
    try {
      Map<String, dynamic> orderDetails = await fetchOrderDetailsAsMap(orderId);
      final email = Email(
        body: _createEmailBodyFromOrderDetails(orderDetails),
        subject: 'Order Details',
        recipients: ['recipient@example.com'], // Modify as necessary
        isHTML: false,
      );

      await FlutterEmailSender.send(email);
      print("Email sent successfully!");
    } catch (e) {
      print("Failed to send email: $e");
      rethrow;
    }
  }

  // Function to create email body from order details
  String _createEmailBodyFromOrderDetails(Map<String, dynamic> orderDetails) {
    return '''
Client Name: ${orderDetails['clientName']}
Product Name: ${orderDetails['productName']}
Product Description: ${orderDetails['productDescription']}
Quantity: ${orderDetails['quantity']}
Price: ${orderDetails['price']}
Client Address: ${orderDetails['clientAddress']}

Attached are the scanned cheques.
    ''';
  }

  // Function to fetch pending orders
  Future<List<Map<String, dynamic>>> fetchPendingOrders() async {
    List<Map<String, dynamic>> allOrders = await fetchOrders();
    List<Map<String, dynamic>> pendingOrders = [];
    DateTime now = DateTime.now();

    for (var order in allOrders) {
      DateTime orderDate = DateTime.parse(order['timestamp']);
      int monthsPassed =
          now.month - orderDate.month + 12 * (now.year - orderDate.year);
      if (monthsPassed < int.parse(order['nbCheques'])) {
        pendingOrders.add(order);
      }
    }

    if (pendingOrders.isEmpty) {
      print('No pending orders found');
    }

    return pendingOrders;
  }

  Map<int, int> _monthCounts = {}; // Map to store counts of orders per month

  Map<int, int> get monthCounts => _monthCounts; // Getter for month counts

  // Function to fetch and process orders to count orders per month
  void fetchAndProcessOrders() async {
    List<Map<String, dynamic>> pendingOrders = await fetchPendingOrders();
    _monthCounts = {};
    for (var order in pendingOrders) {
      DateTime orderDate = DateTime.parse(order['timestamp']);
      int orderMonth = orderDate.month;
      _monthCounts[orderMonth] = (_monthCounts[orderMonth] ?? 0) + 1;
    }
    notifyListeners(); // Notify listeners to update UI
  }

  // Function to delete an order
  Future<void> deleteOrder(BuildContext context, String orderId) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance; // Firebase Auth instance
      final User? user = auth.currentUser; // Get current user
      await _firestore
          .collection('providers')
          .doc(user?.uid)
          .collection('orders')
          .doc(orderId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order deleted successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
      print("Order deleted successfully!");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete order: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
      print("Failed to delete order: $e");
      rethrow;
    }
  }

  // Function to update an order
  Future<void> updateOrder(String orderId, Map<String, dynamic> updatedData,
      BuildContext context) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance; // Firebase Auth instance
      User? user = auth.currentUser; // Get current user

      if (user == null) {
        throw Exception('User not logged in');
      }

      String currentUserId = user.uid; // Get user ID

      // Update order in the provider's collection
      await _firestore
          .collection('providers')
          .doc(currentUserId)
          .collection('orders')
          .doc(orderId)
          .update(updatedData);

      // Update order in the user's collection
      await _firestore
          .collection('users')
          .doc(updatedData['clientId'])
          .collection('orders')
          .doc(orderId)
          .update(updatedData);

      print("Order updated successfully!");

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order updated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Failed to update order: $e");

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order: $e'),
          duration: const Duration(seconds: 2),
        ),
      );

      rethrow;
    }
  }

//save the cheques dates
Future<void> saveChequeDates(String orderId, List<DateTime> chequeDates,String clientId) async {
  final FirebaseAuth auth = FirebaseAuth.instance; // Firebase Auth instance
  final User? user = auth.currentUser; // Get current user
  String? currentUserId = user?.uid; // Get user ID

  if (currentUserId == null) {
    throw Exception('User not logged in');
  }

  List<String> chequeDatesStrings =
      chequeDates.map((date) => date.toIso8601String()).toList();

  try {
    // Log before updating Firestore
    print('Updating provider orders with user ID: $currentUserId, order ID: $orderId, cheque dates: $chequeDatesStrings');

    await _firestore
        .collection('providers')
        .doc(currentUserId)
        .collection('orders')
        .doc(orderId)
        .update({'chequeDates': chequeDatesStrings});

    // Log before updating user's collection
    print('Updating user orders with user ID: $currentUserId, order ID: $orderId, cheque dates: $chequeDatesStrings');

    await _firestore
        .collection('users')
        .doc(clientId)
        .collection('orders')
        .doc(orderId)
        .update({'chequeDates': chequeDatesStrings});

    print('Cheque dates saved successfully');
  } catch (e, stackTrace) {
    print("Failed to save cheque dates: $e");
    print("Stack trace: $stackTrace");
    rethrow;
  }
}

}
