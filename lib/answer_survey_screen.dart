import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnswerSurveyScreen extends StatefulWidget {
  final String surveyId;
  final String userId;

  const AnswerSurveyScreen({super.key, required this.surveyId, required this.userId});

  @override
  _AnswerSurveyScreenState createState() => _AnswerSurveyScreenState();
}

class _AnswerSurveyScreenState extends State<AnswerSurveyScreen> {
  Map<String, dynamic> _responses = {}; // Stores user answers

  Future<void> submitResponses() async {
    if (_responses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please answer all questions.")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final responseData = {
      'surveyId': widget.surveyId,
      'userId': widget.userId,
      'timestamp': FieldValue.serverTimestamp(),
      'answers': _responses,
    };

    try {
      await FirebaseFirestore.instance.collection('responses').add(responseData);
      prefs.remove('offline_responses'); // Clear local storage if synced
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Responses submitted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      prefs.setString('offline_responses', responseData.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet. Response saved offline.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Answer Survey")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('surveys').doc(widget.surveyId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Survey not found"));
          }

          var survey = snapshot.data!.data() as Map<String, dynamic>;
          var title = survey['title'] ?? "Untitled";
          var questions = List<String>.from(survey['questions'] ?? []);
          var questionTypes = List<String>.from(survey['questionTypes'] ?? []);
          var optionsList = survey['options'] != null ? List<List<String>>.from(survey['options'].map((opt) => List<String>.from(opt))) : [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      var question = questions[index];
                      var questionType = questionTypes[index];

                      if (questionType == 'multiple_choice' && optionsList.isNotEmpty) {
                        var options = optionsList[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Q${index + 1}: $question", style: const TextStyle(fontWeight: FontWeight.bold)),
                            ...options.map((option) {
                              return RadioListTile<String>(
                                title: Text(option),
                                value: option,
                                groupValue: _responses[question],
                                onChanged: (value) {
                                  setState(() {
                                    _responses[question] = value!;
                                  });
                                },
                              );
                            }).toList(),
                          ],
                        );
                      } else {
                        return TextField(
                          decoration: InputDecoration(labelText: "Q${index + 1}: $question"),
                          onChanged: (value) {
                            setState(() {
                              _responses[question] = value;
                            });
                          },
                        );
                      }
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: submitResponses,
                  child: const Text("Submit Answers"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
