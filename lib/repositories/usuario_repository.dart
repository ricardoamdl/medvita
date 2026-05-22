import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../database/database_helper.dart';

class UsuarioRepository {
  // Converte a senha em hash SHA-256 antes de salvar
  // Assim a senha nunca fica salva em texto puro no banco
  static String _criptografarSenha(String senha) {
    final bytes = utf8.encode(senha);
    return sha256.convert(bytes).toString();
  }

  // ── CADASTRAR ──────────────────────────────────────
  // Retorna o id do usuário criado, ou null se o email já existe
  static Future<int?> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final db = await DatabaseHelper.database;
      final id = await db.insert('usuarios', {
        'nome': nome,
        'email': email,
        'senha': _criptografarSenha(senha),
      });
      return id;
    } catch (e) {
      // Email duplicado cai aqui (UNIQUE constraint)
      return null;
    }
  }

  // ── LOGIN ──────────────────────────────────────────
  // Retorna o Map do usuário se email+senha corretos, ou null se inválido
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String senha,
  }) async {
    final db = await DatabaseHelper.database;
    final resultado = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, _criptografarSenha(senha)],
    );

    if (resultado.isNotEmpty) {
      return resultado.first;
    }
    return null;
  }

  // ── CONFIRMAR CADASTRO (CPF + nascimento) ──────────
  // Retorna true se salvou, false se CPF já existe
  static Future<bool> confirmarCadastro({
    required int usuarioId,
    required String cpf,
    required String nascimento,
  }) async {
    try {
      final db = await DatabaseHelper.database;
      await db.update(
        'usuarios',
        {'cpf': cpf, 'nascimento': nascimento},
        where: 'id = ?',
        whereArgs: [usuarioId],
      );
      return true;
    } catch (e) {
      // CPF duplicado cai aqui (UNIQUE constraint)
      return false;
    }
  }

  // ── VERIFICAR SE JÁ CONFIRMOU ──────────────────────
  // Retorna true se o usuário já tem CPF cadastrado
  static Future<bool> jaConfirmou(int usuarioId) async {
    final db = await DatabaseHelper.database;
    final resultado = await db.query(
      'usuarios',
      columns: ['cpf'],
      where: 'id = ?',
      whereArgs: [usuarioId],
    );

    if (resultado.isNotEmpty) {
      return resultado.first['cpf'] != null;
    }
    return false;
  }
}
