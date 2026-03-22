// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/productdescreption_model.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance
  ProductDescriptionDataModel? currentProduct; // Current product

  // Function to add a product to Firestore
  Future<void> addProductToFirestore(ProductDescriptionDataModel product) async {
    try {
      await _firestore.collection('products').doc(product.productId).set({
        'price': product.price, // Set product price
        'productName': product.productName, // Set product name
        'productDescription': product.productDescription, // Set product description
        'code': product.code, // Set product code
        'productRef': product.productRef, // Set product reference
        'adresse': product.adresse, // Set product address
        'quantity': product.quantity, // Set product quantity
        'providerSelected': product.providerSelected, // Set selected provider
      });
      currentProduct = product; // Update current product
      notifyListeners(); // Notify listeners to update UI
    } catch (e) {
      rethrow; // Rethrow the error
    }
  }

  // Function to fetch a product from Firestore
  Future<void> fetchProductFromFirestore(String productId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        currentProduct = ProductDescriptionDataModel(
          productId: productId, // Set product ID
          price: data['price'], // Set product price
          productName: data['productName'], // Set product name
          productDescription: data['productDescription'], // Set product description
          code: data['code'], // Set product code
          productRef: data['productRef'], // Set product reference
          adresse: data['adresse'], // Set product address
          quantity: data['quantity'], // Set product quantity
          providerSelected: data['providerSelected'], // Set selected provider
        );
        notifyListeners(); // Notify listeners to update UI
      }
    } catch (e) {
      rethrow; // Rethrow the error
    }
  }
}
