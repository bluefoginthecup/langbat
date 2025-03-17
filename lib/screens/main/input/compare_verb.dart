import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomField {
  TextEditingController titleController;
  TextEditingController frontController;
  TextEditingController backController;

  CustomField({
    String title = "",
    String front = "",
    String back = "",
  })  : titleController = TextEditingController(text: title),
        frontController = TextEditingController(text: front),
        backController = TextEditingController(text: back);

  Map<String, String> toMap() {
    return {
      "title": titleController.text.trim(),
      "front": frontController.text.trim(),
      "back": backController.text.trim(),
    };
  }

  void dispose() {
    titleController.dispose();
    frontController.dispose();
    backController.dispose();
  }
}

class VerbDetailInputScreen extends StatefulWidget {
  final String text;     // 기존 동사 원형 (예: "hablar")
  final String meaning;  // 동사의 뜻 (예: "말하다")

  const VerbDetailInputScreen({
    Key? key,
    this.text = '',
    this.meaning = '',
  }) : super(key: key);

  @override
  _VerbDetailInputScreenState createState() => _VerbDetailInputScreenState();
}

class _VerbDetailInputScreenState extends State<VerbDetailInputScreen> {
  // 기본 필드 컨트롤러들
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

  // 동적 추가 필드 리스트
  List<CustomField> customFields = [];

  // 헬퍼 함수: 동사 변화 맵을 콤마로 구분된 문자열로 변환
  String _mapToCommaSeparatedString(Map<String, dynamic> conjugationMap) {
    final order = ["yo", "tú", "él/ella/Ud", "nosotros", "vosotros", "ellos/ellas/Uds"];
    return order.map((key) => conjugationMap[key] ?? "").join(', ');
  }

  // 콤마로 구분된 문자열을 리스트로 변환하는 함수
  List<String> _parseConjugation(String input) =>
      input.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  // 예문은 기존과 같이 여러 줄 입력받고 저장(현재는 단일 문자열)
  // 저장 시에는 그대로 저장하거나 나중에 원하는 대로 변경 가능

