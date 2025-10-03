import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hims/core/models/home_model.dart';

/// Кастомня модель пользователя для приложения HIMS
class HimsUser extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  Home? home;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final String authProvider; // 'google', 'email', etc.

  HimsUser({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.home,
    this.createdAt,
    this.lastLoginAt,
    required this.authProvider,
  });

  /// Создание пользователя из Firebase User
  factory HimsUser.fromFirebaseUser({
    required String id,
    required String email,
    required String name,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    required String authProvider,
  }) {
    return HimsUser(
      id: id,
      email: email,
      name: name,
      photoUrl: photoUrl,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      authProvider: authProvider,
    );
  }

  /// Создание пользователя из Firestore документа
  factory HimsUser.fromFirestore(Map<String, dynamic> data, String id) {
    return HimsUser(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
      createdAt: data['createdAt']?.toDate(),
      lastLoginAt: data['lastLoginAt']?.toDate(),
      authProvider: data['authProvider'] ?? 'unknown',
    );
  }

  HimsUser setHome(Home home) {
    this.home = home;
    return this;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl ?? '',
      'createdAt':
          createdAt == null
              ? FieldValue.serverTimestamp()
              : (createdAt is DateTime
                  ? Timestamp.fromDate(createdAt!)
                  : createdAt),
      'lastLoginAt':
          lastLoginAt == null
              ? FieldValue.serverTimestamp()
              : (lastLoginAt is DateTime
                  ? Timestamp.fromDate(lastLoginAt!)
                  : lastLoginAt),
      'authProvider': authProvider,
    };
  }

  /// Копирование с изменениями
  HimsUser copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    List<String>? homeIds,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? authProvider,
  }) {
    return HimsUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      authProvider: authProvider ?? this.authProvider,
    );
  }

  /// Обновление времени последнего входа
  HimsUser updateLastLogin() {
    return copyWith(lastLoginAt: DateTime.now());
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    photoUrl,
    home,
    createdAt,
    lastLoginAt,
    authProvider,
  ];

  @override
  String toString() {
    return 'HimsUser(id: $id, email: $email, name: $name, authProvider: $authProvider)';
  }
}
