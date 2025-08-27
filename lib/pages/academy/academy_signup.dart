import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'academy_dashboard.dart';

class AcademySignUpPage extends StatefulWidget {
  const AcademySignUpPage({super.key});

  @override
  State<AcademySignUpPage> createState() => _AcademySignUpPageState();
}

class _AcademySignUpPageState extends State<AcademySignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _branchesController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();

  bool _loading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _signUpAcademy() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final rePassword = _rePasswordController.text.trim();

    if (password != rePassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => _loading = true);

    try {
      // Create Firebase Auth user
      final UserCredential user = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store Academy details in Firestore
      await _firestore.collection("academies").doc(user.user!.uid).set({
        "name": _nameController.text.trim(),
        "place": _placeController.text.trim(),
        "branches": _branchesController.text.trim(),
        "phone": _phoneController.text.trim(),
        "email": email,
        "createdAt": DateTime.now(),
      });

      // Navigate to Academy Dashboard
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AcademyDashboard(academyUid: user.user!.uid),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? "Sign-Up failed";
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Academy Sign-Up")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Academy Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _placeController,
              decoration: const InputDecoration(labelText: "Place"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _branchesController,
              decoration: const InputDecoration(
                labelText: "Branches (comma separated)",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: "Phone"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _rePasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Re-enter Password"),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _signUpAcademy,
                      child: const Text("Sign Up"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
