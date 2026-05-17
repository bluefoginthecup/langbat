import 'package:langbat/src/repos/study_repository.dart';

class PointService {
  static final StudyRepository _studyRepository = StudyRepository();

  static Future<void> addPoint({
    required int amount,
    required String type,
    required String description,
  }) {
    return _studyRepository.addPointLog(
      amount: amount,
      type: type,
      description: description,
    );
  }

  static Future<int> totalPoints() {
    return _studyRepository.totalPoints();
  }
}
