/// Mirrors the exact stage → grade mapping used by the web registration form
/// (resources/views/auth/student-register.blade.php `educationData`), so the
/// values sent to POST /api/auth/register/student match what the backend
/// expects (education_stage: secondary|preparatory, grade: grade_1|grade_2|grade_3).
class GradeOption {
  const GradeOption(this.value, this.label);
  final String value;
  final String label;
}

class EducationStage {
  const EducationStage(this.value, this.label, this.grades);
  final String value;
  final String label;
  final List<GradeOption> grades;
}

const educationStages = [
  EducationStage('preparatory', 'اعدادي / Preparatory', [
    GradeOption('grade_1', 'اولى اعدادي'),
    GradeOption('grade_2', 'تانية اعدادي'),
    GradeOption('grade_3', 'تالتة اعدادي'),
  ]),
  EducationStage('secondary', 'ثانوي / Secondary', [
    GradeOption('grade_1', 'اولى ثانوي'),
    GradeOption('grade_2', 'تانية ثانوي'),
    GradeOption('grade_3', 'تالتة ثانوي'),
  ]),
];
