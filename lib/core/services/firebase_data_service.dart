import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hims/core/models/home_model.dart';
import 'package:hims/core/services/api_response.dart';
import 'package:uuid/uuid.dart';

class FirebaseDataService {
  static final FirebaseDataService _singleton = FirebaseDataService._internal();
  final uuid = Uuid();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseDataService._internal();

  factory FirebaseDataService() {
    return _singleton;
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getHomes({
    required String userId,
  }) async {
    try {
      final snapshot =
          await _firestore
              .collection("homes")
              .where("memberIds", arrayContains: userId)
              .get();

      if (snapshot.docs.isEmpty) {
        return ApiResponse(data: [], statusCode: 200);
      }

      // Преобразуем в список строк (например, по полю name)
      final homes = snapshot.docs.map((doc) => doc.data()).toList();

      return ApiResponse(data: homes, statusCode: 200);
    } on FirebaseException catch (e) {
      return ApiResponse(
        data: null,
        statusCode: 500,
        error: e.message ?? "Firestore error",
      );
    } catch (e) {
      return ApiResponse(data: null, statusCode: 500, error: e.toString());
    }
  }

  Future<ApiResponse<String>> addHome({
    required String name,
    required String userId,
  }) async {
    try {
      final newHome = Home(
        id: uuid.v4(),
        name: name,
        ownerId: userId,
        memberIds: [userId],
        createdAt: DateTime.now(),
      );
      print(newHome.toFirestore());

      await _firestore
          .collection("homes")
          .doc(newHome.id) // используем твой uuid как id документа
          .set(newHome.toFirestore());

      return ApiResponse(data: newHome.id, statusCode: 201);
    } on FirebaseException catch (e) {
      return ApiResponse(
        data: null,
        statusCode: 500,
        error: e.message ?? "Firestore error",
      );
    } catch (e) {
      return ApiResponse(data: null, statusCode: 500, error: e.toString());
    }
  }
}
