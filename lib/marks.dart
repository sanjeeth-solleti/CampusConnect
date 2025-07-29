import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MarksPage extends StatefulWidget {
  final String regId;

  const MarksPage({Key? key, required this.regId}) : super(key: key);

  @override
  _MarksPageState createState() => _MarksPageState();
}

class _MarksPageState extends State<MarksPage> {
  Map<String, dynamic>? marksData;
  bool loading = true;
  double? cgpa;

  final List<String> yearOrder = ['YEAR-1', 'YEAR-2', 'YEAR-3', 'YEAR-4'];
  final List<String> semOrder = ['SEM-1', 'SEM-2'];

  @override
  void initState() {
    super.initState();
    fetchStudentMarks(widget.regId);
  }

  Future<void> fetchStudentMarks(String regId) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('students')
              .where('regId', isEqualTo: regId)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        if (data.containsKey("marks")) {
          final marks = Map<String, dynamic>.from(data['marks']);
          double totalSgpa = 0;
          int count = 0;

          // Calculate CGPA
          marks.forEach((_, yearValue) {
            final yearData = Map<String, dynamic>.from(yearValue);
            yearData.forEach((_, semData) {
              final semMap = Map<String, dynamic>.from(semData);
              final sgpaVal = double.tryParse(semMap['SGPA']?.toString() ?? '');
              if (sgpaVal != null) {
                totalSgpa += sgpaVal;
                count++;
              }
            });
          });

          setState(() {
            marksData = marks;
            cgpa = count > 0 ? (totalSgpa / count) : null;
            loading = false;
          });
        } else {
          setState(() => loading = false);
        }
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      print("Error fetching student marks: $e");
      setState(() => loading = false);
    }
  }

  Widget buildMarksTable(
    String year,
    String sem,
    Map<String, dynamic> semData,
  ) {
    final sNos = List<String>.from(semData['S.No'] ?? []);
    final subjectCodes = List<String>.from(semData['Subject Code'] ?? []);
    final subjects = List<String>.from(semData['Subject'] ?? []);
    final grades = List<String>.from(semData['Grade'] ?? []);
    final status = List<String>.from(semData['Status'] ?? []);
    final credits = List<String>.from(
      semData['Credits']?.map((e) => e.toString()) ?? [],
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8.0),
      child: DataTable(
        columnSpacing: 38,
        headingRowColor: MaterialStateProperty.all(Colors.red[50]),
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        dataTextStyle: const TextStyle(color: Colors.black54),
        border: TableBorder.all(
          color: Colors.red.withOpacity(0.2),
          width: 1,
          borderRadius: BorderRadius.circular(8),
        ),
        columns: const [
          DataColumn(label: Text("S.No")),
          DataColumn(label: Text("Code")),
          DataColumn(label: Text("Subject")),
          DataColumn(label: Text("Grade")),
          DataColumn(label: Text("Status")),
          DataColumn(label: Text("Credits")),
        ],
        rows: List.generate(subjects.length, (index) {
          return DataRow(
            cells: [
              DataCell(Text(index < sNos.length ? sNos[index] : "")),
              DataCell(
                Text(index < subjectCodes.length ? subjectCodes[index] : ""),
              ),
              DataCell(
                SizedBox(
                  width: 200,
                  child: Text(index < subjects.length ? subjects[index] : ""),
                ),
              ),
              DataCell(Text(index < grades.length ? grades[index] : "")),
              DataCell(Text(index < status.length ? status[index] : "")),
              DataCell(Text(index < credits.length ? credits[index] : "")),
            ],
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Student Marks"),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        elevation: 0,
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
                (context) => const [
                  PopupMenuItem(value: 'Logout', child: Text('Logout')),
                ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background/image.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Foreground UI
          loading
              ? Center(child: CircularProgressIndicator(color: Colors.red[800]))
              : marksData == null
              ? const Center(
                child: Text(
                  "No marks data found for this student.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  if (cgpa != null)
                    Card(
                      elevation: 4,
                      shadowColor: Colors.red.withOpacity(0.2),
                      color: Colors.red[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              "Overall CGPA",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cgpa!.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Display each year-semester card
                  ...yearOrder.map((year) {
                    final yearData =
                        marksData![year] ?? marksData![year.toLowerCase()];
                    if (yearData == null) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          semOrder.map((sem) {
                            final semData =
                                yearData[sem] ?? yearData[sem.toLowerCase()];
                            if (semData == null) return const SizedBox.shrink();

                            final sgpa =
                                Map<String, dynamic>.from(
                                  semData,
                                )['SGPA']?.toString() ??
                                "N/A";

                            return Card(
                              elevation: 2,
                              shadowColor: Colors.red.withOpacity(0.1),
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ExpansionTile(
                                shape: const Border(),
                                title: Text(
                                  "$year - $sem",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[900],
                                  ),
                                ),
                                trailing: Text(
                                  "SGPA: $sgpa",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[900],
                                    fontSize: 16,
                                  ),
                                ),
                                children: [
                                  buildMarksTable(
                                    year,
                                    sem,
                                    Map<String, dynamic>.from(semData),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    );
                  }).toList(),
                ],
              ),
        ],
      ),
    );
  }
}
