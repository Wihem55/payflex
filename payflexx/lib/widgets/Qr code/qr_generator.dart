import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/userbankinfo_model.dart';
import '../../Controllers/providers/clientbankInfo_provider.dart';
import '../../Controllers/providers/userinfo_provider.dart';

class QRCodeService {
  Future<String> fetchAndCombineUserInfo(BuildContext context) async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    ClientBankInfoProvider bankInfoProvider =
        Provider.of<ClientBankInfoProvider>(context, listen: false);

    UserModel? userModel = await userProvider.fetchUserInfo();
    ClientBankInfo? bankInfo = await bankInfoProvider.fetchClientBankInfo();

    if (userModel == null || bankInfo == null) {
      return 'Error: Missing data';
    }

    String combinedInfo = 'UserID: ${userModel.userId}, '
        'UserName: ${userModel.userName}, '
        'Email: ${userModel.userEmail}, '
        'Phone: ${userModel.phone}, '
        'DOB: ${userModel.dob}, '
        'CIN: ${userModel.cin}, '
        'BankName: ${bankInfo.bankName}, '
        //'AccountNumber: ${bankInfo.accountNumber}, '
        'RIB: ${bankInfo.ribKey}, '
        'Salary: ${bankInfo.salary}';
    return combinedInfo;
  }
}
