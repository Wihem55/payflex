import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDescriptionDataModel {
  String? price; // Price of the product
  String? productName; // Name of the product
  String? productDescription; // Description of the product
  String? code; // Code of the product
  String? productRef; // Reference of the product
  String? adresse; // Address related to the product
  String? quantity; // Quantity of the product
  String? providerSelected; // Selected provider for the product
  String? providerLogo; // Logo of the provider
  String? productId; // Product ID

  ProductDescriptionDataModel({
    this.price, // Optional parameter for price
    this.productName, // Optional parameter for product name
    this.productDescription, // Optional parameter for product description
    this.code, // Optional parameter for code
    this.productRef, // Optional parameter for product reference
    this.adresse, // Optional parameter for address
    this.quantity, // Optional parameter for quantity
    this.providerSelected, // Optional parameter for selected provider
    this.providerLogo, // Optional parameter for provider logo
    this.productId, // Optional parameter for product ID
  });

  // Factory constructor to create a ProductDescriptionDataModel from a Firestore document
  factory ProductDescriptionDataModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    return ProductDescriptionDataModel(
      price: doc.get('price'), // Get price from Firestore document
      productName: doc.get('productName'), // Get product name from Firestore document
      productDescription: doc.get('productDescription'), // Get product description from Firestore document
      code: doc.get('code'), // Get code from Firestore document
      productRef: doc.get('productRef'), // Get product reference from Firestore document
      adresse: doc.get('adresse'), // Get address from Firestore document
      quantity: doc.get('quantity'), // Get quantity from Firestore document
      providerSelected: doc.get('providerSelected'), // Get selected provider from Firestore document
      providerLogo: doc.get('providerLogo'), // Get provider logo from Firestore document
      productId: doc.id, // Get document ID as productId
    );
  }
}
