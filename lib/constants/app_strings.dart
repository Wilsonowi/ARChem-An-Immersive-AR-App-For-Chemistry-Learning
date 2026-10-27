class AppStrings {
  AppStrings._();

  static const String appName = 'ARChem';
  static const String appTagline = 'SPM Chemistry Learning';
  static const String appVersion = '2.0.0';

  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String email = 'Email Address';
  static const String password = 'Password';
  static const String confirmPwd = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String username = 'Username';
  static const String loginTitle = 'Welcome Back';
  static const String loginSub = 'Continue your chemistry journey';
  static const String registerTitle = 'Create Account';
  static const String registerSub = 'Start your SPM chemistry journey';

  // Errors
  static const String errorEmpty = 'This field cannot be empty';
  static const String errorEmail = 'Please enter a valid email address';
  static const String errorPwd = 'Password must be at least 6 characters';
  static const String errorPwdMatch = 'Passwords do not match';
  static const String errorUsername = 'Username must be at least 3 characters';
  static const String errorNoSpace = 'Username cannot contain spaces';
  static const String errorNetwork =
      'No internet connection. Please check your network.';
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorLogin = 'Invalid email or password.';
  static const String errorVerify =
      'Please verify your email before logging in.';

  // Verify
  static const String verifyTitle = 'Check Your Email';
  static const String verifyButton = 'Back to Login';

  // Onboarding
  static const List<Map<String, String>> onboardingPages = [
    {
      'title': 'Learn Chemistry in AR',
      'body':
          'Experience SPM Form 4 chemistry through augmented reality experiments that bring reactions to life.',
    },
    {
      'title': 'AI-Powered Learning',
      'body':
          'Get personalised quiz questions generated from your textbook, with instant AI hints when you need help.',
    },
    {
      'title': 'Your Personal Study Plan',
      'body':
          'Complete a diagnostic test and get a personalised daily study plan based on your strengths and weaknesses.',
    },
  ];

  // Diagnostic
  static const String diagnosticTitle = 'Diagnostic Test';
  static const String diagnosticBody =
      'Before we build your study plan, we need to understand your current level. This test covers all 8 chapters.';
  static const String diagnosticStart = 'Start Diagnostic Test';
  static const String diagnosticSkip = 'Skip for now';

  // Navigation
  static const String navHome = 'Home';
  static const String navChapters = 'Chapters';
  static const String navLab = 'Lab';
  static const String navProgress = 'Progress';
}
