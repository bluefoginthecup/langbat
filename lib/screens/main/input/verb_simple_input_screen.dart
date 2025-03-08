// lib/screens/input/verb_simple_input_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerbSimpleInputScreen extends StatefulWidget {
  const VerbSimpleInputScreen({Key? key}) : super(key: key);

  @override
  _VerbSimpleInputScreenState createState() => _VerbSimpleInputScreenState();
}

class _VerbSimpleInputScreenState extends State<VerbSimpleInputScreen> {
  // 동사 원형을 입력받기 위한 별도의 컨트롤러
  final TextEditingController _verbController = TextEditingController();
  // 모든 동사 관련 데이터를 한 번에 입력받는 컨트롤러
  final TextEditingController _bulkInputController = TextEditingController();

  // "키: 값" 형태로 입력된 텍스트를 파싱하는 함수
  Map<String, String> _parseBulkInput(String input) {
    Map<String, String> parsed = {};
    final lines = input.split('\n');
    for (var line in lines) {
      if (line.contains(':')) {
        final parts = line.split(':');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.sublist(1).join(':').trim();
          parsed[key] = value;
        }
      }
    }
    return parsed;
  }

  // 콤마로 구분된 문자열을 인칭별 동사 변화 Map으로 변환하는 함수
  Map<String, dynamic> _buildConjugationMap(String input) {
    final list = input.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    return {
      "yo": list.length > 0 ? list[0] : "",
      "tú": list.length > 1 ? list[1] : "",
      "él/ella/Ud": list.length > 2 ? list[2] : "",
      "nosotros": list.length > 3 ? list[3] : "",
      "vosotros": list.length > 4 ? list[4] : "",
      "ellos/ellas/Uds": list.length > 5 ? list[5] : "",
    };
  }

  Future<void> _saveBulkData() async {
    final verb = _verbController.text.trim();
    if (verb.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("동사 원형을 입력하세요.")),
      );
      return;
    }

    final bulkInput = _bulkInputController.text;
    final parsed = _parseBulkInput(bulkInput);
    print("Parsed data: $parsed");

    final meaning = parsed["뜻"] ?? "";
    final present = parsed["현재"] ?? "";
    final preterite = parsed["과거"] ?? "";
    final imperfect = parsed["불완료"] ?? "";
    final future = parsed["미래"] ?? "";
    final subjunctive = parsed["접속법"] ?? "";
    final imperative = parsed["명령법"] ?? "";
    final beginnerExample = parsed["초급예문"] ?? "";
    final intermediateExample = parsed["중급예문"] ?? "";
    final advancedExample = parsed["고급예문"] ?? "";

    final conjugations = {
      "present": _buildConjugationMap(present),
      "preterite": _buildConjugationMap(preterite),
      "imperfect": _buildConjugationMap(imperfect),
      "future": _buildConjugationMap(future),
      "subjunctive": _buildConjugationMap(subjunctive),
      "imperative": _buildConjugationMap(imperative),
    };

    final examples = {
      "beginner": beginnerExample,
      "intermediate": intermediateExample,
      "advanced": advancedExample,
    };

    final data = {
      "verb": verb,
      "meaning": meaning,
      "conjugations": conjugations,
      "examples": examples,
      "createdAt": FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('verbs').doc(verb).set(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("동사 데이터가 저장되었습니다.")),
      );
      _verbController.clear();
      _bulkInputController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("저장 실패: $e")),
      );
    }
  }

  @override
  void dispose() {
    _verbController.dispose();
    _bulkInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("동사 간단 입력"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 동사 원형 입력 필드
            TextField(
              controller: _verbController,
              decoration: const InputDecoration(
                labelText: "동사 원형 (예: hablar)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            // 모든 정보를 한 번에 입력받는 필드
            Expanded(
              child: TextField(
                controller: _bulkInputController,
                decoration: const InputDecoration(
                  labelText: "모든 정보를 한 번에 입력하세요\n\n"
                      "예시:\n"
                      "뜻: 말하다\n"
                      "현재: hablo, hablas, habla, hablamos, habláis, hablan\n"
                      "과거: hablé, hablaste, habló, hablamos, hablasteis, hablaron\n"
                      "불완료: hablaba, hablabas, hablaba, hablábamos, hablabais, hablaban\n"
                      "미래: hablaré, hablarás, hablará, hablaremos, hablaréis, hablarán\n"
                      "접속법: hable, hables, hable, hablemos, habléis, hablen\n"
                      "명령법: habla, hable, hablemos, hablad, hablen\n"
                      "초급예문: Acepto tu ayuda.\n"
                      "중급예문: Cuando era niño, aceptaba todo sin preguntar.\n"
                      "고급예문: Es importante que aceptemos nuestras diferencias.",
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _saveBulkData,
              child: const Text("저장"),
            ),
          ],
        ),
      ),
    );
  }
}
