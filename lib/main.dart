import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const GugudanQuizApp());
}

class GugudanQuizApp extends StatelessWidget {
  const GugudanQuizApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '구구단 퀴즈',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GugudanQuizScreen(),
    );
  }
}

class GugudanQuizScreen extends StatefulWidget {
  const GugudanQuizScreen({Key? key}) : super(key: key);

  @override
  _GugudanQuizScreenState createState() => _GugudanQuizScreenState();
}

class _GugudanQuizScreenState extends State<GugudanQuizScreen> {
  late FlutterTts flutterTts;
  TextEditingController answerController = TextEditingController();
  int num = 2;
  int dan = 1;
  String feedbackText = '';
  bool showFeedback = false;
  final stt.SpeechToText _speech = stt.SpeechToText();

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    generateQuestion();
  }

  void generateQuestion() {
    setState(() {
      num = Random().nextInt(8) + 2; // 2부터 9까지의 랜덤한 숫자 선택
      dan = Random().nextInt(9) + 1; // 1부터 9까지의 랜덤한 숫자 선택
      showFeedback = false;
    });
    speakQuestion();
  }

  void speakQuestion() async {
    await flutterTts.setLanguage('ko-KR');
    await flutterTts.speak('$num 곱하기 $dan 은?');
  }

  void checkAnswer() {
    int userAnswer = int.tryParse(answerController.text) ?? 0;
    setState(() {
      if (userAnswer == num * dan) {
        feedbackText = '정답입니다!';
      } else {
        feedbackText = '틀렸습니다. 다시 풀어보세요.';
      }
      showFeedback = true;
      answerController.text ='';
    });
    speakFeedback();
  }

  void speakFeedback() async {
    await flutterTts.setLanguage('ko-KR');
    await flutterTts.speak(feedbackText);
  }

  void nextQuestion() {
    setState(() {
      answerController.text = '';
      showFeedback = false;
    });
    generateQuestion();
  }

  Future<void> listenForAnswer() async {
    if (await _speech.initialize()) {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            answerController.text = result.recognizedWords;
          });
        },
        listenFor: Duration(seconds: 30),
      );
    } else {
      print('음성 인식 초기화 실패');
    }
  }

  void stopListening() {
    _speech.stop();
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('구구단 퀴즈'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '$num X $dan = ?',
                style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: answerController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '답을 입력하세요',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: checkAnswer,
                child: const Text('정답 확인'),
              ),
              const SizedBox(height: 20.0),
              if (showFeedback)
                Text(
                  feedbackText,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: feedbackText.contains('정답') ? Colors.green : Colors.red,
                  ),
                ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: nextQuestion,
                child: const Text('다음 문제'),
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: listenForAnswer,
                child: const Text('음성 인식으로 대답하기'),
              ),
              ElevatedButton(
                onPressed: stopListening,
                child: const Text('음성 인식 멈추기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
