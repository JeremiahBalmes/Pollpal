import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'answer_survey_screen.dart';

class SurveyListScreen extends StatelessWidget {
  const SurveyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Surveys'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('surveys').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No surveys available."));
          }

          var surveys = snapshot.data!.docs;

          return ListView.builder(
            itemCount: surveys.length,
            itemBuilder: (context, index) {
              var survey = surveys[index];
              var surveyId = survey.id;
              var surveyTitle = survey['title'] ?? 'Untitled Survey';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    surveyTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnswerSurveyScreen(surveyId: surveyId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Answer Survey"),
              ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
         