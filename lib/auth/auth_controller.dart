import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';

// ── AUTH STATE ────────────────────────────────────────────

class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final UserModel? user;
  final String? errorMessage;
  final bool needsVerification;
  final String? verificationEmail;

  const AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.user = null,
    this.errorMessage = null,
    this.needsVerification = false,
    this.verificationEmail = null,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    UserModel? user,
    String? errorMessage,
    bool? needsVerification,
    String? verificationEmail,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      needsVerification: needsVerification ?? this.needsVerification,
      verificationEmail: verificationEmail ?? this.verificationEmail,
    );
  }
}

// ── AUTH CONTROLLER ───────────────────────────────────────

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState()) {
    _init();
  }

  final _service = SupabaseService.instance;

  // ── INIT — check existing session ─────────────────────
  Future<void> _init() async {
    state = state.copyWith(isLoading: true);

    final user = _service.currentUser;
    if (user != null) {
      final profile = await _service.fetchProfile();
      state = state.copyWith(isLoading: false, isLoggedIn: true, user: profile);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  // ── SIGN IN ───────────────────────────────────────────
  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _service.signIn(
        email: email.trim(),
        password: password.trim(),
      );

      if (response.user == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Login failed. Please try again.',
        );
        return false;
      }

      // Fetch profile in background — navigate immediately
      final profile = await _service.fetchProfile();
      state = state.copyWith(isLoading: false, isLoggedIn: true, user: profile);
      return true;
    } on AuthException catch (e) {
      String msg = e.message;
      if (msg.toLowerCase().contains('email'))
        msg = 'Please verify your email before logging in.';
      else if (msg.toLowerCase().contains('invalid'))
        msg = 'Invalid email or password.';

      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No internet connection. Please check your network.',
      );
      return false;
    }
  }

  // ── SIGN UP ───────────────────────────────────────────
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _service.signUp(
        email: email.trim(),
        password: password.trim(),
        username: username.trim(),
        fullName: fullName.trim(),
      );

      if (response.user == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Registration failed. Please try again.',
        );
        return false;
      }

      // Check if user is immediately logged in (email verification OFF)
      if (response.session != null) {
        final profile = await _service.fetchProfile();
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: true,
          user: profile,
        );
      } else {
        // Email verification required
        state = state.copyWith(
          isLoading: false,
          needsVerification: true,
          verificationEmail: email.trim(),
        );
      }
      return true;
    } on AuthException catch (e) {
      String msg = e.message;
      if (msg.toLowerCase().contains('already registered'))
        msg = 'An account with this email already exists.';

      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No internet connection. Please check your network.',
      );
      return false;
    }
  }

  // ── SIGN OUT ──────────────────────────────────────────
  Future<void> signOut() async {
    await _service.signOut();
    state = const AuthState();
  }

  // ── CLEAR ERROR ───────────────────────────────────────
  void clearError() => state = state.copyWith(clearError: true);

  // ── REFRESH PROFILE ───────────────────────────────────
  Future<void> refreshProfile() async {
    final profile = await _service.fetchProfile();
    if (profile != null) state = state.copyWith(user: profile);
  }

  // ── RESET VERIFICATION STATE ──────────────────────────
  void updateCachedProfile(UserModel user) {
    state = state.copyWith(isLoggedIn: true, user: user);
  }

  void resetVerification() {
    state = state.copyWith(needsVerification: false, verificationEmail: null);
  }
}

// ── PROVIDERS ─────────────────────────────────────────────

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(),
);

final isLoggedInProvider = Provider<bool>(
  (ref) => ref.watch(authControllerProvider).isLoggedIn,
);

final currentUserProvider = Provider<UserModel?>(
  (ref) => ref.watch(authControllerProvider).user,
);
