// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payflexx/Controllers/providerController.dart';
import 'package:payflexx/validators/My_validators.dart';


class AddProviderPage extends StatefulWidget {
  static const routeName = '/addProvider';

  const AddProviderPage({Key? key}) : super(key: key);

  @override
  _AddProviderPageState createState() => _AddProviderPageState();
}

class _AddProviderPageState extends State<AddProviderPage> {
  late TextEditingController nameController, emailController, phoneController, dobController, cinController, passwordController, sPCController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    dobController = TextEditingController();
    cinController= TextEditingController();
    passwordController = TextEditingController();
    sPCController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    cinController.dispose();
    passwordController.dispose();
    sPCController.dispose();
    super.dispose();
  }
Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime
          .now(), // Consider setting an initial date relevant to your app
      firstDate: DateTime(1900), // Earliest allowable date
      lastDate: DateTime.now(), // Latest allowable date
      // You can customize the theme of the date picker below
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary:
                  Color.fromARGB(255, 198, 148, 244), // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            dialogBackgroundColor: Colors.white, // background color
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != DateTime.now()) {
      // Formatting and setting the date to _dobController
      dobController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }
 void addProvider() async {
  if (_formKey.currentState!.validate()) {
    bool result = await authProviderController()
        .registerProviderWithoutNavigation(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      providerName: nameController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      dob: dobController.text.trim(),
      cin: cinController.text.trim(),
      securityPinCode: sPCController.text.trim(),
      context: context,
    );

    if (result) {
      // Clear form fields if registration is successful
      nameController.clear();
      emailController.clear();
      phoneController.clear();
      dobController.clear();
      cinController.clear();
      passwordController.clear();
      sPCController.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Provider added successfully.")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to add provider.")));
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Provider'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (Value) {
                        return MyValidators.displayNamevalidator(
                            Value); // Assuming this is a static method in MyValidators class
                      },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                 
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
               validator: (Value) {
                        return MyValidators.emailValidator(
                            Value); // Assuming this is a static method in MyValidators class
                      },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: phoneController,
                  keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                 validator: (Value) {
                        return MyValidators.phoneValidator(
                            Value); // Assuming this is a static method in MyValidators class
                      },
               
              ),
              const SizedBox(height: 20),
               const  SizedBox(height: 20),
              TextFormField(
                controller: dobController,
                
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  prefixIcon:const  Icon(Icons.calendar_today),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon:const  Icon(Icons.date_range),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'This field cannot be empty' : null,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: cinController,
                 keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'CIN',
             
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (Value) {
                        return MyValidators.cinValidator(
                            Value); // Assuming this is a static method in MyValidators class
                      },
                 
              ),
               const   SizedBox(height: 20),
               TextFormField(
                controller: sPCController,
                   keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Security Pin Code',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (Value) {
                        return MyValidators.fourDigitValidator(
                            Value); // Assuming this is a static method in MyValidators class
                      },
               ),
               
              
               const   SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => MyValidators.passwordValidator(value),
              ),
            const   SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, color: Colors.white, size: 24),
                label: const Text('Add Provider'),
                onPressed: addProvider,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.deepPurple,
                  textStyle: const TextStyle(fontSize: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
