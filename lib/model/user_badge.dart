class UserBadge {
  final String id;
  final String userId;
  final String badgeId;
  final String isPurchased;

  UserBadge({
    required this.id,
    required this.userId,
    required this.badgeId,
    required this.isPurchased,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      id: json['id'],
      userId: json['userId'],
      badgeId: json['badgeId'],
      isPurchased: json['isPurchased'],
    );
  }
}