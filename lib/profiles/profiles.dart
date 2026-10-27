import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../auth/auth_controller.dart';
import '../home/home_controller.dart';
import '../services/supabase_service.dart';
import '../widgets/chemistry_background.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _picker = ImagePicker();
  String? _localAvatarPath;
  bool _isSavingProfile = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLocalAvatar();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadLocalAvatar() async {
    final uid = SupabaseService.instance.userId;
    if (uid == null) return;

    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_avatarPrefsKey(uid));
    if (!mounted) return;
    if (path != null && File(path).existsSync()) {
      setState(() => _localAvatarPath = path);
    } else if (_localAvatarPath != null) {
      setState(() => _localAvatarPath = null);
    }
  }

  Future<void> _pickLocalAvatar() async {
    final uid = SupabaseService.instance.userId;
    if (uid == null) return;

    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 900,
    );
    if (image == null) return;

    final localPath = await _saveAvatarLocally(uid: uid, pickedPath: image.path);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarPrefsKey(uid), localPath);
    if (!mounted) return;
    setState(() => _localAvatarPath = localPath);
  }

  Future<String> _saveAvatarLocally({
    required String uid,
    required String pickedPath,
  }) async {
    final source = File(pickedPath);
    final directory = await getApplicationDocumentsDirectory();
    final avatarDirectory = Directory('${directory.path}/profile_avatars');
    if (!avatarDirectory.existsSync()) {
      avatarDirectory.createSync(recursive: true);
    }

    final extension = pickedPath.split('.').last.toLowerCase();
    final safeExtension = extension.length <= 5 ? extension : 'jpg';
    final destinationPath =
        '${avatarDirectory.path}/$uid-${DateTime.now().millisecondsSinceEpoch}.$safeExtension';
    final saved = await source.copy(destinationPath);
    return saved.path;
  }

  Future<void> _editProfile() async {
    final user = ref.read(currentUserProvider);
    if (user == null || _isSavingProfile) return;

    final result = await showDialog<_ProfileEditResult>(
      context: context,
      builder: (_) => _ProfileEditDialog(
        fullName: user.fullName,
        username: user.username,
      ),
    );
    if (result == null) return;

    setState(() => _isSavingProfile = true);
    try {
      await SupabaseService.instance.updateProfile(
        fullName: result.fullName,
        username: result.username,
      );
      ref.read(authControllerProvider.notifier).updateCachedProfile(
            user.copyWith(
              fullName: result.fullName,
              username: result.username,
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update profile. $e')),
      );
    } finally {
      if (mounted) setState(() => _isSavingProfile = false);
    }
  }

  String _avatarPrefsKey(String uid) => 'local_avatar_path_$uid';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final state = ref.watch(homeControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text('Profile', style: AppTextStyles.headingMedium),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () {
            if (context.canPop())
              context.pop();
            else
              context.go('/home');
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            onPressed: _isSavingProfile ? null : _editProfile,
            icon: _isSavingProfile
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    Icons.edit_rounded,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
          ),
        ],
      ),
      body: ChemistryBackground(
        // Purple theme, matching the rest of the app.
        gradientCenter: Colors.white,
        gradientEdge: AppColors.lilacGlow,
        gridColor: AppColors.indigo,
        accentColor: AppColors.indigo,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
            const SizedBox(height: 32),

            // ── AVATAR ────────────────────────────────────
            _EditableAvatar(
              initials: user?.initials ?? 'A',
              localPath: _localAvatarPath,
              onTap: _pickLocalAvatar,
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

            const SizedBox(height: 16),

            // ── NAME ──────────────────────────────────────
            Text(
              user?.fullName ?? 'Student',
              style: AppTextStyles.headingLarge,
            ).animate(delay: 100.ms).fadeIn(),

            const SizedBox(height: 4),

            Text(
              '@${user?.username ?? ''}',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.indigo),
            ).animate(delay: 150.ms).fadeIn(),

            const SizedBox(height: 8),

            // Joined date
            if (user?.createdAt != null)
              Text(
                'Joined ${_formatDate(user!.createdAt)}',
                style: AppTextStyles.bodySmall,
              ).animate(delay: 200.ms).fadeIn(),

            const SizedBox(height: 32),

            // ── STATS ─────────────────────────────────────
            _StatsGrid(state: state).animate(delay: 250.ms).fadeIn(),

            const SizedBox(height: 28),

            // ── INFO CARD ─────────────────────────────────
            _InfoCard(
              label: 'Full Name',
              value: user?.fullName ?? '-',
            ).animate(delay: 300.ms).fadeIn(),

            const SizedBox(height: 10),

            _InfoCard(
              label: 'Username',
              value: '@${user?.username ?? '-'}',
            ).animate(delay: 330.ms).fadeIn(),

            const SizedBox(height: 10),

            _InfoCard(
              label: 'Diagnostic Test',
              value: user?.hasCompletedDiagnostic == true
                  ? '✓ Completed'
                  : 'Not completed',
              valueColor: user?.hasCompletedDiagnostic == true
                  ? AppColors.green
                  : AppColors.amber,
            ).animate(delay: 360.ms).fadeIn(),

            const SizedBox(height: 10),

            _HistoryLink(
              onTap: () => context.push('/quiz-history'),
            ).animate(delay: 390.ms).fadeIn(),

            const SizedBox(height: 32),

            // ── LOGOUT BUTTON ─────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.red,
                  size: 18,
                ),
                label: Text(
                  'Logout',
                  style: AppTextStyles.buttonOutline.copyWith(
                    color: AppColors.red,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ).animate(delay: 400.ms).fadeIn(),

            const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}

