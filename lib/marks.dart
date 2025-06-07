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

          marks.forEach((yearKey, yearValue) {
            final yearData = Map<String, dynamic>.from(yearValue);
            yearData.forEach((semKey, semData) {
              final semMap = Map<String, dynamic>.from(semData);
              if (semMap.containsKey('SGPA')) {
                final sgpaVal = double.tryParse(semMap['SGPA'].toString());
                if (sgpaVal != null) {
                  totalSgpa += sgpaVal;
                  count++;
                }
              }
            });
          });

          setState(() {
            marksData = marks;
            cgpa = count > 0 ? (totalSgpa / count) : null;
            loading = false;
          });
        } else {
          setState(() {
            loading = false;
          });
        }
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print("Error fetching student marks: $e");
      setState(() {
        loading = false;
      });
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
    final sgpa = semData['SGPA']?.toString() ?? "N/A";

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$year - $sem",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red[800],
            ),
          ),
          SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DataTable(
                columnSpacing: 30,
                headingRowColor: MaterialStateProperty.all(Colors.red[100]),
                headingTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                dataTextStyle: TextStyle(color: Colors.black87),
                border: TableBorder.all(color: Colors.red, width: 1),
                columns: const [
                  DataColumn(label: SizedBox(width: 60, child: Text("S.No"))),
                  DataColumn(
                    label: SizedBox(width: 100, child: Text("Subject Code")),
                  ),
                  DataColumn(
                    label: SizedBox(width: 200, child: Text("Subject")),
                  ),
                  DataColumn(label: SizedBox(width: 80, child: Text("Grade"))),
                  DataColumn(
                    label: SizedBox(width: 100, child: Text("Status")),
                  ),
                  DataColumn(
                    label: SizedBox(width: 80, child: Text("Credits")),
                  ),
                ],
                rows: List.generate(subjects.length, (index) {
                  return DataRow(
                    cells: [
                      DataCell(Text(index < sNos.length ? sNos[index] : "")),
                      DataCell(
                        Text(
                          index < subjectCodes.length
                              ? subjectCodes[index]
                              : "",
                        ),
                      ),
                      DataCell(
                        Text(index < subjects.length ? subjects[index] : ""),
                      ),
                      DataCell(
                        Text(index < grades.length ? grades[index] : ""),
                      ),
                      DataCell(
                        Text(index < status.length ? status[index] : ""),
                      ),
                      DataCell(
                        Text(index < credits.length ? credits[index] : ""),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "SGPA: $sgpa",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red[900],
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> yearOrder = ['year-1', 'year-2', 'year-3', 'year-4'];
  List<String> semOrder = ['sem-1', 'sem-2'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Student Marks"),
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
                (BuildContext context) => const [
                  PopupMenuItem<String>(value: 'Logout', child: Text('Logout')),
                ],
          ),
        ],
      ),
      body:
          loading
              ? Center(child: CircularProgressIndicator())
              : marksData == null
              ? Center(child: Text("No marks data found."))
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (cgpa != null)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Text(
                          "CGPA: ${cgpa!.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[900],
                          ),
                        ),
                      ),
                    ...yearOrder.map((year) {
                      final yearData = marksData![year];
                      if (yearData == null) return SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            semOrder.map((sem) {
                              final semData = yearData[sem];
                              if (semData == null) return SizedBox.shrink();

                              return buildMarksTable(
                                year,
                                sem,
                                Map<String, dynamic>.from(semData),
                              );
                            }).toList(),
                      );
                    }).toList(),
                  ],
                ),
              ),
    );
  }
}
