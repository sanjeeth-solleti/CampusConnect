import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeesPage extends StatelessWidget {
  final String regId;

  const FeesPage({super.key, required this.regId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Make transparent for image
      appBar: AppBar(
        title: const Text("Fees Details"),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background/image.png',
              fit: BoxFit.cover,
            ),
          ),
          FutureBuilder<QuerySnapshot>(
            future:
                FirebaseFirestore.instance
                    .collection('students')
                    .where('regId', isEqualTo: regId)
                    .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text("Error fetching data"));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("Student data not found"));
              }

              var studentDoc =
                  snapshot.data!.docs.first.data() as Map<String, dynamic>;

              if (!studentDoc.containsKey("fees")) {
                return const Center(child: Text("No fees data available"));
              }

              var fees = studentDoc["fees"] as Map<String, dynamic>;
              var sortedFees =
                  fees.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Text(
                      "Fee History of $regId",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 9, 8, 8),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      itemCount: sortedFees.length,
                      itemBuilder: (context, index) {
                        final entry = sortedFees[index];
                        final year =
                            entry.key.replaceAll("-", " ").toUpperCase();
                        final feeDetails = entry.value as Map<String, dynamic>;
                        return _buildFeeCard(context, year, feeDetails);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeeCard(
    BuildContext context,
    String year,
    Map<String, dynamic> feeDetails,
  ) {
    final total = feeDetails["Total"]?.toString() ?? "0";
    final paid = feeDetails["paid"]?.toString() ?? "0";
    final pending = feeDetails["pending"]?.toString() ?? "0";

    final double pendingAmount = double.tryParse(pending) ?? 0.0;
    final pendingColor =
        pendingAmount > 0
            ? Colors.red.shade700
            : const Color.fromARGB(255, 242, 8, 8);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              year,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const Divider(height: 24, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatColumn("Total Fee", "₹$total"),
                _buildStatColumn(
                  "Paid",
                  "₹$paid",
                  valueColor: const Color.fromARGB(221, 43, 221, 3),
                ),
                _buildStatColumn(
                  "Pending",
                  "₹$pending",
                  valueColor: pendingColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value, {
    Color valueColor = Colors.black,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
