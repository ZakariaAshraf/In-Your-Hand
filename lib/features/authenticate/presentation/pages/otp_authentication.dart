// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// import '../../../../core/utils/app_colors.dart';
//
// class OtpAuthentication extends StatelessWidget {
//   final String otp;
//
//   OtpAuthentication({super.key, required this.otp});
//
//   final pinController = TextEditingController();
//   final FirebaseAuth auth = FirebaseAuth.instance;
//
//   @override
//   Widget build(BuildContext context) {
//     // final l10n = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: AppBar(),
//       body: Column(
//         children: [
//           Pinput(
//             controller: pinController,
//             length: 6,
//             defaultPinTheme: PinTheme(
//               width: 50,
//               height: 50,
//               textStyle: TextStyle(
//                 fontSize: 20,
//                 color: Color.fromRGBO(30, 60, 87, 1),
//                 fontWeight: FontWeight.w600,
//               ),
//               decoration: BoxDecoration(
//                 color: AppColors.secondary,
//                 border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//             ),
//           ),
//           CustomButton(
//             title: "Verify",
//             onTap: () async {
//               String input = pinController.text;
//               if (input.isEmpty) {
//                 CustomToastWidget.show(
//                   context: context,
//                   title: "Enter number",
//                   iconPath: "assets/icons/icon.png",
//                 );
//               } else {
//                 try {
//                   PhoneAuthCredential credential = PhoneAuthProvider.credential(
//                     verificationId: otp,
//                     smsCode: input,
//                   );
//                   await auth.signInWithCredential(credential);
//                   CustomToastWidget.show(
//                     context: context,
//                     title: "Success",
//                     iconPath: "assets/icons/icon.png",
//                   );
//                 } on Exception catch (e) {
//                   print(e.toString());
//                 }
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
