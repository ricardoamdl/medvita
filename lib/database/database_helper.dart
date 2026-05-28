import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'medvita.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Tabela de usuários (pessoas físicas)
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha TEXT NOT NULL,
        cpf TEXT UNIQUE,
        nascimento TEXT
      )
    ''');

    // Tabela de clínicas (pessoas jurídicas)
    await db.execute('''
      CREATE TABLE clinicas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        senha TEXT NOT NULL,
        razao_social TEXT DEFAULT '',
        cnpj TEXT UNIQUE,
        cidade TEXT,
        estado TEXT,
        bairro TEXT,
        rua TEXT,
        numero TEXT,
        complemento TEXT,
        endereco TEXT,
        foto_path TEXT,
        descricao TEXT
      )
    ''');

    // Tabela de especialidades
    await db.execute('''
      CREATE TABLE especialidades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL UNIQUE
      )
    ''');

    // Tabela de médicos
    await db.execute('''
      CREATE TABLE medicos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        clinica_id INTEGER NOT NULL,
        especialidades_id INTEGER NOT NULL,
        valor_consulta REAL,
        FOREIGN KEY (clinica_id) REFERENCES clinicas(id),
        FOREIGN KEY (especialidades_id) REFERENCES especialidades(id)
      )
    ''');

    // Tabela de relacionamento entre clínicas e especialidades
    await db.execute('''
      CREATE TABLE clinica_especialidade (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clinica_id INTEGER NOT NULL,
        especialidades_id INTEGER NOT NULL,
        FOREIGN KEY (clinica_id) REFERENCES clinicas(id),
        FOREIGN KEY (especialidades_id) REFERENCES especialidades(id),
        UNIQUE(clinica_id, especialidades_id)
      )
    ''');

    // Tabela de horários dos médicos
    await db.execute('''
      CREATE TABLE horarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicos_id INTEGER NOT NULL,
        data TEXT NOT NULL,
        hora TEXT NOT NULL,
        disponivel INTEGER DEFAULT 1,
        FOREIGN KEY (medicos_id) REFERENCES medicos(id),
        UNIQUE(medicos_id, data, hora)
      )
    ''');

    // Insere especialidades padrão
    await db.insert('especialidades', {'nome': 'Cardiologia'});
    await db.insert('especialidades', {'nome': 'Dermatologia'});
    await db.insert('especialidades', {'nome': 'Neurologia'});
    await db.insert('especialidades', {'nome': 'Ortopedia'});
    await db.insert('especialidades', {'nome': 'Pediatria'});
    await db.insert('especialidades', {'nome': 'Psiquiatria'});
    await db.insert('especialidades', {'nome': 'Oftalmologia'});
    await db.insert('especialidades', {'nome': 'Otorrinolaringologia'});
    await db.insert('especialidades', {'nome': 'Ginecologia'});
    await db.insert('especialidades', {'nome': 'Urologia'});
  }
}
