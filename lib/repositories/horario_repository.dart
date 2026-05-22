import '../database/database_helper.dart';

class HorarioRepository {
  // Busca horários disponíveis de um médico em uma data específica
  static Future<List<Map<String, dynamic>>> buscarDisponiveis({
    required int medicoId,
    required String data, // formato: 'YYYY-MM-DD'
  }) async {
    final db = await DatabaseHelper.database;

    final resultado = await db.query(
      'horarios',
      where: 'medicos_id = ? AND data = ? AND disponivel = 1',
      whereArgs: [medicoId, data],
      orderBy: 'hora ASC',
    );

    return resultado;
  }

  // Busca todos os médicos de uma especialidade em uma clínica
  static Future<List<Map<String, dynamic>>> buscarMedicosPorEspecialidade({
    required int clinicaId,
    required String especialidade,
  }) async {
    final db = await DatabaseHelper.database;

    final resultado = await db.rawQuery(
      '''
      SELECT m.id, m.nome, m.valor_consulta, e.nome as especialidade
      FROM medicos m
      INNER JOIN especialidades e ON e.id = m.especialidades_id
      WHERE m.clinica_id = ?
      AND e.nome = ?
    ''',
      [clinicaId, especialidade],
    );

    return resultado;
  }

  // Formata a data do DateTime para string 'YYYY-MM-DD'
  static String formatarData(DateTime data) {
    return '${data.year}-'
        '${data.month.toString().padLeft(2, '0')}-'
        '${data.day.toString().padLeft(2, '0')}';
  }
}
