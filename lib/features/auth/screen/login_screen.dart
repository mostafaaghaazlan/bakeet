import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bakeet/core/constant/app_colors/app_colors.dart';
import 'package:bakeet/core/constant/text_styles/app_text_style.dart';
import 'package:bakeet/core/ui/widgets/custom_text_form_field.dart';
import 'package:bakeet/core/ui/widgets/custom_button.dart';
import 'package:bakeet/features/auth/cubit/auth_cubit.dart';
import 'package:bakeet/features/home/screen/home_screen.dart';
import 'package:bakeet/features/vendor managment/screen/vendor_registration_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: const _LoginScreenContent(),
    );
  }
}

class _LoginScreenContent extends StatefulWidget {
  const _LoginScreenContent();

  @override
  State<_LoginScreenContent> createState() => _LoginScreenContentState();
}

class _LoginScreenContentState extends State<_LoginScreenContent>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      context.read<AuthCubit>().login(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoginSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تسجيل الدخول بنجاح: ${state.email}'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

          // Navigate based on user type
          if (state.isMerchant) {
            // Navigate to VendorRegistrationScreen for merchants
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const VendorRegistrationScreen(),
              ),
            );
          } else {
            // Navigate to HomeScreen for regular users
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              ),
            );
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary600,
                AppColors.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 20.h,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildLoginCard(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 440.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(32.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 40,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.r),
        child: Container(
          padding: EdgeInsets.all(32.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                SizedBox(height: 40.h),
                _buildEmailField(),
                SizedBox(height: 20.h),
                _buildPasswordField(),
                SizedBox(height: 16.h),
                _buildRememberAndForgot(),
                SizedBox(height: 32.h),
                _buildLoginButton(),
                SizedBox(height: 24.h),
                _buildDivider(),
                SizedBox(height: 24.h),
                _buildSocialButtons(),
                SizedBox(height: 28.h),
                _buildSignUpLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.lock_rounded,
            color: Colors.white,
            size: 40.sp,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          'مرحباً بك',
          style: AppTextStyle.getBoldStyle(
            color: AppColors.black1c,
            fontSize: 32.sp,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          'قم بتسجيل الدخول للمتابعة',
          style: AppTextStyle.getMediumStyle(
            color: AppColors.grey72,
            fontSize: 16.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return CustomTextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      hintText: 'البريد الإلكتروني',
      prefixIcon: Padding(
        padding: EdgeInsets.all(14.w),
        child: Icon(
          Icons.email_outlined,
          color: AppColors.primary,
          size: 22.sp,
        ),
      ),
      borderColor: AppColors.greyDD,
      focusedColor: AppColors.primary,
      borderRadius: 16.r,
      fillColor: AppColors.neutral25,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال البريد الإلكتروني';
        }
        if (!value.contains('@')) {
          return 'الرجاء إدخال بريد إلكتروني صحيح';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) =>
          current is AuthPasswordVisibilityChanged ||
          current is AuthInitial,
      builder: (context, state) {
        final cubit = context.read<AuthCubit>();
        return CustomTextFormField(
          controller: _passwordController,
          isObscure: cubit.isObscure,
          hintText: 'كلمة المرور',
          prefixIcon: Padding(
            padding: EdgeInsets.all(14.w),
            child: Icon(
              Icons.lock_outline_rounded,
              color: AppColors.primary,
              size: 22.sp,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              cubit.isObscure
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppColors.grey72,
              size: 22.sp,
            ),
            onPressed: () => cubit.togglePasswordVisibility(),
          ),
          borderColor: AppColors.greyDD,
          focusedColor: AppColors.primary,
          borderRadius: 16.r,
          fillColor: AppColors.neutral25,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال كلمة المرور';
            }
            if (value.length < 6) {
              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildRememberAndForgot() {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) =>
          current is AuthRememberMeChanged || current is AuthInitial,
      builder: (context, state) {
        final cubit = context.read<AuthCubit>();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: Checkbox(
                    value: cubit.rememberMe,
                    onChanged: (v) => cubit.toggleRememberMe(v ?? false),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'تذكرني',
                  style: AppTextStyle.getMediumStyle(
                    color: AppColors.black28,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to forgot password
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'نسيت كلمة المرور؟',
                style: AppTextStyle.getSemiBoldStyle(
                  color: AppColors.primary,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoginButton() {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) =>
          current is AuthLoading ||
          current is AuthLoginSuccess ||
          current is AuthError ||
          current is AuthInitial,
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return CustomButton(
          text: isLoading ? 'جاري التحميل...' : 'تسجيل الدخول',
          h: 56.h,
          radius: 16.r,
          color: AppColors.primary,
          textStyle: AppTextStyle.getBoldStyle(
            color: Colors.white,
            fontSize: 18.sp,
          ),
          isEnabled: !isLoading,
          rowChild: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'جاري التحميل...',
                      style: AppTextStyle.getBoldStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                      ),
                    ),
                  ],
                )
              : null,
          onPressed: () => _submit(context),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.greyDD,
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'أو تسجيل الدخول عبر',
            style: AppTextStyle.getMediumStyle(
              color: AppColors.grey72,
              fontSize: 14.sp,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.greyDD,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _SocialButton(
          icon: Icons.g_mobiledata_rounded,
          color: const Color(0xFFDB4437),
          onTap: () {},
        ),
        _SocialButton(
          icon: Icons.apple_rounded,
          color: Colors.black,
          onTap: () {},
        ),
        _SocialButton(
          icon: Icons.facebook_rounded,
          color: const Color(0xFF1877F2),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSignUpLink() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'ليس لديك حساب؟ ',
          style: AppTextStyle.getMediumStyle(
            color: AppColors.black28,
            fontSize: 15.sp,
          ),
          children: [
            TextSpan(
              text: 'إنشاء حساب',
              style: AppTextStyle.getBoldStyle(
                color: AppColors.primary,
                fontSize: 15.sp,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  // Navigate to register
                },
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 64.w,
        height: 64.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.greyDD,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: color,
            size: 28.sp,
          ),
        ),
      ),
    );
  }
}
