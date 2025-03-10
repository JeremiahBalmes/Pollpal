import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

class CreateSurveyScreen extends StatefulWidget {
  const CreateSurveyScreen({super.key});

  @override
  _CreateSurveyScreenState createState() => _CreateSurveyScreenState();
}

class _CreateSurveyScreenState extends State<CreateSurveyScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<Map<String, dynamic>> _questions = [];
  String? _qrCodeUrl;

  void _addQuestion() {
    setState(() {
      _questions.add({
        'type': 'short_answer',
        'question': TextEditingController(),
        'choices': <TextEditingController>[],
      });
    });
  }

  void _addChoice(int questionIndex) {
    setState(() {
      _questions[questionIndex]['choices'].add(TextEditingController());
    });
  }

  void _removeChoice(int questionIndex, int choiceIndex) {
    setState(() {
      _questions[questionIndex]['choices'].removeAt(choiceIndex);
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  Future<void> _saveSurvey() async {
    String title = _titleController.text.trim();
    if (title.isEmpty || _questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a title and at least one question.")),
      );
      return;
    }

    List<Map<String, dynamic>> questionsData = _questions.map((q) {
      return {
        'type': q['type'],
        'question': q['question'].text.trim(),
        'choices': q['type'] == 'multiple_choice'
            ? q['choices'].map((c) => c.text.trim()).toList()
            : [],
      };
    }).toList();

    String surveyId = const Uuid().v4(); // Generates a unique survey ID
print("Generated Survey ID: $surveyId"); // ✅ Check if this prints a valid ID

String qrCodeUrl = "https://pollpal.page.link/?link=https://pollpal.com/survey/$surveyId&apn=com.example.surveyapp";
print("Generated QR Code URL: $qrCodeUrl"); // ✅ Check if this prints the correct link






   print("Generated QR Code URL: $qrCodeUrl");  
print("Scannable QR Data: ${_qrCodeUrl ?? 'No QR code generated'}");


    await FirebaseFirestore.instance.collection('surveys').doc(surveyId).set({
      'title': title,
      'questions': questionsData,
      'responses': 0,
      'created_at': Timestamp.now(),
      'qr_code': qrCodeUrl,
    });

    setState(() {
      _qrCodeUrl = qrCodeUrl;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Survey Saved!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Survey"),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Survey Title"),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _questions[index]['question'],
                                  decoration: InputDecoration(
                                    labelText: "Question ${index + 1}",
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeQuestion(index),
                              ),
                            ],
                          ),
                          DropdownButton<String>(
                            value: _questions[index]['type'],
                            items: const [
                              DropdownMenuItem(value: 'short_answer', child: Text("Short Answer")),
                              DropdownMenuItem(value: 'multiple_choice', child: Text("Multiple Choice")),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _questions[index]['type'] = value;
                                if (value == 'multiple_choice' && _questions[index]['choices'].isEmpty) {
                                  _questions[index]['choices'].add(TextEditingController());
                                } else if (value == 'short_answer') {
                                  _questions[index]['choices'].clear();
                                }
                              });
                            },
                          ),
                          if (_questions[index]['type'] == 'multiple_choice') ...[
                            Column(
                              children: [
                                for (int i = 0; i < _questions[index]['choices'].length; i++)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _questions[index]['choices'][i],
                                          decoration: InputDecoration(
                                            labelText: "Choice ${i + 1}",
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                                        onPressed: () => _removeChoice(index, i),
                                      ),
                                    ],
                                  ),
                                TextButton(
                                  onPressed: () => _addChoice(index),
                                  child: const Text("Add Choice"),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            if (_qrCodeUrl != null) ...[
              const Text("Scan this QR Code to access the survey:"),
              const SizedBox(height: 10),
              QrImageView(
                data: _qrCodeUrl!,
                size: 200,
              ),
            ],
            ElevatedButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add),
              label: const Text("Add Question"),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _saveSurvey,
              icon: const Icon(Icons.save),
              label: const Text("Save Survey"),
            ),
          ],
        ),
      ),
    );
  }
}
