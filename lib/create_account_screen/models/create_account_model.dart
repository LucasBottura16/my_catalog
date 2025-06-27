import 'package:cloud_firestore/cloud_firestore.dart';

class DBCreateCustomer {
  String? _uid;
  String? _name;
  String? _cpf;
  String? _state;
  String? _address;
  String? _phone;

  DBCreateCustomer();

  DBCreateCustomer.fromDocumentSnapshot(DocumentSnapshot documentSnapshot){
    uid = documentSnapshot["uid"];
    name = documentSnapshot["nome"];
    cpf = documentSnapshot["cpf"];
    state = documentSnapshot["estado"];
    address = documentSnapshot["endereco"];
    phone = documentSnapshot["telefone"];
  }

  Map<String, dynamic> toMap(uid) {
    Map<String, dynamic> map = {
      "uid": uid,
      "nome": _name,
      "cpf": _cpf,
      "estado": _state,
      "endereco": _address,
      "telefone": _phone,
      "biografia": "Descreva sua biografia aqui!",
      "imagem": ""
    };

    return map;
  }

  String get uid => _uid!;

  set uid(String value) {
    _uid = value;
  }

  String get phone => _phone!;

  set phone(String value) {
    _phone = value;
  }

  String get address => _address!;

  set address(String value) {
    _address = value;
  }

  String get state => _state!;

  set state(String value) {
    _state = value;
  }

  String get cpf => _cpf!;

  set cpf(String value) {
    _cpf = value;
  }

  String get name => _name!;

  set name(String value) {
    _name = value;
  }

}

class DBCreateCompany {
  String? _uid;
  String? _companyName;
  String? _cnpj;
  String? _representative;
  String? _category;
  String? _state;
  String? _address;
  String? _phone;

  DBCreateCompany();

  DBCreateCompany.fromDocumentSnapshot(DocumentSnapshot documentSnapshot){
    uid = documentSnapshot["uid"];
    companyName = documentSnapshot["nome"];
    cnpj = documentSnapshot["cnpj"];
    representative = documentSnapshot["representante"];
    category = documentSnapshot["categoria"];
    state = documentSnapshot["estado"];
    address = documentSnapshot["endereco"];
    phone = documentSnapshot["telefone"];
  }

  Map<String, dynamic> toMap(uid) {
    Map<String, dynamic> map = {
      "uid": uid,
      "nome": _companyName,
      "cnpj": _cnpj,
      "representante": _representative,
      "categoria": _category,
      "estado": _state,
      "endereco": _address,
      "telefone": _phone,
      "biografia": "Descreva sua biografia aqui!",
      "imagem": ""
    };
    return map;
  }

  String get phone => _phone!;

  set phone(String value) {
    _phone = value;
  }

  String get address => _address!;

  set address(String value) {
    _address = value;
  }

  String get state => _state!;

  set state(String value) {
    _state = value;
  }

  String get category => _category!;

  set category(String value) {
    _category = value;
  }

  String get representative => _representative!;

  set representative(String value) {
    _representative = value;
  }

  String get cnpj => _cnpj!;

  set cnpj(String value) {
    _cnpj = value;
  }

  String get companyName => _companyName!;

  set companyName(String value) {
    _companyName = value;
  }

  String get uid => _uid!;

  set uid(String value) {
    _uid = value;
  }
}