// lib/screens/input/verb_detail_input_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerbDetailInputScreen extends StatefulWidget {
  final String verb;     // 동사 원형 (예: "hablar")
  final String meaning;  // 동사의 기본 뜻 (예: "말하다")

  const VerbDetailInputScreen({
    Key? key,
    required this.verb,
    required this.meaning,
  }) : super(key: key);

  @override
  _VerbDetailInputScreenState createState() => _VerbDetailInputScreenState();
}

class _VerbDetailInputScreenState extends State<VerbDetailInputScreen> {
  // 기존 시제별 컨트롤러
  final TextEditingController _presentController = TextEditingController();
  final TextEditingController _preteriteController = TextEditingController();
  final TextEditingController _imperfectController = TextEditingController();
  final TextEditingController _futureController = TextEditingController();

  // 추가 필드 컨트롤러
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

  // 콤마(,)로 구분된 문자열을 리스트로 변환하는 함수
  List<String> _parseConjugation(String input) =>
      input.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  // Firestore에서 저장된 데이터를 불러와 컨트롤러에 채워 넣는 함수 (초기 로드)
  Future<void> _loadVerbDetails() async {
    final doc = await FirebaseFirestore.instance
        .collection('verbs')
        .doc(widget.verb)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        // 기존 시제별 데이터
        _presentController.text =
            _mapToCommaSeparatedString(data['conjugations']['present']);
        _preteriteController.text =
            _mapToCommaSeparatedString(data['conjugations']['preterite']);
        _imperfectController.text =
            _mapToCommaSeparatedString(data['conjugations']['imperfect']);
        _futureController.text =
            _mapToCommaSeparatedString(data['conjugations']['future']);
        // 추가 필드
        _meaningController.text = data['meaning'] ?? widget.meaning;
        _subjunctiveController.text =
        data['conjugations']['subjunctive'] != null
            ? _mapToCommaSeparatedString(data['conjugations']['subjunctive'])
            : "";
        _imperativeController.text =
        data['conjugations']['imperative'] != null
            ? _mapToCommaSeparatedString(data['conjugations']['imperative'])
            : "";
        _beginnerExampleController.text =
        data['examples'] != null ? data['examples']['beginner'] ?? "" : "";
        _intermediateExampleController.text =
        data['examples'] != null ? data['examples']['intermediate'] ?? "" : "";
        _advancedExampleController.text =
        data['examples'] != null ? data['examples']['advanced'] ?? "" : "";
      });
    }
  }

  // 저장 함수: 모든 입력 필드를 Firestore에 저장
  Future<void> _saveVerbDetails() async {
    // 파싱
    final presentList = _parseConjugation(_presentController.text);
    final preteriteList = _parseConjugation(_preteriteController.text);
    final imperfectList = _parseConjugation(_imperfectController.text);
    final futureList = _parseConjugation(_futureController.text);
    final subjunctiveList = _parseConjugation(_subjunctiveController.text);
    final imperativeList = _parseConjugation(_imperativeController.text);

    // 각 시제별 인칭별 매핑 함수
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

    // 기존 시제 데이터
    Map<String, dynamic> conjugations = {
      "present": buildConjugationMap(presentList),
      "preterite": buildConjugationMap(preteriteList),
      "imperfect": buildConjugationMap(imperfectList),
      "future": buildConjugationMap(futureList),
      // 추가 시제: 접속법, 명령법
      "subjunctive": buildConjugationMap(subjunctiveList),
      "imperative": buildConjugationMap(imperativeList),
    };

    // 예문 데이터
    Map<String, dynamic> examples = {
      "beginner": _beginnerExampleController.text.trim(),
      "intermediate": _intermediateExampleController.text.trim(),
      "advanced": _advancedExampleController.text.trim(),
    };

    // 저장할 데이터 구조
    Map<String, dynamic> data = {
      "verb": widget.verb,
      "meaning": _meaningController.text.trim(),
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
        SnackBar(content: Text("동사 정보가 저장되었습니다.")),
      );
      // 저장 후 페이지 새로고침: 최신 데이터를 불러와서 입력 필드에 반영
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
    _loadVerbDetails();
  }

  @override
  void dispose() {
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
        title: Text("${widget.verb} 동사 상세 정보"),
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
        // 뜻 입력 (이미 전달된 값이 있다면 수정 가능하도록)
        TextField(
          controller: _meaningController,
          decoration: InputDecoration(
            labelText: '뜻 (예: 말하다)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        // 기존 시제 입력 필드들
        TextField(
          controller: _presentController,
          decoration: InputDecoration(
            labelText: '현재 시제 (예: hablo, hablas, habla, hablamos, habláis, hablan)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _preteriteController,
          decoration: InputDecoration(
            labelText: '과거 시제 (예: hablé, hablaste, habló, hablamos, hablasteis, hablaron)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _imperfectController,
          decoration: InputDecoration(
            labelText: '불완료 시제 (예: hablaba, hablabas, hablaba, hablábamos, hablabais, hablaban)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _futureController,
          decoration: InputDecoration(
            labelText: '미래 시제 (예: hablaré, hablarás, hablará, hablaremos, hablaréis, hablarán)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        // 추가 시제: 접속법
        TextField(
          controller: _subjunctiveController,
          decoration: InputDecoration(
            labelText: '접속법 (예: hable, hables, hable, hablemos, habléis, hablen)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        // 추가 시제: 명령법
        TextField(
          controller: _imperativeController,
          decoration: InputDecoration(
            labelText: '명령법 (예: habla, hable, hablemos, hablad, hablen)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        // 예문 입력: 초급
        TextField(
          controller: _beginnerExampleController,
          decoration: InputDecoration(
            labelText: '초급 예문 (예: Acepto tu ayuda.)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        // 예문 입력: 중급
        TextField(
          controller: _intermediateExampleController,
          decoration: InputDecoration(
            labelText: '중급 예문 (예: Cuando era niño, aceptaba todo sin preguntar.)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        // 예문 입력: 고급
        TextField(
          controller: _advancedExampleController,
          decoration: InputDecoration(
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
