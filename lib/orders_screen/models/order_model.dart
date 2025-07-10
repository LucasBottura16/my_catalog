import 'package:cloud_firestore/cloud_firestore.dart';

class DBOrderModel {
  DateTime? _orderDate;
  String? _totalAmount;
  List<Map<String, dynamic>>? _productsData;
  String? _status;
  String? _uidCustomer;
  String? _uidCompany;
  String? _uidCatalog;
  String? _uidOrder;
  String? _nameCatalog;
  String? _nameCompany;
  String? _nameCustomer;
  String? _emailCustomer;
  String? _phoneCustomer;
  String? _addressCustomer;

  DBOrderModel();

  DBOrderModel.fromDocumentSnapshot(DocumentSnapshot documentSnapshot){
    _uidOrder = documentSnapshot["uidOrder"];
    _orderDate = documentSnapshot["orderDate"].toDate();
    _totalAmount = documentSnapshot["totalAmount"];
    _productsData = List<Map<String, dynamic>>.from(documentSnapshot["products"]);
    _status = documentSnapshot["status"];
    _uidCustomer = documentSnapshot["uidCustomer"];
    _uidCompany = documentSnapshot["uidComapny"];
    _uidCatalog = documentSnapshot["uidCatalog"];
    _nameCatalog = documentSnapshot["nameCatalog"];
    _nameCompany = documentSnapshot["nameCompany"];
    _nameCustomer = documentSnapshot["nameCustomer"];
    _emailCustomer = documentSnapshot["emailCustomer"];
    _phoneCustomer = documentSnapshot["phoneCustomer"];
    _addressCustomer = documentSnapshot["addressCustomer"];
  }

  Map<String, dynamic> toMap(uid) {
    Map<String, dynamic> map = {
      'orderDate': _orderDate,
      'totalAmount': _totalAmount,
      'products': _productsData,
      'status': 'Pendente',
      'uidCustomer': _uidCustomer,
      'uidComapny': _uidCompany,
      'uidCatalog': _uidCatalog,
      'uidOrder': uid,
      'nameCatalog': _nameCatalog,
      'nameCompany': _nameCompany,
      'nameCustomer': _nameCustomer,
      'emailCustomer': _emailCustomer,
      'phoneCustomer': _phoneCustomer,
      'addressCustomer': _addressCustomer,
    };
    return map;
  }


  String get emailCustomer => _emailCustomer!;

  set emailCustomer(String value) {
    _emailCustomer = value;
  }

  String get nameCatalog => _nameCatalog!;

  set nameCatalog(String value) {
    _nameCatalog = value;
  }

  String get uidOrder => _uidOrder!;

  set uidOrder(String value) {
    _uidOrder = value;
  }

  String get uidCatalog => _uidCatalog!;

  set uidCatalog(String value) {
    _uidCatalog = value;
  }

  String get uidCompany => _uidCompany!;

  set uidCompany(String value) {
    _uidCompany = value;
  }

  String get uidCustomer => _uidCustomer!;

  set uidCustomer(String value) {
    _uidCustomer = value;
  }

  String get status => _status!;

  set status(String value) {
    _status = value;
  }

  List<Map<String, dynamic>> get productsData => _productsData!;

  set productsData(List<Map<String, dynamic>> value) {
    _productsData = value;
  }

  String get totalAmount => _totalAmount!;

  set totalAmount(String value) {
    _totalAmount = value;
  }

  DateTime get orderDate => _orderDate!;

  set orderDate(DateTime value) {
    _orderDate = value;
  }

  String get nameCompany => _nameCompany!;

  set nameCompany(String value) {
    _nameCompany = value;
  }

  String get nameCustomer => _nameCustomer!;

  set nameCustomer(String value) {
    _nameCustomer = value;
  }

  String get phoneCustomer => _phoneCustomer!;

  set phoneCustomer(String value) {
    _phoneCustomer = value;
  }

  String get addressCustomer => _addressCustomer!;

  set addressCustomer(String value) {
    _addressCustomer = value;
  }

}
