import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Home extends Equatable {
  final String id;
  final String name;
  final String ownerId;
  final List<String> memberIds;
  final DateTime createdAt;

  const Home({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.memberIds,
    required this.createdAt,
  });

  // Фабричный конструктор для создания объекта Home из документа Firestore
  factory Home.fromFirestore(Map<String, dynamic> data) {
    return Home(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      ownerId: data['ownerId'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      createdAt: data['createdAt'].toDate(),
    );
  }

  // Метод для преобразования объекта Home в формат, пригодный для сохранения в Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  List<Object?> get props => [id, name, ownerId, memberIds, createdAt];
}
