import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SurveyDetailsScreen extends StatelessWidget {
  const SurveyDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print("Opening Survey Details Screen");
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final String? surveyId = args?['surveyId'];

    if (surveyId == null) {
      return const Scaffold(
        body: Center(
          child: Text("Survey ID is missing."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Survey Details"),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('surveys').doc(surveyId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Survey not found."));
          }

          var surveyData = snapshot.data!.data() as Map<String, dynamic>;
          List<dynamic>? responseIds = surveyData['responses'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surveyData['title'] ?? "No Title",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Description: ${surveyData['description'] ?? "No description"}",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Text(
                  "Total Responses: ${responseIds?.length ?? 0}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Responses:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (responseIds == null || responseIds.isEmpty)
                  const Text("No responses yet.")
                else
                  Expanded(
                    child: FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('responses')
                          .where(FieldPath.documentId, whereIn: responseIds)
                          .get(),
                      builder: (context, responseSnapshot) {
                        if (responseSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!responseSnapshot.hasData || responseSnapshot.data!.docs.isEmpty) {
                          return const Text("No responses found.");
                        }

                        var responses = responseSnapshot.data!.docs;

                        return ListView.builder(
                          itemCount: responses.length,
                          itemBuilder: (context, index) {
                            var responseData = responses[index].data() as Map<String, dynamic>;
                            print("DEBUG: Response Data -> $responseData");

                            var answers = responseData['answers'];

                            // ✅ Ensure `answers` is a Map before using `.entries`
                            Map<String, dynamic> formattedAnswers = {};

                            if (answers is List) {
                              for (int i = 0; i < answers.length; i++) {
                                formattedAnswers["Q${i + 1}"] = answers[i];
                              }
                            } else if (answers is Map<String, dynamic>) {
                              formattedAnswers = Map<String, dynamic>.from(answers);
                            }

                            print("DEBUG: Type of answers -> ${formattedAnswers.runtimeType}");
                            print("DEBUG: Answers content -> $formattedAnswers");

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Response ${index + 1}",
                                      style: const TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    ...formattedAnswers.entries.map((entry) {
                                      return Text(
                                        "${entry.key}: ${entry.value}",
                                        style: const TextStyle(fontSize: 14),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
