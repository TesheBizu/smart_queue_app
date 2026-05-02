import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final codeCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Enter 6-digit code sent to your email"),

            TextField(controller: codeCtrl),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final uid = FirebaseAuth.instance.currentUser!.uid;

                final doc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .get();

                final savedCode = doc['verificationCode'];

                if (codeCtrl.text == savedCode) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .update({
                    'isVerified': true,
                    'verificationCode': null,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Verified successfully")),
                  );

                  await FirebaseAuth.instance.signOut();

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid code")),
                  );
                }
              },
              child: const Text("Verify"),
            ),
          ],
        ),
      ),
    );
  }
}