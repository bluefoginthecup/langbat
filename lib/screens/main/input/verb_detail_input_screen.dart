// lib/screens/input/verb_detail_input_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerbDetailInputScreen extends StatefulWidget {
  final String verb;     // 기존 동사 원형 (예: "hablar")
  final String meaning;  // 동사의 뜻 (예: "말하다")

  const VerbDetailInputScreen({
    Key? key,
    this.verb='',
    this.meaning='',
  }) : super(key: key);

  @override
  _VerbDetailInputScreenState createState() => _VerbDetailInputScreenState();
}

class _VerbDetailInputScreenState extends State<VerbDetailInputScreen> {
  // 동사원형을 수정할 수 있는 컨트롤러 추가
  late TextEditingController _verbController;
  final TextEditingController _presentController = TextEditingController();
  final TextEditingController _preteriteController = TextEditingController();
  final TextEditingController _imperfectController = TextEditingController();
  final TextEditingController _futureController = TextEditingController();
  final TextEditingController _meaningController = TextEditingController();
  final TextEditingController _subjunctiveController = TextEditingController();
  final TextEditingController _imperativeController = TextEditingController();
  final TextEditingController _beginnerExampleController = TextEditingController();
  final TextEditingController _intermediateExampleController = TextEditingController();
  final TextEditingController _advancedExampleController = TextEditingController();

  // 헬퍼 함수: 동사 변화 맵을 콤마로 구분된 문자열로 변환
  String _mapToCommaSeparatedString(Map<String, dynamic> conjugationMap) {
    final order = ["yo", "tú", "él/ella/Ud", "nosotros", "vosotros", "ellos/ellas/Uds"];
    return order.map((key) => conjugationMap[key] ?? "").join(', ');
  }

