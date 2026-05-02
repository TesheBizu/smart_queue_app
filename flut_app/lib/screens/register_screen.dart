import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import 'verify_screen.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key}); // ❗ no const

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  String role = "user";
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 EMAIL
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            // 🔹 PASSWORD
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            // 🔹 ROLE SELECTOR
            DropdownButtonFormField<String>(
              value: role,
              decoration: const InputDecoration(
                labelText: "Select Role",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "user", child: Text("User")),
                DropdownMenuItem(value: "provider", child: Text("Provider")),
                DropdownMenuItem(value: "admin", child: Text("Admin")),
              ],
              onChanged: (value) {
                setState(() {
                  role = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            // 🔥 REGISTER BUTTON
            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // 🔥 VALIDATION
                        if (emailCtrl.text.isEmpty ||
                            passCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill all fields"),
                            ),
                          );
                          return;
                        }

                        setState(() => isLoading = true);

                        try {
                          await AuthService.register(
                            email: emailCtrl.text.trim(),
                            password: passCtrl.text.trim(),
                            role: role,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Registration successful"),
                            ),
                          );

                          // 🔥 USER → VERIFY
                          if (role == "user") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const VerifyScreen(),
                              ),
                            );
                          } else {
                            // 🔥 ADMIN / PROVIDER → BACK TO LOGIN
                            Navigator.pop(context);
                          }

                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $e")),
                          );
                        }

                        setState(() => isLoading = false);
                      },
                      child: const Text("Register"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}