import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/asset_paths.dart';
import '../cubit/signup_cubit.dart';
import '../cubit/signup_state.dart';
import '../widgets/auth_error_banner.dart';

class SignupBody extends StatefulWidget {
  const SignupBody({super.key});

  @override
  State<SignupBody> createState() => _SignupBodyState();
}

class _SignupBodyState extends State<SignupBody> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: BlocConsumer<SignupCubit, SignupState>(
            listener: (context, state) {
              if (state is SignupSuccess) context.go('/dashboard');
            },
            builder: (context, state) {
              final isLoading = state is SignupLoading;
              return Column(
                children: [
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.chevron_right, size: 20),
                      label: Text('auth_back_to_signin'.tr()),
                      style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Image.asset(AssetPaths.logo, width: 110, height: 110),
                  const SizedBox(height: 16),
                  Text('auth_create_account'.tr(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  if (state is SignupError) AuthErrorBanner(errorKey: state.errorKey),
                  Align(alignment: Alignment.centerRight, child: Text('auth_email_label'.tr(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                  const SizedBox(height: 6),
                  TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, textDirection: TextDirection.ltr, decoration: _inputDecoration('auth_email_hint'.tr(), Icons.mail_outline)),
                  const SizedBox(height: 16),
                  Align(alignment: Alignment.centerRight, child: Text('auth_password_label'.tr(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscurePass,
                    textDirection: TextDirection.ltr,
                    decoration: _inputDecoration('auth_password_hint'.tr(), Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20), onPressed: () => setState(() => _obscurePass = !_obscurePass)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(alignment: Alignment.centerRight, child: Text('auth_confirm_password'.tr(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    textDirection: TextDirection.ltr,
                    decoration: _inputDecoration('auth_re_enter_password'.tr(), Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20), onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm)),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('auth_create_account_btn'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _submit() => context.read<SignupCubit>().signup(_emailCtrl.text, _passCtrl.text, _confirmCtrl.text);

  InputDecoration _inputDecoration(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );
}
