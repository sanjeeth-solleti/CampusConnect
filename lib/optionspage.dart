import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'fees.dart';
import 'marks.dart';
import 'attendance.dart';

class OptionsPage extends StatefulWidget {
  final String name;
  final String regId;
  final String branch;
  final String section;

  const OptionsPage({
    super.key,
    required this.name,
    required this.regId,
    required this.branch,
    required this.section,
  });

  @override
  _OptionsPageState createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        backgroundColor: Colors.red.shade700,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Student Info Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailText("Name", widget.name),
                  const SizedBox(height: 12),
                  _buildDetailText("Reg ID", widget.regId),
                  const SizedBox(height: 12),
                  _buildDetailText("Branch", widget.branch),
                  const SizedBox(height: 12),
                  _buildDetailText("Section", widget.section),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Navigation Buttons
            _buildButton("Fees", Icons.attach_money, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FeesPage(regId: widget.regId),
                ),
              );
            }),
            const SizedBox(height: 15),
            _buildButton("Marks", Icons.school, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MarksPage(regId: widget.regId),
                ),
              );
            }),
            const SizedBox(height: 15),
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
    );
  }

  // Helper widget to build student details
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

  // Helper widget to build buttons
  Widget _buildButton(String title, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 22),
        label: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
        ),
      ),
    );
  }
}
