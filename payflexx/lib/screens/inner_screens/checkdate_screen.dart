// ignore_for_file: sort_child_properties_last, library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:payflexx/screens/provider_screens/sendEmail_page.dart';
import 'package:provider/provider.dart';

import '../../Controllers/providers/fullorder_provider.dart';

class ChequeDatePage extends StatefulWidget {
  final String orderId;
  final String clientId;
  final String nbcheques;

  const ChequeDatePage(
      {super.key,
      required this.orderId,
      required this.clientId,
      required this.nbcheques});

  @override
  _ChequeDatePageState createState() => _ChequeDatePageState();
}

class _ChequeDatePageState extends State<ChequeDatePage> {
  final List<DateTime> _selectedDates = [];
  final TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Cheque Dates'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Chèques Dates : ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Selectionnee les  Dates',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _saveChequeDates,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF003366), // Dark Blue
                      Color(0xFF48A999), // Teal
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_right, color: Colors.white, size: 25),
                      SizedBox(width: 15),
                      Text(
                        "Envoyer par e-mail",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSelectedDatesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDatesList() {
    return Expanded(
      child: ListView.builder(
        itemCount: _selectedDates.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              title: Text("${_selectedDates[index].toLocal()}".split(' ')[0]),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _selectedDates.removeAt(index);
                    _updateDateControllerText();
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    if (_selectedDates.length >= int.parse(widget.nbcheques)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'You cannot select more dates than the number of cheques.')),
      );
      return;
    }

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) {
      setState(() {
        _selectedDates.add(selectedDate);
        _updateDateControllerText();
      });
    }
  }

  void _updateDateControllerText() {
    _dateController.text = _selectedDates
        .map((date) => "${date.toLocal()}".split(' ')[0])
        .join(', ');
  }

  void _saveChequeDates() async {
    if (_selectedDates.length != int.parse(widget.nbcheques)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please select exactly ${widget.nbcheques} dates.')),
      );
      return;
    }

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      print(
          'Attempting to save cheque dates for order ID: ${widget.orderId}, dates: $_selectedDates');
      await orderProvider.saveChequeDates(
          widget.orderId, _selectedDates, widget.clientId);

      if (!mounted) {
        return; // Check if the widget is still mounted before navigating
      }

      print('Navigating to EmailSenderPage');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EmailSenderPage(
            orderId: widget.orderId,
            nbCheques: widget.nbcheques,
            chequeDates: _selectedDates,
          ),
        ),
      );
    } catch (e, stackTrace) {
      print('Failed to save cheque dates: $e');
      print('Stack trace: $stackTrace');

      if (!mounted) return;

      // Show a snackbar on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save cheque dates: $e')),
      );
    }
  }
}
