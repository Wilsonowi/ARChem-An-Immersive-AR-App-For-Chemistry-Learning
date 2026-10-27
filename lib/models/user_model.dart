class UserModel {
  final String id;
  final String username;
  final String fullName;
  final String? avatarUrl;
  final bool hasCompletedDiagnostic;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    this.avatarUrl,
    this.hasCompletedDiagnostic = false,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      hasCompletedDiagnostic:
          json['has_completed_diagnostic'] as bool? ?? false,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'has_completed_diagnostic': hasCompletedDiagnostic,
    'created_at': createdAt.toIso8601String(),
  };

  UserModel copyWith({
    String? username,
    String? fullName,
    String? avatarUrl,
    bool? hasCompletedDiagnostic,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hasCompletedDiagnostic:
          hasCompletedDiagnostic ?? this.hasCompletedDiagnostic,
      createdAt: createdAt,
    );
  }

  /// Initials for avatar placeholder
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (fullName.isNotEmpty) return fullName[0].toUpperCase();
    return username.isNotEmpty ? username[0].toUpperCase() : 'A';
  }
}
