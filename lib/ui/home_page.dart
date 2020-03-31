import 'dart:io';

import 'package:agenda_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contacts = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getAllContacts();
  }

  void _orderList(OrderOptions result) {
    setState(() {
      switch (result) {
        case OrderOptions.orderaz:
          contacts.sort((a, b) {
            return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
          });
          break;
        case OrderOptions.orderza:
          contacts.sort((a, b) {
            return b.nome.toLowerCase().compareTo(a.nome.toLowerCase());
          });
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordernar A-Z'),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordernar Z-A'),
                value: OrderOptions.orderza,
              )
            ],
            onSelected: _orderList,
          )
        ],
        title: Text('Contatos'),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _ShowContactPage();
        },
        child: Icon(
          Icons.add,
        ),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: contacts[index].imagem != null
                          ? FileImage(File(contacts[index].imagem))
                          : AssetImage('images/person.png')),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      contacts[index].nome ?? '',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      contacts[index].email ?? '',
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    Text(
                      contacts[index].telefone ?? '',
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
        // _ShowContactPage(contact: contacts[index]);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlatButton(
                        onPressed: () {
                          launch('tel:${contacts[index].telefone}');
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Ligar',
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _ShowContactPage(contact: contacts[index]);
                        },
                        child: Text(
                          'Editar',
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlatButton(
                        onPressed: () {
                          helper.deleteContact(contacts[index].id);
                          setState(() {
                            contacts.removeAt(index);
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Excluir',
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
      },
    );
  }

  void _ShowContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPage(
          contact: contact,
        ),
      ),
    );
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }

      _getAllContacts();
    }
  }

  void _getAllContacts() {
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }
}
