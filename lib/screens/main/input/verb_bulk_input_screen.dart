// lib/screens/input/verb_bulk_input_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerbBulkInputScreen extends StatefulWidget {
  // 동사 원형을 생성자 매개변수로 받지 않고, 화면 내에서 입력하도록 할 수 있음.
  const VerbBulkInputScreen({super.key});

  @override
  _VerbBulkInputScreenState createState() => _VerbBulkInputScreenState();
}

class _VerbBulkInputScreenState extends State<VerbBulkInputScreen> {
  // 하나의 텍스트 필드에서 모든 데이터를 입력받음.
  final TextEditingController _bulkInputController = TextEditingController();
  // 동사 원형을 별도로 입력받기 위한 컨트롤러
  final TextEditingController _verbController = TextEditingController();

  // 사용자가 입력한 전체 텍스트를 "키: 값" 형식으로 파싱하는 함수
  Map<String, String> _parseBulkInput(String input) {
    Map<String, String> parsed = {};
    // 각 줄을 분리
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
      "yo": list.isNotEmpty ? list[0] : "",
      "tú": list.length > 1 ? list[1] : "",
      "él/ella/Ud": list.length > 2 ? list[2] : "",
      "nosotros": list.length > 3 ? list[3] : "",
      "vosotros": list.length > 4 ? list[4] : "",
      "ellos/ellas/Uds": list.length > 5 ? list[5] : "",
    };
  }

  Future<void> _saveBulkData() async {
    // 동사 원형은 별도의 텍스트 필드에서 받음.
    final verb = _verbController.text.trim();
    if (verb.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("동사 원형을 입력하세요.")),
      );
      return;
    }

    final bulkInput = _bulkInputController.text;
    final parsed = _parseBulkInput(bulkInput);

    // 파싱 결과를 콘솔에 출력하여 확인
    print("Parsed data: $parsed");

    // 각 항목의 값을 추출
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

    // 동사 변화 데이터 구성
    final conjugations = {
      "present": _buildConjugationMap(present),
      "preterite": _buildConjugationMap(preterite),
      "imperfect": _buildConjugationMap(imperfect),
      "future": _buildConjugationMap(future),
      "subjunctive": _buildConjugationMap(subjunctive),
      "imperative": _buildConjugationMap(imperative),
    };

    // 예문 데이터 구성
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
      // 저장 후 입력 필드 초기화
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
    _bulkInputController.dispose();
    _verbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("동사 대량 입력"),
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
            // 모든 정보를 하나의 텍스트 필드에 입력
            Expanded(
              child: TextField(
                controller: _bulkInputController,
                decoration: const InputDecoration(
                  labelText: "모든 정보를 한 번에 입력하세요",
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
