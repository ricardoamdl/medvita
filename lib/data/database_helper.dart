import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final caminho = await getDatabasesPath();
    final path = join(caminho, 'medvita.db');

    return await openDatabase(
      path,
      version: 2, // ← versão 2 por causa das mudanças
      onCreate: _criarTabelas,
      onUpgrade: _atualizarTabelas, // ← migração para quem já tem v1
    );
  }

  // ── Criação completa (instalação nova) ─────────────
  static Future<void> _criarTabelas(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS usuarios (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        nome        TEXT    NOT NULL,
        email       TEXT    NOT NULL UNIQUE,
        senha       TEXT    NOT NULL,
        cpf         TEXT    UNIQUE,
        nascimento  TEXT,
        tipo        TEXT    DEFAULT 'fisica'
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS clinicas (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        razao_social TEXT    NOT NULL,
        cnpj         TEXT    NOT NULL UNIQUE,
        email        TEXT    NOT NULL UNIQUE,
        senha        TEXT    NOT NULL,
        endereco     TEXT,
        bairro       TEXT,
        cidade       TEXT,
        estado       TEXT,
        rua          TEXT,
        numero       TEXT,
        complemento  TEXT,
        dias_func    TEXT,
        horario      TEXT,
        avaliacao    REAL    DEFAULT 0.0,
        distancia_km REAL    DEFAULT 0.0,
        descricao    TEXT,
        foto_path    TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS especialidades (
        id   INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT    NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS clinica_especialidade (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        clinica_id        INTEGER NOT NULL,
        especialidades_id INTEGER NOT NULL,
        FOREIGN KEY (clinica_id)        REFERENCES clinicas(id),
        FOREIGN KEY (especialidades_id) REFERENCES especialidades(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS medicos (
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        nome              TEXT    NOT NULL,
        clinica_id        INTEGER NOT NULL,
        especialidades_id INTEGER NOT NULL,
        valor_consulta    REAL    DEFAULT 0.0,
        FOREIGN KEY (clinica_id)        REFERENCES clinicas(id),
        FOREIGN KEY (especialidades_id) REFERENCES especialidades(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS horarios (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        medicos_id INTEGER NOT NULL,
        data       TEXT    NOT NULL,
        hora       TEXT    NOT NULL,
        disponivel INTEGER DEFAULT 1,
        FOREIGN KEY (medicos_id) REFERENCES medicos(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS consultas (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        usuarios_id INTEGER NOT NULL,
        medicos_id  INTEGER NOT NULL,
        clinica_id  INTEGER NOT NULL,
        horario_id  INTEGER NOT NULL,
        status      TEXT    DEFAULT 'confirmada',
        FOREIGN KEY (usuarios_id) REFERENCES usuarios(id),
        FOREIGN KEY (medicos_id)  REFERENCES medicos(id),
        FOREIGN KEY (clinica_id)  REFERENCES clinicas(id),
        FOREIGN KEY (horario_id)  REFERENCES horarios(id)
      )
    ''');

    // Especialidades padrão já inseridas no banco
    await _inserirEspecialidadesPadrao(db);
  }

  // ── Migração (quem já tinha v1 instalada) ──────────
  static Future<void> _atualizarTabelas(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // Adiciona campo tipo na tabela usuarios
      await db.execute(
        "ALTER TABLE usuarios ADD COLUMN tipo TEXT DEFAULT 'fisica'",
      );

      // Adiciona campos novos na tabela clinicas
      await db.execute("ALTER TABLE clinicas ADD COLUMN razao_social TEXT");
      await db.execute("ALTER TABLE clinicas ADD COLUMN cnpj TEXT");
      await db.execute("ALTER TABLE clinicas ADD COLUMN email TEXT");
      await db.execute("ALTER TABLE clinicas ADD COLUMN senha TEXT");
      await db.execute("ALTER TABLE clinicas ADD COLUMN estado TEXT");
      await db.execute("ALTER TABLE clinicas ADD COLUMN rua TEXT");
      await db.execute("ALTER TABLE clinicas ADD COLUMN numero TEXT");
      await db.execute("ALTER TABLE clinicas ADD COLUMN complemento TEXT");
      await db.execute("ALTER TABLE clinicas ADD COLUMN descricao TEXT");
      await db.execute("ALTER TABLE clinicas ADD COLUMN foto_path TEXT");

      await _inserirEspecialidadesPadrao(db);
    }
  }

  // ── Especialidades padrão ───────────────────────────
  // Inseridas automaticamente para a clínica escolher
  static Future<void> _inserirEspecialidadesPadrao(Database db) async {
    final especialidades = [
      'Clínico geral',
      'Cardiologista',
      'Pediatria',
      'Odontologia',
      'Urologia',
      'Dermatologia',
      'Ortopedia',
      'Ginecologia',
      'Psiquiatria',
      'Neurologia',
      'Oftalmologia',
      'Endocrinologia',
    ];

    for (final nome in especialidades) {
      await db.insert('especialidades', {
        'nome': nome,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
}
