import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../customer/customer_home.dart';
import '../driver/driver_home.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String role;

  OtpScreen({required this.phone, required this.role});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final otpController = TextEditingController();
  String verificationId = '';

  @override
  void initState() {
    super.initState();
    sendOtp();
  }

  void sendOtp() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91${widget.phone}',
      verificationCompleted: (credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (e) {
        print('Failed: $e');
      },
      codeSent: (verId, _) {
        setState(() {
          verificationId = verId;
        });
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  void verifyOtp() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpController.text.trim(),
    );

    UserCredential userCred =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // Store role in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCred.user!.uid)
        .set({
      'phone': widget.phone,
      'role': widget.role,
    });

    if (widget.role == 'driver') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DriverHome()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CustomerHome()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter OTP')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'OTP'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: verifyOtp,
              child: Text('Verify & Continue'),
            )
          ],
        ),
      ),
    );
  }
}
