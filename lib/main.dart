import 'package:bakeet/features/auth/screen/login_screen.dart';
import 'package:bakeet/features/home/cubit/home_cubit.dart';
import 'package:bakeet/features/home/screen/home_screen.dart';
import 'package:bakeet/features/home/screen/reels_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/constant/app_colors/app_colors.dart';
import 'core/classes/keys.dart';
import 'core/di/injection.dart';
import 'features/vendor managment/cubit/v_vendor_managment_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // initialize dependency injection (register cubits, repositories)
  await setUp();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<HomeCubit>()),
        BlocProvider(create: (_) => getIt<VVendorManagmentCubit>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            navigatorKey: Keys.navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Bakeet',
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: const LoginScreen(),
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                primary: AppColors.primary,
                secondary: AppColors.secondary,
              ),
              textTheme: GoogleFonts.cairoTextTheme(),
              fontFamily: GoogleFonts.cairo().fontFamily,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                ),
              ),
              // card theme defaults will be used; cards created in screens will use custom shapes
            ),
          );
        },
      ),
    );
  }
}

/// MainShell hosts the bottom navigation and two pages (Home, Second)
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onTap(int index) {
    setState(() => _currentIndex = index);
  }

  void _goToHome() {
    setState(() => _currentIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    // Create pages list here to pass the callback
    final List<Widget> pages = <Widget>[
      const HomeScreen(),
      ReelsScreen(onBack: _goToHome),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      extendBody: true,
      bottomNavigationBar: _currentIndex == 1
          ? null // Hide bottom nav when on ReelsScreen
          : Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: _onTap,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  selectedItemColor: AppColors.primary,
                  unselectedItemColor: AppColors.neutral600,
                  selectedFontSize: 12,
                  unselectedFontSize: 11,
                  elevation: 0,
                  selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  items: [
                    BottomNavigationBarItem(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: _currentIndex == 0
                            ? BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.1),
                                    AppColors.secondary.withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              )
                            : null,
                        child: Icon(
                          _currentIndex == 0 ? Icons.home : Icons.home_outlined,
                          size: 26,
                        ),
                      ),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: _currentIndex == 1
                            ? BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.1),
                                    AppColors.secondary.withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              )
                            : null,
                        child: Icon(
                          _currentIndex == 1
                              ? Icons.play_circle
                              : Icons.play_circle_outline,
                          size: 26,
                        ),
                      ),
                      label: 'Reels',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
