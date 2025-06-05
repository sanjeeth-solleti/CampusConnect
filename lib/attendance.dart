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
    // ignore: unnecessary_null_comparison
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
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: Colors.red[800],
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAttendanceData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No attendance data found'));
          }

          final attendanceList = snapshot.data!;

          return Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ATTENDENCE: $regId',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[800],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        border: TableBorder.all(color: Colors.red, width: 2.5),
                        headingRowColor: MaterialStateProperty.all(
                          Colors.white,
                        ),
                        dataRowColor: MaterialStateProperty.all(Colors.white),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Month',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Conducted',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Attended',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Percentage',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                        rows:
                            attendanceList.map((data) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      data['Month'].toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      data['Conducted'].toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      data['Attended'].toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      data['Percentage'].toString(),
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
