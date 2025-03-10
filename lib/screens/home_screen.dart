import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'survey_list_screen.dart'; // Import the survey list screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0b592f),
      appBar: AppBar(
        title: const Text("Survey Dashboard"),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.poll, color: Colors.white, size: 30),
                const SizedBox(width: 10),
                const Text(
                  "Welcome to the Survey App!",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (context.mounted) {
                      print("Create Survey button clicked");
                      Navigator.pushNamed(context, '/create_survey');
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Create Survey"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (context.mounted) {
                      print("Answer Survey button clicked");
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SurveyListScreen()),
                      );
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Answer Survey"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (context.mounted) {
                      print("QR Scanner button clicked");
                      Navigator.pushNamed(context, '/scan_qr');
                    }
                  },
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text("Scan QR"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            const Text(
              "Your Surveys",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('surveys').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No surveys found."));
                    }

                    return ListView(
                      children: snapshot.data!.docs.map((doc) {
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: ListTile(
                            leading: const Icon(Icons.assignment, color: Colors.green),
                            title: Text(
                              doc['title'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("Responses: ${doc['responses']}"),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              if (!mounted) return;
                              Navigator.pushNamed(context, '/survey_details', arguments: {'surveyId': doc.id});
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Survey Responses",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(
                        x: 0, barRods: [BarChartRodData(toY: 5, color: Colors.blue)]),
                    BarChartGroupData(
                        x: 1, barRods: [BarChartRodData(toY: 8, color: Colors.green)]),
                    BarChartGroupData(
                        x: 2, barRods: [BarChartRodData(toY: 3, color: Colors.red)]),
                  ],
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text("Survey A", style: TextStyle(color: Colors.black, fontSize: 12));
                            case 1:
                              return const Text("Survey B", style: TextStyle(color: Colors.black, fontSize: 12));
                            case 2:
                              return const Text("Survey C", style: TextStyle(color: Colors.black, fontSize: 12));
                            default:
                              return const Text("");
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
