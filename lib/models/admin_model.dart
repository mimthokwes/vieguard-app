class Admin {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? profilePhoto;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.profilePhoto,
  });

  Admin copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? profilePhoto,
  }) =>
      Admin(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        profilePhoto: profilePhoto ?? this.profilePhoto,
      );

  factory Admin.fromJson(Map<String, dynamic> json) => Admin(
        id: json['id'].toString(),
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        role: json['role'] as String,
        profilePhoto: json['profilePhoto'] as String? ?? json['profile_photo'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'profilePhoto': profilePhoto,
      };
}
