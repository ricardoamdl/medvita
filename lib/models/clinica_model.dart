class ClinicaModel {
  final int? id;
  final String nome;
  final String especialidade;
  final double avaliacao;
  final int totalAvaliacoes;
  final double distanciaKm;
  // Campos novos para a tela de detalhe
  final String endereco;
  final String cidade;
  final String horario;
  final List<String> especialidades;
  final String fotoPath;

  const ClinicaModel({
    this.id,
    required this.nome,
    required this.especialidade,
    required this.avaliacao,
    required this.totalAvaliacoes,
    required this.distanciaKm,
    this.endereco = '',
    this.cidade = '',
    this.horario = '',
    this.especialidades = const [],
    this.fotoPath = '',
  });
}
