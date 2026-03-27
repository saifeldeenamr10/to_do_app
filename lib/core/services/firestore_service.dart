import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/helper/app_logger.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a document to a collection
  Future<DocumentReference> addDocument({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    try {
      return await _db.collection(collection).add(data);
    } catch (e) {
      AppLogger.red('FirestoreService - addDocument Error: $e');
      rethrow;
    }
  }

  // Set a document with a specific ID
  Future<void> setDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db.collection(collection).doc(docId).set(data);
    } catch (e) {
      AppLogger.red('FirestoreService - setDocument Error: $e');
      rethrow;
    }
  }

  // Update a document
  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db.collection(collection).doc(docId).update(data);
    } catch (e) {
      AppLogger.red('FirestoreService - updateDocument Error: $e');
      rethrow;
    }
  }

  // Delete a document
  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      await _db.collection(collection).doc(docId).delete();
    } catch (e) {
      AppLogger.red('FirestoreService - deleteDocument Error: $e');
      rethrow;
    }
  }

  // Get a specific document
  Future<DocumentSnapshot> getDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      return await _db.collection(collection).doc(docId).get();
    } catch (e) {
      AppLogger.red('FirestoreService - getDocument Error: $e');
      rethrow;
    }
  }

  // Get all documents in a collection based on a query
  Future<QuerySnapshot> getCollection({
    required String collection,
    Query Function(Query query)? queryBuilder,
  }) async {
    try {
      Query query = _db.collection(collection);
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      return await query.get();
    } catch (e) {
      AppLogger.red('FirestoreService - getCollection Error: $e');
      rethrow;
    }
  }

  // Stream of a collection
  Stream<QuerySnapshot> streamCollection({
    required String collection,
    Query Function(Query query)? queryBuilder,
  }) {
    Query query = _db.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots();
  }
}