  // 콤마로 구분된 문자열을 리스트로 변환하는 함수
  List<String> _parseConjugation(String input) =>
      input.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  // Firestore에서 저장된 데이터를 불러와 컨트롤러에 채워 넣는 함수
  Future<void> _loadVerbDetails() async {
    final doc = await FirebaseFirestore.instance.collection('verbs').doc(widget.verb).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        // 동사원형 수정 컨트롤러에 초기값 설정
        _verbController.text = data['verb'] ?? widget.verb;
        _meaningController.text = data['meaning'] ?? widget.meaning;
        _presentController.text = _mapToCommaSeparatedString(data['conjugations']['present']);
        _preteriteController.text = _mapToCommaSeparatedString(data['conjugations']['preterite']);
        _imperfectController.text = _mapToCommaSeparatedString(data['conjugations']['imperfect']);
        _futureController.text = _mapToCommaSeparatedString(data['conjugations']['future']);
        _subjunctiveController.text = data['conjugations']['subjunctive'] != null
            ? _mapToCommaSeparatedString(data['conjugations']['subjunctive'])
            : "";
        _imperativeController.text = data['conjugations']['imperative'] != null
            ? _mapToCommaSeparatedString(data['conjugations']['imperative'])
            : "";
        _beginnerExampleController.text = data['examples']?['beginner'] ?? "";
        _intermediateExampleController.text = data['examples']?['intermediate'] ?? "";
        _advancedExampleController.text = data['examples']?['advanced'] ?? "";
      });
    }
  }

  Future<void> _saveVerbDetails() async {
    // 파싱
    final newVerb = _verbController.text.trim();
    final meaning = _meaningController.text.trim();
    final presentList = _parseConjugation(_presentController.text);
    final preteriteList = _parseConjugation(_preteriteController.text);
    final imperfectList = _parseConjugation(_imperfectController.text);
    final futureList = _parseConjugation(_futureController.text);
    final subjunctiveList = _parseConjugation(_subjunctiveController.text);
    final imperativeList = _parseConjugation(_imperativeController.text);

    Map<String, dynamic> buildConjugationMap(List<String> list) {
      return {
        "yo": list.length > 0 ? list[0] : "",
        "tú": list.length > 1 ? list[1] : "",
        "él/ella/Ud": list.length > 2 ? list[2] : "",
        "nosotros": list.length > 3 ? list[3] : "",
        "vosotros": list.length > 4 ? list[4] : "",
        "ellos/ellas/Uds": list.length > 5 ? list[5] : "",
      };
    }

    Map<String, dynamic> conjugations = {
      "present": buildConjugationMap(presentList),
      "preterite": buildConjugationMap(preteriteList),
      "imperfect": buildConjugationMap(imperfectList),
      "future": buildConjugationMap(futureList),
      "subjunctive": buildConjugationMap(subjunctiveList),
      "imperative": buildConjugationMap(imperativeList),
    };

    Map<String, dynamic> examples = {
      "beginner": _beginnerExampleController.text.trim(),
      "intermediate": _intermediateExampleController.text.trim(),
      "advanced": _advancedExampleController.text.trim(),
    };

    Map<String, dynamic> data = {
      "verb": newVerb,
      "meaning": meaning,
      "conjugations": conjugations,
      "examples": examples,
      "createdAt": FieldValue.serverTimestamp(),
    };

    try {
      // 만약 동사원형이 수정되었다면, 새 문서를 만들고 기존 문서를 삭제
      if (newVerb != widget.verb) {
        await FirebaseFirestore.instance.collection('verbs').doc(newVerb).set(data);
        await FirebaseFirestore.instance.collection('verbs').doc(widget.verb).delete();
      } else {
        await FirebaseFirestore.instance.collection('verbs').doc(newVerb).set(data);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("동사 정보가 저장되었습니다.")),
      );
      // 저장 후 최신 데이터를 다시 불러옵니다.
      await _loadVerbDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("저장 실패: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _verbController = TextEditingController(text: widget.verb);
    _loadVerbDetails();
  }

  @override
  void dispose() {
    _verbController.dispose();
    _presentController.dispose();
    _preteriteController.dispose();
    _imperfectController.dispose();
    _futureController.dispose();
    _meaningController.dispose();
    _subjunctiveController.dispose();
    _imperativeController.dispose();
    _beginnerExampleController.dispose();
    _intermediateExampleController.dispose();
    _advancedExampleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${_verbController.text} 동사 상세 정보"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildInputFields(),
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 동사원형 수정 필드
        TextField(
          controller: _verbController,
          decoration: const InputDecoration(
            labelText: '동사 원형 (예: hablar)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        // 뜻 입력 필드
        TextField(
          controller: _meaningController,
          decoration: const InputDecoration(
            labelText: '뜻 (예: 말하다)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        // 시제별 입력 필드
        TextField(
          controller: _presentController,
          decoration: const InputDecoration(
            labelText: '현재 시제 (예: hablo, hablas, habla, hablamos, habláis, hablan)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _preteriteController,
          decoration: const InputDecoration(
            labelText: '과거 시제 (예: hablé, hablaste, habló, hablamos, hablasteis, hablaron)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _imperfectController,
          decoration: const InputDecoration(
            labelText: '불완료 시제 (예: hablaba, hablabas, hablaba, hablábamos, hablabais, hablaban)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _futureController,
          decoration: const InputDecoration(
            labelText: '미래 시제 (예: hablaré, hablarás, hablará, hablaremos, hablaréis, hablarán)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        // 추가 시제: 접속법
        TextField(
          controller: _subjunctiveController,
          decoration: const InputDecoration(
            labelText: '접속법 (예: hable, hables, hable, hablemos, habléis, hablen)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        // 추가 시제: 명령법
        TextField(
          controller: _imperativeController,
          decoration: const InputDecoration(
            labelText: '명령법 (예: habla, hable, hablemos, hablad, hablen)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        // 예문 입력: 초급
        TextField(
          controller: _beginnerExampleController,
          decoration: const InputDecoration(
            labelText: '초급 예문 (예: Acepto tu ayuda.)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        // 예문 입력: 중급
        TextField(
          controller: _intermediateExampleController,
          decoration: const InputDecoration(
            labelText: '중급 예문 (예: Cuando era niño, aceptaba todo sin preguntar.)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        // 예문 입력: 고급
        TextField(
          controller: _advancedExampleController,
          decoration: const InputDecoration(
            labelText: '고급 예문 (예: Es importante que aceptemos nuestras diferencias.)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _saveVerbDetails,
          child: const Text("저장"),
        ),
      ],
    );
  }
}
