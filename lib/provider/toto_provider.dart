import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:moapp_toto/models/toto_entity.dart';
import 'package:moapp_toto/models/user_entity.dart';

class TotoProvider with ChangeNotifier {
  List<ToToEntity?> _totos = [];

  List<ToToEntity?> get t => _totos;

  TotoProvider() {
    print("totoProvider()");
    init();
  }

  Future<void> init() async {
    // document entry
    FirebaseFirestore.instance
        .collection('toto')
        .orderBy("created", descending: true)
        .snapshots()
        .listen((snapshot) {
      _totos = snapshot.docs
          .map((doc) => ToToEntity.fromDocumentSnapshot(doc))
          .where((doc) => doc != null)
          .toList();
      print('totos updated, notifying listeners...');
      notifyListeners();
    });
  }
}
