import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../repositories/horario_repository.dart';
import 'confirmacao_agendamento_screen.dart';

class AgendamentoScreen extends StatefulWidget {
  final String especialidade;
  final int clinicaId;
  final String nomeClinica;
  final String endereco;

  const AgendamentoScreen({
    super.key,
    required this.especialidade,
    required this.clinicaId,
    required this.nomeClinica,
    required this.endereco,
  });

  @override
  State<AgendamentoScreen> createState() => _AgendamentoScreenState();
}

class _AgendamentoScreenState extends State<AgendamentoScreen> {
  int _diaSelecionado = 0;
  String? _horarioSelecionado;
  int? _horarioIdSelecionado;

  static const _diasSemana = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];
  static const _meses = [
    '',
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];

  List<DateTime> get _proximosDias =>
      List.generate(7, (i) => DateTime.now().add(Duration(days: i)));

  // Busca médicos e horários do banco
  Future<Map<String, dynamic>> _carregarDados() async {
    final medicos = await HorarioRepository.buscarMedicosPorEspecialidade(
      clinicaId: widget.clinicaId,
      especialidade: widget.especialidade,
    );

    if (medicos.isEmpty) return {'medico': null, 'horarios': []};

    // Pega o primeiro médico disponível
    final medico = medicos.first;

    final dataStr = HorarioRepository.formatarData(
      _proximosDias[_diaSelecionado],
    );

    final horarios = await HorarioRepository.buscarDisponiveis(
      medicoId: medico['id'] as int,
      data: dataStr,
    );

    return {'medico': medico, 'horarios': horarios};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            _buildCalendario(),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _carregarDados(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.greenPrimary,
                      ),
                    );
                  }

                  final dados = snapshot.data ?? {};
                  final medico = dados['medico'];
                  final horarios =
                      (dados['horarios'] as List<Map<String, dynamic>>?) ?? [];

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Horários',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        horarios.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    'Nenhum horário disponível\npara esta data',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              )
                            : _buildGridHorarios(horarios),
                        const SizedBox(height: 20),
                        if (medico != null) _buildCardInfos(medico),
                        const SizedBox(height: 32),
                        _buildBotaoAgendar(medico),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendario() {
    final dias = _proximosDias;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Color(0xFFF0F0F0),
                radius: 16,
                child: Icon(Icons.chevron_left, color: Colors.black, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: dias.length,
              itemBuilder: (context, index) {
                final dia = dias[index];
                final selecionado = _diaSelecionado == index;
                return GestureDetector(
                  onTap: () => setState(() {
                    _diaSelecionado = index;
                    _horarioSelecionado = null;
                    _horarioIdSelecionado = null;
                  }),
                  child: Container(
                    width: 54,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: selecionado
                          ? AppTheme.greenPrimary
                          : const Color(0xFFE8E8E8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _diasSemana[dia.weekday - 1],
                          style: TextStyle(
                            fontSize: 11,
                            color: selecionado
                                ? Colors.white70
                                : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dia.day.toString().padLeft(2, '0'),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: selecionado ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          _meses[dia.month],
                          style: TextStyle(
                            fontSize: 11,
                            color: selecionado
                                ? Colors.white70
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridHorarios(List<Map<String, dynamic>> horarios) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.8,
      ),
      itemCount: horarios.length,
      itemBuilder: (context, index) {
        final horario = horarios[index];
        final hora = horario['hora'] as String;
        final id = horario['id'] as int;
        final selecionado = _horarioIdSelecionado == id;

        return GestureDetector(
          onTap: () => setState(() {
            _horarioSelecionado = hora;
            _horarioIdSelecionado = id;
          }),
          child: Container(
            decoration: BoxDecoration(
              color: selecionado ? AppTheme.greenPrimary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                hora,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: selecionado ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardInfos(Map<String, dynamic> medico) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'valor da consulta',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                Text(
                  'R\$ ${(medico['valor_consulta'] as num).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medico['nome'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  medico['especialidade'] as String,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoAgendar(Map<String, dynamic>? medico) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: (_horarioSelecionado == null || medico == null)
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConfirmacaoAgendamentoScreen(
                      nomeClinica: widget.nomeClinica,
                      endereco: widget.endereco,
                      diaSelecionado: _proximosDias[_diaSelecionado],
                      horario: _horarioSelecionado!,
                      especialidade: widget.especialidade,
                      medicoId: medico['id'] as int,
                      clinicaId: widget.clinicaId,
                      horarioId: _horarioIdSelecionado!,
                    ),
                  ),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.greenPrimary,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Agendar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
