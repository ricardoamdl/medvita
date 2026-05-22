import '../database/database_helper.dart';
import '../models/clinica_model.dart';

class ClinicaRepository {
  // Busca todas as clínicas cadastradas
  static Future<List<ClinicaModel>> buscarTodas() async {
    final db = await DatabaseHelper.database;
    final resultado = await db.query('clinicas');

    return resultado
        .map(
          (row) => ClinicaModel(
            id: row['id'] as int?,
            nome: row['nome'] as String,
            especialidade: '', // virá do join futuramente
            avaliacao: (row['avaliacao'] as num?)?.toDouble() ?? 0.0,
            totalAvaliacoes: 0,
            distanciaKm: (row['distancia_km'] as num?)?.toDouble() ?? 0.0,
            endereco: '${row['endereco'] ?? ''}, ${row['bairro'] ?? ''}',
            cidade: row['cidade'] as String? ?? '',
            horario: row['horario'] as String? ?? '',
            especialidades: [], // carregadas separadamente
          ),
        )
        .toList();
  }

  // Busca especialidades de uma clínica específica
  static Future<List<String>> buscarEspecialidades(int clinicaId) async {
    final db = await DatabaseHelper.database;

    // JOIN entre clinica_especialidade e especialidades
    final resultado = await db.rawQuery(
      '''
      SELECT e.nome
      FROM especialidades e
      INNER JOIN clinica_especialidade ce ON ce.especialidades_id = e.id
      WHERE ce.clinica_id = ?
    ''',
      [clinicaId],
    );

    return resultado.map((row) => row['nome'] as String).toList();
  }
}
