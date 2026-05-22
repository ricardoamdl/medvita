import '../database/database_helper.dart';

class ConsultaRepository {
  // Salva o agendamento e bloqueia o horário — tudo numa transação
  static Future<bool> agendar({
    required int usuarioId,
    required int medicoId,
    required int clinicaId,
    required int horarioId,
  }) async {
    final db = await DatabaseHelper.database;

    try {
      await db.transaction((txn) async {
        // 1. Bloqueia o horário para outros usuários
        await txn.update(
          'horarios',
          {'disponivel': 0},
          where: 'id = ? AND disponivel = 1',
          whereArgs: [horarioId],
        );

        // 2. Registra a consulta
        await txn.insert('consultas', {
          'usuarios_id': usuarioId,
          'medicos_id': medicoId,
          'clinica_id': clinicaId,
          'horario_id': horarioId,
          'status': 'confirmada',
        });
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // Busca consultas do usuário logado
  static Future<List<Map<String, dynamic>>> buscarConsultasUsuario(
    int usuarioId,
  ) async {
    final db = await DatabaseHelper.database;

    final resultado = await db.rawQuery(
      '''
      SELECT 
        c.id,
        c.status,
        cl.nome      as clinica,
        cl.endereco  as endereco,
        cl.cidade    as cidade,
        m.nome       as medico,
        e.nome       as especialidade,
        h.data       as data,
        h.hora       as hora
      FROM consultas c
      INNER JOIN clinicas  cl ON cl.id = c.clinica_id
      INNER JOIN medicos   m  ON m.id  = c.medicos_id
      INNER JOIN horarios  h  ON h.id  = c.horario_id
      INNER JOIN especialidades e ON e.id = m.especialidades_id
      WHERE c.usuarios_id = ?
      ORDER BY h.data ASC, h.hora ASC
    ''',
      [usuarioId],
    );

    return resultado;
  }

  // Cancela uma consulta e libera o horário
  static Future<bool> cancelar(int consultaId, int horarioId) async {
    final db = await DatabaseHelper.database;

    try {
      await db.transaction((txn) async {
        // 1. Libera o horário
        await txn.update(
          'horarios',
          {'disponivel': 1},
          where: 'id = ?',
          whereArgs: [horarioId],
        );

        // 2. Atualiza status da consulta
        await txn.update(
          'consultas',
          {'status': 'cancelada'},
          where: 'id = ?',
          whereArgs: [consultaId],
        );
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}
