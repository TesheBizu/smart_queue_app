import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/user_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/provider_screen.dart';
import 'screens/verify_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 REQUIRED FOR FIREBASE
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/register': (context) => RegisterScreen(),
        //'/verify': (context) => const VerifyScreen(),
      },
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // 🔄 Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ Not logged in
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        final user = FirebaseAuth.instance.currentUser!;

        // 🔥 CHECK FIRESTORE USER DOC
        return FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snap) {

            if (!snap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final data = snap.data!.data() as Map<String, dynamic>?;

            if (data == null) {
              return const LoginScreen();
            }

            // 🔥 BLOCK IF NOT VERIFIED
            if (data['isVerified'] != true) {
              return const VerifyScreen();
            }

            final role = data['role'];

            // 🔥 ROUTE BASED ON ROLE
            if (role == "admin") {
              return const AdminScreen();
            } else if (role == "provider") {
              return const ProviderScreen();
            } else {
              return const UserScreen();
            }
          },
        );
      },
    );
  }
}