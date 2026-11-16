class ProfessionalProfile {
  const ProfessionalProfile({
    this.name = '',
    this.profession = '',
    this.phone = '',
    this.pixKey = '',
  });

  final String name;
  final String profession;
  final String phone;
  final String pixKey;

  Map<String, String> toJson() => {
    'name': name,
    'profession': profession,
    'phone': phone,
    'pixKey': pixKey,
  };

  factory ProfessionalProfile.fromJson(Map<String, dynamic> json) =>
      ProfessionalProfile(
        name: json['name'] as String? ?? '',
        profession: json['profession'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        pixKey: json['pixKey'] as String? ?? '',
      );
}
