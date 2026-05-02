import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  // REGISTER
  static Future<void> register({
    required String email,
    required String password,
    required String role,
    }) async {
      final cred = await FirebaseAuth.instance
      .createUserWithEmailAndPassword(
        email: email,
        password: password,
        );
        
        final uid = cred.user!.uid;
        
        String? code;

  // 🔥 ONLY USER GETS VERIFICATION
  if (role == "user") { 
    code = (100000 +
            (DateTime.now().millisecondsSinceEpoch % 900000))
        .toString();

    print("USER VERIFICATION CODE: $code");
  }

  await FirebaseFirestore.instance.collection('users').doc(uid).set({
    'email': email,
    'role': role,
    'isVerified': role == "user" ? false : true,
    'verificationCode': code,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

  // LOGIN
  static Future<void> login({
    required String email,
    required String password,
    }) async {
      try {
        final cred = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
          email: email,
          password: password,
          );
          
          if (cred.user == null) {
            throw Exception("User not found");
            }
            
            } on FirebaseAuthException catch (e) {
              throw Exception(e.message);
              }
         }

  static Future<void> logout() async {
  await FirebaseAuth.instance.signOut();
}

  static Future<String?> getUserRole() async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) return null;

    final doc = await _db.collection('users').doc(uid).get();

    if (!doc.exists) return null;

    return doc.data()?['role'];
  }

  
}