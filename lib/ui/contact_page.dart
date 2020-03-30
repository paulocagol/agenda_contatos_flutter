import 'dart:io';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;
  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();


  bool _userEdited = false;
  Contact _editContact;

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editContact = Contact();
    } else {
      _editContact = Contact.fromMap(widget.contact.toMap());

      _nomeController.text = _editContact.nome;
      _emailController.text = _editContact.email;
      _telefoneController.text = _editContact.telefone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editContact.nome ?? 'Novo Contato'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.save),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              child: Container(
                width: 140.0,
                height: 140.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: _editContact.imagem != null
                          ? FileImage(File(_editContact.imagem))
                          : AssetImage('images/person.png')),
                ),
              ),
            ),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome'),
              onChanged: (text) {
                _userEdited = true;
                setState(() {
                  _editContact.nome = text;
                });
              },
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: (text) {
                _userEdited = true;
                _editContact.email = text;
              },
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _telefoneController,
              decoration: InputDecoration(labelText: 'Fone'),
              onChanged: (text) {
                _userEdited = true;
                _editContact.telefone = text;
              },
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }
}
