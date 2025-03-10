import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnswerSurveyScreen extends StatefulWidget {
  final String surveyId;

  const AnswerSurveyScreen({super.key, required this.surveyId});

  @override
  _AnswerSurveyScreenState createState() => _AnswerSurveyScreenState();
}

class _AnswerSurveyScreenState extends State<AnswerSurveyScreen> {
  final List<Map<String, dynamic>> _answers = []; // List to store responses

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Answer Survey"),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('surveys').doc(widget.surveyId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Survey not found."));
          }

          var surveyData = snapshot.data!.data() as Map<String, dynamic>;
          var questions = surveyData.containsKey('questions') && surveyData['questions'] is List
              ? surveyData['questions'] as List<dynamic>
              : [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                surveyData['title'] ?? "Survey",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...questions.asMap().entries.map((entry) {
                int index = entry.key;
                var questionData = entry.value;
                String question = questionData['question'] ?? "Question ${index + 1}";
                String type = questionData['type'] ?? "short";

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      question,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),

                    // ✅ HANDLE MULTIPLE CHOICE QUESTIONS
                    if (type == "multiple_choice" && questionData.containsKey('choices')) ...[
                      ...(questionData['choices'] as List<dynamic>).map((option) {
                        return RadioListTile(
                          title: Text(option),
                          value: option,
                          groupValue: _answers.any((ans) => ans['question'] == question)
                              ? _answers.firstWhere((ans) => ans['question'] == question)['answer']
                              : null,
                          onChanged: (value) {
                            setState(() {
                              _updateAnswer(question, value);
                            });
                          },
                        );
                      }).toList(),
                    ] 
                    // ✅ HANDLE SHORT ANSWER QUESTIONS
                    else ...[
                      TextField(
                        onChanged: (value) {
                          _updateAnswer(question, value);
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Your answer",
                        ),
                      ),
                    ],
                  ],
                );
              }).toList(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Reference to the responses collection
                    CollectionReference responsesRef = FirebaseFirestore.instance.collection('responses');

                    // Add response document
                    DocumentReference responseDoc = await responsesRef.add({
                      'surveyId': widget.surveyId,
                      'answers': _answers,
                      'timestamp': FieldValue.serverTimestamp(),
                    });

                    // Reference to the survey document
                    DocumentReference surveyRef = FirebaseFirestore.instance.collection('surveys').doc(widget.surveyId);

                    // Update the survey document to store response IDs
                    await surveyRef.update({
                      'responses': FieldValue.arrayUnion([responseDoc.id]) // Add response ID to survey
                    });

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Survey submitted successfully!")),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error submitting survey: $e")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Submit Answers"),
              ),
            ],
          );
        },
      ),
    );
  }

  /// ✅ Update or add answers correctly
  void _updateAnswer(String question, dynamic answer) {
    int index = _answers.indexWhere((ans) => ans['question'] == question);
    if (index >= 0) {
      _answers[index]['answer'] = answer;
    } else {
      _answers.add({'question': question, 'answer': answer});
    }
  }
}
