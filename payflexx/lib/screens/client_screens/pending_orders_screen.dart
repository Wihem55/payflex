import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Controllers/providers/fullorder_provider.dart';
import '../inner_screens/orders/invoicePage.dart';

class PendingOrdersPage extends StatelessWidget {
  const PendingOrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Orders'),
      ),
      body: FutureBuilder(
        future: Provider.of<OrderProvider>(context, listen: false)
            .fetchPendingOrders(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var orders = snapshot.data!;
            if (orders.isEmpty) {
              return const Center(
                  child: Text("Aucune commande en cours n'a été trouvée."));
            }
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                var order = orders[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(order['productName'] ?? 'No Name'),
                    subtitle: Text(
                        'Quantity: ${order['quantity']} - Price: ${order['price']}'),
                    trailing: Text(order['nbCheques'] + ' Cheques'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InvoicePage(orderData: order),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("Pas de commandes disponibles."));
          }
        },
      ),
    );
  }
}
