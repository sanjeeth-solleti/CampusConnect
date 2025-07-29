import 'package:flutter/material.dart';
// Keep this import as it might be used elsewhere or needed for Firebase setup
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'fees.dart';
import 'marks.dart';
import 'attendance.dart';

class OptionsPage extends StatefulWidget {
  final String name;
  final String regId; // Used to find the student's document in the database
  final String branch;
  final String section;
  final String yearSem; // --- ADDED THIS LINE ---

  const OptionsPage({
    super.key,
    required this.name,
    required this.regId,
    required this.branch,
    required this.section,
    required this.yearSem, // --- AND THIS LINE ---
  });

  @override
  _OptionsPageState createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  String? _imageUrl; // To store the downloaded image URL

  @override
  void initState() {
    super.initState();
    _getImageUrlFromDatabase(); // Read the image URL from the database
  }

  // Function to read image URL from the database document using regId
  Future<void> _getImageUrlFromDatabase() async {
    print(
      'Reading student document for regId: ${widget.regId} from database',
    ); // Added logging
    if (widget.regId.isNotEmpty) {
      try {
        // Query the 'students' collection to find the document with the matching regId field
        // Assuming 'regId' is a field in the document, and document ID is random.
        QuerySnapshot studentQuery =
            await FirebaseFirestore.instance
                .collection('students')
                .where(
                  'regId',
                  isEqualTo: widget.regId,
                ) // Query using the 'regId' field
                .limit(1) // We expect only one document with this regId
                .get();

        if (studentQuery.docs.isNotEmpty) {
          // Get the first document that matches the regId
          DocumentSnapshot studentDoc = studentQuery.docs.first;

          // Get the image URL from the 'student_image' field
          String? imageUrl = studentDoc.get(
            'student_image',
          ); // Use the correct field name

          if (imageUrl != null && imageUrl.isNotEmpty) {
            print(
              'Successfully read image URL from database: $imageUrl',
            ); // Added logging
            setState(() {
              _imageUrl = imageUrl;
            });
          } else {
            print(
              'Image URL field is empty or null in database for regId: ${widget.regId}',
            ); // Added logging
            setState(() {
              _imageUrl = null;
            });
          }
        } else {
          print(
            'Student document not found in database for regId: ${widget.regId}',
          ); // Added logging
          setState(() {
            _imageUrl = null;
          });
        }
      } catch (e) {
        print('Error reading image URL from database: $e'); // Enhanced logging
        setState(() {
          _imageUrl = null;
        });
      }
    } else {
      print(
        'regId is empty, cannot read image URL from database',
      ); // Added logging
      setState(() {
        _imageUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keeping this print for confirmation that regId is passed to the widget
    print('regId in OptionsPage build: ${widget.regId}');
    // Removed the print for 'name' in build to avoid confusion and keep logging focused

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        backgroundColor: Colors.red.shade700.withOpacity(0.9),
        foregroundColor: Colors.white,
        elevation: 5,
        shadowColor: Colors.black26,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Logout') {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'Logout',
                    child: Text('Logout'),
                  ),
                ],
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background/image.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
          child: Column(
            children: [
              // Student Info + Photo Row
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailText("Name", widget.name),
                          const SizedBox(height: 12),
                          _buildDetailText("Reg ID", widget.regId),
                          const SizedBox(height: 12),
                          // --- ADDED THIS WIDGET ---
                          _buildDetailText("Year/Sem", widget.yearSem),
                          const SizedBox(height: 12),
                          _buildDetailText("Branch", widget.branch),
                          const SizedBox(height: 12),
                          _buildDetailText("Section", widget.section),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Student Photo (Square) from Firebase Storage
                    Container(
                      height: 170,
                      width: 150,
                      color: Colors.grey.shade300,
                      child:
                          _imageUrl != null
                              ? Image.network(
                                _imageUrl!,
                                fit: BoxFit.cover,
                                // You might still get network errors even with a valid URL,
                                // so keep the errorBuilder
                                errorBuilder: (context, error, stackTrace) {
                                  print(
                                    'Error loading image: $error',
                                  ); // Log image loading errors
                                  return Container(
                                    color: Colors.grey.shade400,
                                    child: const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              )
                              : Container(
                                color: Colors.grey.shade400,
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ), // Placeholder if image not found or URL is null/empty
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Buttons
              _buildButton("Fees", Icons.attach_money, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeesPage(regId: widget.regId),
                  ),
                );
              }),
              const SizedBox(height: 20),
              _buildButton("Marks", Icons.school, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MarksPage(regId: widget.regId),
                  ),
                );
              }),
              const SizedBox(height: 20),
              _buildButton("Attendance", Icons.check_circle, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AttendancePage(regId: widget.regId),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailText(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String title, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 22),
        label: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
          shadowColor: Colors.black45,
        ),
      ),
    );
  }
}
