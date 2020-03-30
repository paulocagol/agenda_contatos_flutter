import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String contactTable = 'contacTable';
final String idColumn = 'idColumn';
final String nomeColumn = 'nomeColumn';
final String emailColumn = 'emailColumn';
final String telefoneColumn = 'telefoneColumn';
final String imagemColumn = 'imagemColumn';

class ContactHelper {
  static final ContactHelper _instace = ContactHelper.internal();

  factory ContactHelper() => _instace;

  ContactHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'contacts.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int newVersion) async {
        await db.execute(
            'CREATE TABLE $contactTable ($idColumn INTEGER PRIMARY KEY, $nomeColumn TEXT, $emailColumn TEXT, $telefoneColumn TEXT, $imagemColumn TEXT)');
      },
    );
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;

    contact.id = await dbContact.insert(contactTable, contact.toMap());

    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
        columns: [
          idColumn,
          nomeColumn,
          emailColumn,
          telefoneColumn,
          imagemColumn
        ],
        where: '$idColumn = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact
        .delete(contactTable, where: '$idColumn = ?', whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(),
        where: '$idColumn = ?', whereArgs: [contact.id]);
  }

  Future<List> getAllContacts() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery('SELECT * FROM $contactTable');
    List<Contact> listContact = List();

    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }

    return listContact;
  }

  Future<int> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery('SELECT COUNT(*) FROM $contactTable'));
  }

  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

class Contact {
  int id;
  String nome;
  String email;
  String telefone;
  String imagem;

  Contact();

  Contact.fromMap(Map map) {
    id = map[idColumn];
    nome = map[nomeColumn];
    email = map[emailColumn];
    telefone = map[telefoneColumn];
    imagem = map[imagemColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nomeColumn: nome,
      emailColumn: email,
      telefoneColumn: telefone,
      imagemColumn: imagem
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return 'Contact(id: $id, nome: $nome, email: $email, telefone: $telefone, imagem: $imagem)';
  }
}
