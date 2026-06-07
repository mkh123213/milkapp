import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/asset_paths.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';
import '../widgets/auth_error_banner.dart';

class LoginBody extends StatefulWidget {
  const LoginBody({super.key});

  @override
  State<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: BlocBuilder<LoginCubit, LoginState>(
            builder: (context, state) {
              final isLoading = state is LoginLoading;
              return Column(
                children: [
                  const SizedBox(height: 32),
                  Image.asset(AssetPaths.logo, width: 120, height: 120),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      children: [
                        TextSpan(text: '${'auth_welcome'.tr()} '),
                        TextSpan(text: 'app_title'.tr(), style: const TextStyle(color: AppColors.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('auth_sign_in_subtitle'.tr(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.g_mobiledata, size: 24),
                      label: Text('auth_continue_google'.tr(), style: const TextStyle(fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        backgroundColor: AppColors.primary.withValues(alpha: 0.05),
                        foregroundColor: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('auth_or'.tr(), style: const TextStyle(color: AppColors.textHint, fontSize: 12))),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state is LoginError) AuthErrorBanner(errorKey: state.errorKey),
                  Align(alignment: Alignment.centerRight, child: Text('auth_email_label'.tr(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailCtrl,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    textDirection: TextDirection.ltr,
                    decoration: _inputDecoration('auth_email_hint'.tr(), Icons.mail_outline),
                  ),
                  const SizedBox(height: 16),
                  Align(alignment: Alignment.centerRight, child: Text('auth_password_label'.tr(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    textDirection: TextDirection.ltr,
                    textInputAction: TextInputAction.done,
                    decoration: _inputDecoration('auth_password_hint'.tr(), Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('auth_sign_in'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: Text('auth_forgot_password'.tr(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${'auth_need_account'.tr()} ', style: const TextStyle(color: AppColors.textSecondary)),
                      TextButton(
                        onPressed: () => context.push('/signup'),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        child: Text('auth_sign_up'.tr(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
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

  void _submit() =>
      context.read<LoginCubit>().login(_emailCtrl.text, _passCtrl.text);

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
