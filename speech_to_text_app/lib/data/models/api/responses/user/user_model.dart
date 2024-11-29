import 'dart:convert';

class UserModel {
  final String name;
  final String email;
  final String id;
  final String token;
  final bool isPremium;
  final int maxAudioFiles;
  final int maxTotalAudioTime;
  final int totalAudioTime;

  UserModel({
    required this.name,
    required this.email,
    required this.id,
    required this.token,
    required this.isPremium,
    required this.maxAudioFiles,
    required this.maxTotalAudioTime,
    required this.totalAudioTime,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? id,
    String? token,
    bool? isPremium,
    int? maxAudioFiles,
    int? maxTotalAudioTime,
    int? totalAudioTime,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      id: id ?? this.id,
      token: token ?? this.token,
      isPremium: isPremium ?? this.isPremium,
      maxAudioFiles: maxAudioFiles ?? this.maxAudioFiles,
      maxTotalAudioTime: maxTotalAudioTime ?? this.maxTotalAudioTime,
      totalAudioTime: totalAudioTime ?? this.totalAudioTime,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'id': id,
      'token': token,
      'isPremium': isPremium,
      'maxAudioFiles': maxAudioFiles,
      'maxTotalAudioTime': maxTotalAudioTime,
      'totalAudioTime': totalAudioTime,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      id: map['id'] ?? '',
      token: map['token'] ?? '',
      isPremium: map['is_premium'] ?? false,
      maxAudioFiles: map['max_audio_files'] ?? 10,
      maxTotalAudioTime: map['max_total_audio_time'] ?? 18000,
      totalAudioTime: map['total_audio_time'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, id: $id, token: $token, isPremium: $isPremium, maxAudioFiles: $maxAudioFiles, maxTotalAudioTime: $maxTotalAudioTime, totalAudioTime: $totalAudioTime)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.email == email &&
        other.id == id &&
        other.token == token &&
        other.isPremium == isPremium &&
        other.maxAudioFiles == maxAudioFiles &&
        other.maxTotalAudioTime == maxTotalAudioTime &&
        other.totalAudioTime == totalAudioTime;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        email.hashCode ^
        id.hashCode ^
        token.hashCode ^
        isPremium.hashCode ^
        maxAudioFiles.hashCode ^
        maxTotalAudioTime.hashCode ^
        totalAudioTime.hashCode;
  }
}
