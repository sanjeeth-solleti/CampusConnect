import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendancePage extends StatelessWidget {
  final String regId;

  const AttendancePage({super.key, required this.regId});

  Future<List<Map<String, dynamic>>> fetchAttendanceData() async {
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('students')
            .where('regId', isEqualTo: regId)
            .get();

    if (querySnapshot.docs.isEmpty) {
      print("No document found with regId: $regId");
      return [];
    }

    final data = querySnapshot.docs.first.data();
    if (data == null) return [];

    final Attendance = data['Attendance'] as Map<String, dynamic>?;

    if (Attendance == null) {
      print("Attendance field is null for regId: $regId");
      return [];
    }

    final List<dynamic> Month = Attendance['Month'] ?? [];
    final List<dynamic> Conducted = Attendance['Conducted'] ?? [];
    final List<dynamic> Attended = Attendance['Attended'] ?? [];
    final List<dynamic> percentage = Attendance['Percentage'] ?? [];

    List<Map<String, dynamic>> tableData = [];

    for (int i = 0; i < Month.length; i++) {
      tableData.add({
        'Month': Month[i] ?? '',
        'Conducted': i < Conducted.length ? Conducted[i] : 0,
        'Attended': i < Attended.length ? Attended[i] : 0,
        'Percentage': i < percentage.length ? percentage[i] : '0%',
      });
    }

    return tableData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: Colors.red.shade700,
        elevation: 0,
        foregroundColor: const Color.fromARGB(255, 254, 254, 254),
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
          // Background image
          SizedBox.expand(
            child: Image.asset(
              'assets/background/image.png',
              fit: BoxFit.cover,
            ),
          ),
          // Foreground content
          FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchAttendanceData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No attendance data found',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              }

              final attendanceList = snapshot.data!;

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    top: 100,
                    bottom: 30,
                    left: 16,
                    right: 16,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Attendance - $regId',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 189, 2, 2),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 24,
                            headingRowColor: WidgetStateProperty.all(
                              Colors.red[100],
                            ),
                            dataRowColor: WidgetStateProperty.all(Colors.white),
                            border: TableBorder.all(
                              color: Colors.red.shade300,
                              width: 1.5,
                            ),
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'Month',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Conducted',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Attended',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Percentage',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows:
                                attendanceList.map((data) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(data['Month'].toString())),
                                      DataCell(
                                        Text(data['Conducted'].toString()),
                                      ),
                                      DataCell(
                                        Text(data['Attended'].toString()),
                                      ),
                                      DataCell(
                                        Text(data['Percentage'].toString()),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
