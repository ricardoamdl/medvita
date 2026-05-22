import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import '../database/database_helper.dart';

class ClinicaAuthRepository {
  static String _criptografarSenha(String senha) {
    final bytes = utf8.encode(senha);
    return sha256.convert(bytes).toString();
  }

  // ── CADASTRAR clínica (só email/senha por enquanto) ─
  // Retorna o id da clínica criada, ou null se email/cnpj já existe
  static Future<int?> cadastrar({
    required String email,
    required String senha,
  }) async {
    try {
      final db = await DatabaseHelper.database;
      final id = await db.insert('clinicas', {
        'email': email,
        'senha': _criptografarSenha(senha),
        'razao_social': '',
        'cnpj': '',
      });
      return id;
    } catch (e) {
      return null;
    }
  }

  // ── LOGIN da clínica ────────────────────────────────
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String senha,
  }) async {
    final db = await DatabaseHelper.database;
    final resultado = await db.query(
      'clinicas',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, _criptografarSenha(senha)],
    );

    if (resultado.isNotEmpty) return resultado.first;
    return null;
  }

  // ── SALVAR dados do passo 1 ─────────────────────────
  static Future<bool> salvarDadosBasicos({
    required int clinicaId,
    required String razaoSocial,
    required String cnpj,
    required String cidade,
    required String estado,
    required String bairro,
    required String rua,
    required String numero,
    required String complemento,
  }) async {
    try {
      final db = await DatabaseHelper.database;
      await db.update(
        'clinicas',
        {
          'razao_social': razaoSocial,
          'cnpj': cnpj,
          'cidade': cidade,
          'estado': estado,
          'bairro': bairro,
          'rua': rua,
          'numero': numero,
          'complemento': complemento,
          'endereco': '$rua, $numero - $bairro',
        },
        where: 'id = ?',
        whereArgs: [clinicaId],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── SALVAR especialidades (passo 2) ─────────────────
  static Future<bool> salvarEspecialidades({
    required int clinicaId,
    required List<int> especialidadeIds,
  }) async {
    try {
      final db = await DatabaseHelper.database;

      // Remove especialidades antigas se existirem
      await db.delete(
        'clinica_especialidade',
        where: 'clinica_id = ?',
        whereArgs: [clinicaId],
      );

      // Insere as novas
      for (final espId in especialidadeIds) {
        await db.insert('clinica_especialidade', {
          'clinica_id': clinicaId,
          'especialidades_id': espId,
        });
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── SALVAR médico (passo 3) ─────────────────────────
  static Future<bool> salvarMedico({
    required int clinicaId,
    required String nome,
    required int especialidadeId,
    required double valorConsulta,
  }) async {
    try {
      final db = await DatabaseHelper.database;
      await db.insert('medicos', {
        'nome': nome,
        'clinica_id': clinicaId,
        'especialidades_id': especialidadeId,
        'valor_consulta': valorConsulta,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── SALVAR foto e descrição (passo 4) ───────────────
  static Future<bool> salvarFoto({
    required int clinicaId,
    required String fotoPath,
    required String descricao,
  }) async {
    try {
      final db = await DatabaseHelper.database;
      await db.update(
        'clinicas',
        {'foto_path': fotoPath, 'descricao': descricao},
        where: 'id = ?',
        whereArgs: [clinicaId],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── SALVAR agenda e horários (passo 5) ──────────────
  static Future<bool> salvarAgenda({
    required int medicoId,
    required List<String> datas, // lista de datas 'YYYY-MM-DD'
    required List<String> horarios, // lista de horas '08:00'
  }) async {
    try {
      final db = await DatabaseHelper.database;

      for (final data in datas) {
        for (final hora in horarios) {
          // Evita duplicar horários já cadastrados
          await db.insert('horarios', {
            'medicos_id': medicoId,
            'data': data,
            'hora': hora,
            'disponivel': 1,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // ── BUSCAR médicos da clínica ───────────────────────
  static Future<List<Map<String, dynamic>>> buscarMedicos(int clinicaId) async {
    final db = await DatabaseHelper.database;
    return await db.rawQuery(
      '''
      SELECT m.id, m.nome, m.valor_consulta, e.nome as especialidade,
             e.id as especialidade_id
      FROM medicos m
      INNER JOIN especialidades e ON e.id = m.especialidades_id
      WHERE m.clinica_id = ?
    ''',
      [clinicaId],
    );
  }

  // ── BUSCAR todas especialidades disponíveis ─────────
  static Future<List<Map<String, dynamic>>> buscarTodasEspecialidades() async {
    final db = await DatabaseHelper.database;
    return await db.query('especialidades', orderBy: 'nome ASC');
  }
}
