// ignore_for_file: file_names

class FullOrderModel {
  final String? orderID, price, productName, productDescription, code, productRef,
                 adresse, quantity, providerSelected, productId, clientId, clientName,
                 clientSalary, articalPrice, nbCheques;
  final DateTime timestamp; // Timestamp for the order
  final List<DateTime> chequeDates; // List of cheque dates

  FullOrderModel({
      required this.price, // Price of the product
      required this.orderID, // Order ID
      required this.productName, // Name of the product
      required this.productDescription, // Description of the product
      required this.code, // Code of the product
      required this.productRef, // Reference of the product
      required this.adresse, // Address related to the order
      required this.quantity, // Quantity of the product ordered
      required this.providerSelected, // Provider selected for the order
      required this.productId, // Product ID
      required this.clientId, // Client ID
      required this.clientName, // Client Name
      required this.clientSalary, // Client Salary
      required this.articalPrice, // Article Price
      required this.nbCheques, // Number of cheques
      required this.timestamp, // Timestamp of the order
      required this.chequeDates, // List of cheque dates
  });

  // Method to convert FullOrderModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'orderID': orderID, // Set orderID in JSON
      'price': price, // Set price in JSON
      'productName': productName, // Set productName in JSON
      'productDescription': productDescription, // Set productDescription in JSON
      'code': code, // Set code in JSON
      'productRef': productRef, // Set productRef in JSON
      'adresse': adresse, // Set adresse in JSON
      'quantity': quantity, // Set quantity in JSON
      'providerSelected': providerSelected, // Set providerSelected in JSON
      'productId': productId, // Set productId in JSON
      'clientId': clientId, // Set clientId in JSON
      'clientName': clientName, // Set clientName in JSON
      'clientSalary': clientSalary, // Set clientSalary in JSON
      'articalPrice': articalPrice, // Set articalPrice in JSON
      'nbCheques': nbCheques, // Set nbCheques in JSON
      'timestamp': timestamp.toIso8601String(), // Convert timestamp to ISO 8601 string
      'chequeDates': chequeDates.map((date) => date.toIso8601String()).toList(), // Convert list of dates to list of ISO 8601 strings
    };
  }

  // Method to create a FullOrderModel from a JSON map
  factory FullOrderModel.fromJson(Map<String, dynamic> json) {
    return FullOrderModel(
      orderID: json['orderID'],
      price: json['price'],
      productName: json['productName'],
      productDescription: json['productDescription'],
      code: json['code'],
      productRef: json['productRef'],
      adresse: json['adresse'],
      quantity: json['quantity'],
      providerSelected: json['providerSelected'],
      productId: json['productId'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      clientSalary: json['clientSalary'],
      articalPrice: json['articalPrice'],
      nbCheques: json['nbCheques'],
      timestamp: DateTime.parse(json['timestamp']),
      chequeDates: (json['chequeDates'] as List<dynamic>).map((date) => DateTime.parse(date)).toList(),
    );
  }
}