  Future<void> _loadVerbDetails() async {
    final doc = await FirebaseFirestore.instance.collection('verbs').doc(widget.text).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _verbController.text = data['text'] ?? widget.text;
        _meaningController.text = data['meaning'] ?? widget.meaning;
        _presentController.text = _mapToCommaSeparatedString(data['conjugations']?['present']?['forms'] ?? {});
        _preteriteController.text = _mapToCommaSeparatedString(data['conjugations']?['preterite']?['forms'] ?? {});
        _imperfectController.text = _mapToCommaSeparatedString(data['conjugations']?['imperfect']?['forms'] ?? {});
        _futureController.text = _mapToCommaSeparatedString(data['conjugations']?['future']?['forms'] ?? {});
        _subjunctiveController.text = _mapToCommaSeparatedString(data['conjugations']?['subjunctive']?['forms'] ?? {});
        _imperativeController.text = _mapToCommaSeparatedString(data['conjugations']?['imperative']?['forms'] ?? {});
        _beginnerExampleController.text = data['examples']?['beginner']?['text'] ?? "";
        _intermediateExampleController.text = data['examples']?['intermediate']?['text'] ?? "";
        _advancedExampleController.text = data['examples']?['advanced']?['text'] ?? "";

        // customFields 불러오기 (있다면)
        if (data.containsKey("customFields")) {
          List<dynamic> customList = data["customFields"];
          customFields = customList.map((cf) {
            return CustomField(
              title: cf["title"] ?? "",
              front: cf["front"] ?? "",
              back: cf["back"] ?? "",
            );
          }).toList();
        }
      });
    }
  }

  Future<void> _saveVerbDetails() async {
    final newText = _verbController.text.trim();
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
      "present": {
        "order": 0,
        "forms": buildConjugationMap(presentList),
      },
      "preterite": {
        "order": 1,
        "forms": buildConjugationMap(preteriteList),
      },
      "imperfect": {
        "order": 2,
        "forms": buildConjugationMap(imperfectList),
      },
      "future": {
        "order": 3,
        "forms": buildConjugationMap(futureList),
      },
      "subjunctive": {
        "order": 4,
        "forms": buildConjugationMap(subjunctiveList),
      },
      "imperative": {
        "order": 5,
        "forms": buildConjugationMap(imperativeList),
      },
    };

    // 예문 데이터는 단일 문자열로 저장 (원하는 경우 여러 줄의 예문을 하나로 저장)
    Map<String, dynamic> examples = {
      "beginner": {
        "order": 100,
        "text": _beginnerExampleController.text.trim(),
      },
      "intermediate": {
        "order": 200,
        "text": _intermediateExampleController.text.trim(),
      },
      "advanced": {
        "order": 300,
        "text": _advancedExampleController.text.trim(),
      },
    };

    // customFields 저장: 동적 추가 필드들
    List<Map<String, String>> customFieldData = customFields.map((cf) => cf.toMap()).toList();

    Map<String, dynamic> data = {
      "text": newText,
      "meaning": meaning,
      "conjugations": conjugations,
      "examples": examples,
      "customFields": customFieldData, // 추가된 동적 필드들
      "createdAt": FieldValue.serverTimestamp(),
    };

    try {
      if (newText != widget.text) {
        await FirebaseFirestore.instance.collection('verbs').doc(newText).set(data);
        await FirebaseFirestore.instance.collection('verbs').doc(widget.text).delete();
      } else {
        await FirebaseFirestore.instance.collection('verbs').doc(newText).set(data);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("동사 정보가 저장되었습니다.")),
      );
      await _loadVerbDetails();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("저장 실패: $e")),
      );
    }
  }

  // 동적 필드 추가 UI를 위한 위젯
  Widget _buildCustomFieldWidget(int index, CustomField cf) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("추가 필드 ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: cf.titleController,
              decoration: const InputDecoration(labelText: "필드 제목"),
            ),
            TextField(
              controller: cf.frontController,
              decoration: const InputDecoration(labelText: "카드 앞면"),
            ),
            TextField(
              controller: cf.backController,
              decoration: const InputDecoration(labelText: "카드 뒷면"),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    cf.dispose();
                    customFields.removeAt(index);
                  });
                },
                child: const Text("삭제", style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _verbController = TextEditingController(text: widget.text);
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
    for (var cf in customFields) {
      cf.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${_verbController.text} 동사 상세 정보"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: "저장",
            onPressed: _saveVerbDetails,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 기본 필드들
            TextField(
              controller: _verbController,
              decoration: const InputDecoration(
                labelText: '동사 원형 (예: hablar)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _meaningController,
              decoration: const InputDecoration(
                labelText: '뜻 (예: 말하다)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _presentController,
              decoration: const InputDecoration(
                labelText: '현재 시제 (예: hablo, hablas, habla, ...)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _preteriteController,
              decoration: const InputDecoration(
                labelText: '과거 시제 (예: hablé, hablaste, habló, ...)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _imperfectController,
              decoration: const InputDecoration(
                labelText: '불완료 시제 (예: hablaba, hablabas, ...)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _futureController,
              decoration: const InputDecoration(
                labelText: '미래 시제 (예: hablaré, hablarás, ...)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _subjunctiveController,
              decoration: const InputDecoration(
                labelText: '접속법 (예: hable, hables, ...)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _imperativeController,
              decoration: const InputDecoration(
                labelText: '명령법 (예: habla, hable, ...)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _beginnerExampleController,
              decoration: const InputDecoration(
                labelText: '초급 예문 (각 줄에 "예문 텍스트 - 예문 뜻" 입력)',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _intermediateExampleController,
              decoration: const InputDecoration(
                labelText: '중급 예문 (각 줄에 "예문 텍스트 - 예문 뜻" 입력)',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _advancedExampleController,
              decoration: const InputDecoration(
                labelText: '고급 예문 (각 줄에 "예문 텍스트 - 예문 뜻" 입력)',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 20),
            // 동적 추가 필드 섹션
            const Text("추가 필드", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Column(
              children: List.generate(customFields.length, (index) {
                return _buildCustomFieldWidget(index, customFields[index]);
              }),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  customFields.add(CustomField());
                });
              },
              icon: const Icon(Icons.add),
              label: const Text("필드 추가"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveVerbDetails,
              child: const Text("저장"),
            ),
          ],
        ),
      ),
    );
  }
}
