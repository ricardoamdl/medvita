import '../database/database_helper.dart';
import '../models/clinica_model.dart';

class ClinicaRepository {
  // Busca todas as clínicas cadastradas
  static Future<List<ClinicaModel>> buscarTodas() async {
    final db = await DatabaseHelper.database;
    final resultado = await db.query('clinicas');

    // Para cada clínica, carregamos suas especialidades e foto
    final List<ClinicaModel> lista = [];
    for (final row in resultado) {
      final id = row['id'] as int?;
      final foto = row['foto_path'] as String? ?? '';
      final esp = id != null ? await buscarEspecialidades(id) : <String>[];

      lista.add(
        ClinicaModel(
          id: id,
          nome: row['razao_social'] as String? ?? 'Clínica sem nome',
          especialidade: esp.isNotEmpty ? esp.first : '',
          avaliacao: (row['avaliacao'] as num?)?.toDouble() ?? 0.0,
          totalAvaliacoes: 0,
          distanciaKm: (row['distancia_km'] as num?)?.toDouble() ?? 0.0,
          endereco: '${row['rua'] ?? ''}, ${row['numero'] ?? ''}',
          cidade: row['cidade'] as String? ?? '',
          horario: row['horario'] as String? ?? '',
          especialidades: esp,
          fotoPath: foto,
        ),
      );
    }

    return lista;
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
