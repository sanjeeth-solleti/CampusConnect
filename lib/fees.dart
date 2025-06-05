import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeesPage extends StatelessWidget {
  final String regId;

  const FeesPage({super.key, required this.regId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fees Details"),
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
      body: FutureBuilder<QuerySnapshot>(
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
            print("Firestore Error: ${snapshot.error}");
            return const Center(child: Text("Error fetching data"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print("⚠ No student found for Reg ID: $regId");
            return const Center(child: Text("Student data not found"));
          }

          var studentDoc =
              snapshot.data!.docs.first.data() as Map<String, dynamic>;
          print("Found Student Data: $studentDoc");

          if (!studentDoc.containsKey("fees")) {
            return const Center(child: Text("No fees data available"));
          }

          var fees = studentDoc["fees"] as Map<String, dynamic>;
          var sortedFees =
              fees.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

          return LayoutBuilder(
            builder: (context, constraints) {
              double fontSize = constraints.maxWidth < 600 ? 12 : 16;
              double cellPadding =
                  constraints.maxWidth < 600
                      ? 8
                      : constraints.maxWidth < 1000
                      ? 12
                      : 16;
              double columnWidth =
                  constraints.maxWidth < 600
                      ? 80
                      : constraints.maxWidth < 1000
                      ? 120
                      : 150;

              return Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Fees Details : $regId",
                                style: TextStyle(
                                  fontSize: fontSize + 4,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade800,
                                ),
                              ),
                              const SizedBox(height: 16),
                              DataTable(
                                border: TableBorder.all(
                                  color: Colors.red,
                                  width: 4,
                                ),
                                headingRowColor: WidgetStateColor.resolveWith(
                                  (states) => Colors.red.shade100,
                                ),
                                columns: [
                                  _buildHeader("Year", fontSize, columnWidth),
                                  _buildHeader(
                                    "Total Fees",
                                    fontSize,
                                    columnWidth,
                                  ),
                                  _buildHeader(
                                    "Paid Fees",
                                    fontSize,
                                    columnWidth,
                                  ),
                                  _buildHeader(
                                    "Pending Fees",
                                    fontSize,
                                    columnWidth,
                                  ),
                                ],
                                rows:
                                    sortedFees.map((entry) {
                                      var year = entry.key.replaceAll("-", " ");
                                      var feeDetails =
                                          entry.value as Map<String, dynamic>;

                                      return DataRow(
                                        cells: [
                                          _buildCell(
                                            year.toUpperCase(),
                                            fontSize,
                                            cellPadding,
                                          ),
                                          _buildCell(
                                            feeDetails["Total"]?.toString() ??
                                                "-",
                                            fontSize,
                                            cellPadding,
                                          ),
                                          _buildCell(
                                            feeDetails["paid"]?.toString() ??
                                                "-",
                                            fontSize,
                                            cellPadding,
                                          ),
                                          _buildCell(
                                            feeDetails["pending"]?.toString() ??
                                                "-",
                                            fontSize,
                                            cellPadding,
                                          ),
                                        ],
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  DataColumn _buildHeader(String text, double fontSize, double width) {
    return DataColumn(
      label: Container(
        width: width,
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  DataCell _buildCell(String text, double fontSize, double padding) {
    return DataCell(
      Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: padding),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize, color: Colors.black),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