// ── STATS GRID ────────────────────────────────────────────
class _EditableAvatar extends StatelessWidget {
  final String initials;
  final String? localPath;
  final VoidCallback onTap;

  const _EditableAvatar({
    required this.initials,
    required this.localPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageFile = localPath == null ? null : File(localPath!);
    final hasImage = imageFile != null && imageFile.existsSync();

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: AppColors.indigoDim,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.indigo.withOpacity(0.3),
                width: 2,
              ),
              image: hasImage
                  ? DecorationImage(
                      image: FileImage(imageFile!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasImage
                ? null
                : Center(
                    child: Text(
                      initials,
                      style: AppTextStyles.displayMedium.copyWith(
                        color: AppColors.indigo,
                      ),
                    ),
                  ),
          ),
          Positioned(
            right: -2,
            bottom: 2,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.indigo,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileEditResult {
  final String fullName;
  final String username;

  const _ProfileEditResult({
    required this.fullName,
    required this.username,
  });
}

class _ProfileEditDialog extends StatefulWidget {
  final String fullName;
  final String username;

  const _ProfileEditDialog({
    required this.fullName,
    required this.username,
  });

  @override
  State<_ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<_ProfileEditDialog> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.fullName);
    _usernameController = TextEditingController(text: widget.username);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Profile', style: AppTextStyles.headingMedium),
            const SizedBox(height: 16),
            TextField(
              controller: _fullNameController,
              textInputAction: TextInputAction.next,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _usernameController,
              textInputAction: TextInputAction.done,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final fullName = _fullNameController.text.trim();
    final username = _usernameController.text.trim();
    if (fullName.isEmpty || username.isEmpty) return;

    Navigator.of(context).pop(
      _ProfileEditResult(fullName: fullName, username: username),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final HomeState state;
  const _StatsGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.0,
      children: [
        _GridStat(
          icon: Icons.menu_book_rounded,
          color: AppColors.indigo,
          value: '${state.completedChapters}',
          label: 'Chapters Done',
        ),
        _GridStat(
          icon: Icons.science_rounded,
          color: AppColors.green,
          value:
              '${state.chapterProgress.where((p) => p.experimentDone).length}',
          label: 'Labs Done',
        ),
        _GridStat(
          icon: Icons.quiz_rounded,
          color: AppColors.amber,
          value:
              '${state.chapterProgress.where((p) => p.quizScore > 0).length}',
          label: 'Quizzes Taken',
        ),
        _GridStat(
          icon: Icons.trending_up_rounded,
          color: AppColors.chapter7,
          value: '${(state.overallPercent * 100).toInt()}%',
          label: 'Overall',
        ),
      ],
    );
  }
}

class _GridStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _GridStat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: AppTextStyles.headingMedium.copyWith(color: color),
              ),
              Text(label, style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

// ── HISTORY LINK ──────────────────────────────────────────
class _HistoryLink extends StatelessWidget {
  final VoidCallback onTap;
  const _HistoryLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.history_rounded, color: AppColors.indigo, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Quiz History',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
          ],
        ),
      ),
    );
  }
}

// ── INFO CARD ─────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoCard({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
