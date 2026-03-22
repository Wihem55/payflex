// ignore_for_file: prefer_const_constructors

class ClientBankInfo {
  String clientId; // Client ID
  String bankName; // Bank Name
  String accountNumber; // Account Number
  String ribKey; // RIB Key
  String paySlipImageUrl; // URL of the pay slip image
  String chequeImageUrl; // URL of the cheque image
  String salary; // Client's salary

  ClientBankInfo({
    required this.clientId, // Required parameter for clientId
    required this.bankName, // Required parameter for bankName
    required this.accountNumber, // Required parameter for accountNumber
    required this.ribKey, // Required parameter for ribKey
    required this.paySlipImageUrl, // Required parameter for paySlipImageUrl
    required this.chequeImageUrl, // Required parameter for chequeImageUrl
    required this.salary, // Required parameter for salary
  });

  // Method to convert ClientBankInfo to a JSON map
  Map<String, dynamic> toJson() => {
        'clientId': clientId, // Set clientId in JSON
        'bankName': bankName, // Set bankName in JSON
        'accountNumber': accountNumber, // Set accountNumber in JSON
        'ribKey': ribKey, // Set ribKey in JSON
        'paySlipImageUrl': paySlipImageUrl, // Set paySlipImageUrl in JSON
        'chequeImageUrl': chequeImageUrl, // Set chequeImageUrl in JSON
        'Salary': salary, // Set salary in JSON
      };

  // Factory method to create a ClientBankInfo from a JSON map
  static ClientBankInfo fromJson(Map<String, dynamic> data) {
    return ClientBankInfo(
      clientId: data['clientId'], // Get clientId from JSON
      bankName: data['bankName'], // Get bankName from JSON
      accountNumber: data['accountNumber'], // Get accountNumber from JSON
      ribKey: data['ribKey'], // Get ribKey from JSON
      paySlipImageUrl: data['paySlipImageUrl'], // Get paySlipImageUrl from JSON
      chequeImageUrl: data['chequeImageUrl'], // Get chequeImageUrl from JSON
      salary: data['Salary'], // Get salary from JSON
    );
  }
}
