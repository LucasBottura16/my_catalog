import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // Certifique-se de que este arquivo existe

void main() async {
  // Garante que os bindings do Flutter estão inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase com as opções geradas
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teste de Conexão Firebase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FirebaseTestScreen(),
    );
  }
}

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String _statusMessage = 'Aguardando ação...'; // Mensagem de status na tela

  // Função assíncrona para adicionar um documento ao Firestore
  Future<void> _addDataToFirestore() async {
    setState(() {
      _statusMessage = 'Conectando ao Firebase...';
    });

    try {
      // Obtém uma instância do Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Cria um mapa de dados para o documento
      Map<String, dynamic> userData = {
        'nome': 'Usuário Teste Flutter',
        'email': 'teste@example.com',
        'timestamp': FieldValue.serverTimestamp(), // Adiciona um timestamp do servidor
        'testeId': DateTime.now().millisecondsSinceEpoch.toString(), // ID único para o teste
      };

      // Adiciona um novo documento à coleção 'testes'
      // Se a coleção 'testes' não existir, o Firestore a criará automaticamente.
      // add() cria um documento com um ID gerado automaticamente.
      await firestore.collection('testes').add(userData);

      setState(() {
        _statusMessage = 'Dados adicionados com sucesso ao Firestore!';
      });
      print('Dados adicionados com sucesso ao Firestore: $userData');
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro ao adicionar dados: $e';
      });
      print('Erro ao adicionar dados ao Firestore: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste de Conexão Firebase'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _addDataToFirestore,
              child: const Text('Adicionar Dados ao Firestore'),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Verifique o console do Firebase (Firestore) para confirmar! teste',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}