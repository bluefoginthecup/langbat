// lib/screens/input/verb_bulk_input_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerbBatchInputScreen extends StatefulWidget {
  final String verb; // 동사 원형
  final String defaultMeaning; // 기본 뜻 (옵션)

  const VerbBatchInputScreen({
    Key? key,
    required this.verb,
    this.defaultMeaning = "",
  }) : super(key: key);

  @override
  _VerbBatchInputScreenState createState() => _VerbBatchInputScreenState();
}

class _VerbBatchInputScreenState extends State<VerbBatchInputScreen> {
  final TextEditingController _bulkInputController = TextEditingController();

  // 사용자가 입력한 텍스트를 파싱하는 함수
  Map<String, String> _parseBulkInput(String input) {
    Map<String, String> parsed = {};
    // 각 줄마다 "키: 값" 형식이라고 가정
    List<String> lines = input.split('\n');
    for (var line in lines) {
      if (line.contains(':')) {
        var parts = line.split(':');
        if (parts.length >= 2) {
          String key = parts[0].trim();
          String value = parts.sublist(1).join(':').trim();
          parsed[key] = value;
        }
      }
    }
    return parsed;
  }

  // 콤마로 구분된 문자열을 리스트로 변환하는 헬퍼 함수
  List<String> _parseConjugation(String input) =>
      input.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  // 각 시제별로 입력된 값을 파싱하여 인칭별 매핑하는 함수
  Map<String, dynamic> _buildConjugationMap(String input) {
    List<String> list = _parseConjugation(input);
    return {
      "yo": list.length > 0 ? list[0] : "",
      "tú": list.length > 1 ? list[1] : "",
      "él/ella/Ud": list.length > 2 ? list[2] : "",
      "nosotros": list.length > 3 ? list[3] : "",
      "vosotros": list.length > 4 ? list[4] : "",
      "ellos/ellas/Uds": list.length > 5 ? list[5] : "",
    };
  }

  Future<void> _saveBulkVerbData() async {
    // 입력 텍스트를 파싱
    final bulkInput = _bulkInputController.text;
    final parsed = _parseBulkInput(bulkInput);

    // 각 필드별 값을 추출 (키 이름은 사용자가 정한 포맷에 맞춰야 합니다)
    final meaning = parsed["뜻"] ?? widget.defaultMeaning;
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
    Map<String, dynamic> conjugations = {
      "present": _buildConjugationMap(present),
      "preterite": _buildConjugationMap(preterite),
      "imperfect": _buildConjugationMap(imperfect),
      "future": _buildConjugationMap(future),
      "subjunctive": _buildConjugationMap(subjunctive),
      "imperative": _buildConjugationMap(imperative),
    };

    // 예문 데이터 구성
    Map<String, dynamic> examples = {
      "beginner": beginnerExample,
      "intermediate": intermediateExample,
      "advanced": advancedExample,
    };

    Map<String, dynamic> data = {
      "verb": widget.verb,
      "meaning": meaning,
      "conjugations": conjugations,
      "examples": examples,
      "createdAt": FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('verbs')
          .doc(widget.verb) // 동사원형을 문서 ID로 사용
          .set(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("동사 데이터가 저장되었습니다.")),
      );
      // 저장 후 입력 필드를 초기화하거나 최신 데이터를 불러올 수 있음
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.verb} 대량 입력"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "아래 형식에 맞춰 정보를 입력하세요.\n\n"
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
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 10),
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
              onPressed: _saveBulkVerbData,
              child: const Text("저장"),
            ),
          ],
        ),
      ),
    );
  }
}
