import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'optionspage.dart';

class RegistrationIDPage extends StatefulWidget {
  const RegistrationIDPage({super.key});

  @override
  State<RegistrationIDPage> createState() => _RegistrationIDPageState();
}

class _RegistrationIDPageState extends State<RegistrationIDPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _regIdController = TextEditingController();
  bool _isLoading = false;

  void _showErrorSnackBar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _checkUserExists() async {
    final String name = _nameController.text.trim();
    final String regId = _regIdController.text.trim();

    if (name.isEmpty || regId.isEmpty) {
      _showErrorSnackBar("Please fill all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('students')
              .where('name', isEqualTo: name)
              .where('regId', isEqualTo: regId)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final userData = snapshot.docs.first.data();

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => OptionsPage(
                  name: userData['name'] ?? '',
                  regId: userData['regId'] ?? '',
                  branch: userData['branch'] ?? '',
                  section: userData['section'] ?? '',
                  // --- FIX WAS HERE ---
                  yearSem: userData['year/sem'] ?? '',
                ),
          ),
        );
      } else {
        _showErrorSnackBar("User not found");
      }
    } catch (e) {
      _showErrorSnackBar("Error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background/image.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/logo/image.png', height: 100),
                    const SizedBox(height: 24),
                    const Text(
                      "Enter Your Details",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Name",
                        prefixIcon: const Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _regIdController,
                      decoration: InputDecoration(
                        labelText: "Registration ID",
                        prefixIcon: const Icon(Icons.credit_card),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 6,
                        ),
                        onPressed: _isLoading ? null : _checkUserExists,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text(
                          "Sign In",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
