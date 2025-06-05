import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'optionspage.dart';

class RegistrationIDPage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _regIdController = TextEditingController();

  RegistrationIDPage({super.key});

  void _showErrorSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _checkUserExists(BuildContext context) async {
    final String name = _nameController.text.trim();
    final String regId = _regIdController.text.trim();

    if (name.isEmpty || regId.isEmpty) {
      _showErrorSnackBar(context, "Please fill all fields");
      return;
    }

    try {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('students')
              .where('regId', isEqualTo: regId)
              .where('name', isEqualTo: name)
              .limit(1)
              .get();

      if (context.mounted) Navigator.of(context).pop();

      if (snapshot.docs.isNotEmpty) {
        final userData = snapshot.docs.first.data() as Map<String, dynamic>;
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => OptionsPage(
                    name: userData['name'],
                    regId: userData['regId'],
                    branch: userData['branch'],
                    section: userData['section'],
                  ),
            ),
          );
        }
      } else {
        // ignore: use_build_context_synchronously
        _showErrorSnackBar(context, "User not found");
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        _showErrorSnackBar(context, "Error: ${e.toString()}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          height: 600,
          width: 360,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red, width: 2),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 24,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/image.png', height: 100),
                  const SizedBox(height: 20),
                  const Text(
                    "Enter Your Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: Colors.black),
                      hintText: "Name",
                      hintStyle: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black38),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _regIdController,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.credit_card,
                        color: Colors.black,
                      ),
                      hintText: "Registration ID",
                      hintStyle: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black38),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () => _checkUserExists(context),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Submit",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
