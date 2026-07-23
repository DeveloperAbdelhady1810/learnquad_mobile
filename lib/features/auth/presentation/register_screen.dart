import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/labeled_field.dart';
import '../application/auth_controller.dart';
import '../data/education_options.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _stage;
  String? _grade;
  String? _gender;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  List<GradeOption> get _gradesForStage {
    if (_stage == null) return const [];
    return educationStages.firstWhere((s) => s.value == _stage).grades;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_stage == null || _grade == null || _gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('من فضلك أكمل كل الحقول.')),
      );
      return;
    }
    FocusScope.of(context).unfocus();

    await ref
        .read(authControllerProvider.notifier)
        .registerStudent(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          educationStage: _stage!,
          grade: _grade!,
          gender: _gender!,
          age: int.parse(_ageController.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (authState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      authState.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                LabeledField(
                  label: 'الاسم بالكامل',
                  child: TextFormField(
                    controller: _nameController,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(hintText: 'مريم أحمد سيد'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                  ),
                ),
                const SizedBox(height: 14),
                LabeledField(
                  label: 'البريد الإلكتروني',
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      hintText: 'mariam.sayed@gmail.com',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'مطلوب';
                      if (!v.contains('@')) return 'أدخل بريدًا صحيحًا';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 14),
                LabeledField(
                  label: 'رقم الموبايل',
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(hintText: '01012345678'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                  ),
                ),
                const SizedBox(height: 14),
                LabeledField(
                  label: 'كلمة السر',
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 8) return 'ثمانية أحرف على الأقل';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 14),
                LabeledField(
                  label: 'تأكيد كلمة السر',
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscurePassword,
                    textAlign: TextAlign.right,
                    validator: (v) {
                      if (v != _passwordController.text) {
                        return 'كلمتا السر غير متطابقتين';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                LabeledField(
                  label: 'المرحلة الدراسية',
                  child: _StageSegment(
                    value: _stage,
                    onChanged: (value) => setState(() {
                      _stage = value;
                      _grade = null;
                    }),
                  ),
                ),
                if (_stage != null) ...[
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'الصف الدراسي',
                    child: DropdownButtonFormField<String>(
                      initialValue: _grade,
                      items: _gradesForStage
                          .map(
                            (g) => DropdownMenuItem(
                              value: g.value,
                              alignment: AlignmentDirectional.centerEnd,
                              child: Text(g.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _grade = value),
                      validator: (v) => v == null ? 'مطلوب' : null,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                LabeledField(
                  label: 'النوع',
                  child: Row(
                    children: [
                      Expanded(
                        child: _GenderRadio(
                          label: 'ذكر',
                          selected: _gender == 'male',
                          onTap: () => setState(() => _gender = 'male'),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _GenderRadio(
                          label: 'أنثى',
                          selected: _gender == 'female',
                          onTap: () => setState(() => _gender = 'female'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: 120,
                  child: LabeledField(
                    label: 'السن',
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      validator: (v) {
                        final age = int.tryParse(v ?? '');
                        if (age == null) return 'مطلوب';
                        if (age < 10 || age > 25) return '١٠-٢٥';
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _submit,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('إنشاء الحساب'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('عندك حساب بالفعل؟ سجّل دخولك'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Matches the `.seg` two-option segmented control in the mockup.
class _StageSegment extends StatelessWidget {
  const _StageSegment({required this.value, required this.onChanged});
  final String? value;
  final void Function(String value) onChanged;

  @override
  Widget build(BuildContext context) {
    final divider = Theme.of(context).dividerColor;
    return Container(
      decoration: BoxDecoration(border: Border.all(color: divider)),
      child: Row(
        children: educationStages.asMap().entries.map((entry) {
          final index = entry.key;
          final stage = entry.value;
          final selected = value == stage.value;
          final label = stage.label.split(' / ').first;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(stage.value),
              child: Container(
                decoration: BoxDecoration(
                  color: selected ? AppColors.accent : null,
                  border: index == 0
                      ? Border(right: BorderSide(color: divider))
                      : null,
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: selected ? Colors.white : null,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Matches the `.radio` component — a custom dot rather than the platform
/// radio button, so it stays square-cornered-consistent with the rest of the
/// system (the dot itself is the one deliberately circular exception, same
/// as the mockup).
class _GenderRadio extends StatelessWidget {
  const _GenderRadio({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final divider = Theme.of(context).dividerColor;
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.accent : divider,
                width: 1.5,
              ),
              color: selected ? AppColors.accent : Colors.transparent,
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
