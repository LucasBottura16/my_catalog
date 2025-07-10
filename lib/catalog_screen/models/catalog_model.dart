import 'package:cloud_firestore/cloud_firestore.dart';

class DBAddCatalog {
  String? _catalogName;
  String? _catalogCategory;
  String? _catalogDescription;
  String? _catalogImage;
  String? _uid;
  String? _uidCompany;
  String? _data;
  String? _nameCompany;

  DBAddCatalog();

  DBAddCatalog.fromDocumentSnapshotCatalog(DocumentSnapshot documentSnapshot) {
    uid = documentSnapshot["uid"];
    catalogName = documentSnapshot["nome do catalogo"];
    catalogCategory = documentSnapshot["categoria do catalogo"];
    catalogDescription = documentSnapshot["descricao do catalogo"];
    catalogImage = documentSnapshot["imagem do catalogo"];
    uidCompany = documentSnapshot["uidEmpresa"];
    data = documentSnapshot["data"];
    nameCompany = documentSnapshot["nome da empresa"];
  }

  Map<String, dynamic> toMapCatalog(uid, uidCompany) {
    Map<String, dynamic> map = {
      'nome do catalogo': catalogName,
      'categoria do catalogo': catalogCategory,
      'descricao do catalogo': catalogDescription,
      'imagem do catalogo': catalogImage,
      'uid': uid,
      'data': DateTime.now().toString(),
      'uidEmpresa': uidCompany,
      'nome da empresa': nameCompany,
    };
    return map;
  }

  String get nameCompany => _nameCompany!;

  set nameCompany(String value) {
    _nameCompany = value;
  }

  String get uidCompany => _uidCompany!;

  set uidCompany(String value) {
    _uidCompany = value;
  }

  String get uid => _uid!;
  set uid(String value) {
    _uid = value;
  }

  String get catalogImage => _catalogImage!;

  set catalogImage(String value) {
    _catalogImage = value;
  }

  String get catalogDescription => _catalogDescription!;

  set catalogDescription(String value) {
    _catalogDescription = value;
  }

  String get catalogCategory => _catalogCategory!;

  set catalogCategory(String value) {
    _catalogCategory = value;
  }

  String get catalogName => _catalogName!;

  set catalogName(String value) {
    _catalogName = value;
  }

  String get data => _data!;

  set data(String value) {
    _data = value;
  }
}