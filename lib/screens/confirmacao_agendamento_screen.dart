import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../repositories/consulta_repository.dart';
import '../session/sessao_usuario.dart';
import 'home_screen.dart';

class ConfirmacaoAgendamentoScreen extends StatefulWidget {
  final String nomeClinica;
  final String endereco;
  final DateTime diaSelecionado;
  final String horario;
  final String especialidade;
  final int medicoId;
  final int clinicaId;
  final int horarioId;

  const ConfirmacaoAgendamentoScreen({
    super.key,
    required this.nomeClinica,
    required this.endereco,
    required this.diaSelecionado,
    required this.horario,
    required this.especialidade,
    required this.medicoId,
    required this.clinicaId,
    required this.horarioId,
  });

  @override
  State<ConfirmacaoAgendamentoScreen> createState() =>
      _ConfirmacaoAgendamentoScreenState();
}

class _ConfirmacaoAgendamentoScreenState
    extends State<ConfirmacaoAgendamentoScreen> {
  static const _diasSemana = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
  static const _meses = [
    '',
    'JAN',
    'FEV',
    'MAR',
    'ABR',
    'MAI',
    'JUN',
    'JUL',
    'AGO',
    'SET',
    'OUT',
    'NOV',
    'DEZ',
  ];

  bool _salvando = false;

  String get _dataFormatada {
    final d = widget.diaSelecionado;
    final diaSem = _diasSemana[d.weekday - 1];
    final mes = _meses[d.month];
    return '$diaSem. ${d.day} de $mes ás ${widget.horario}';
  }

  Future<void> _confirmarAgendamento() async {
    setState(() => _salvando = true);

    final sucesso = await ConsultaRepository.agendar(
      usuarioId: SessaoUsuario.id!,
      medicoId: widget.medicoId,
      clinicaId: widget.clinicaId,
      horarioId: widget.horarioId,
    );

    setState(() => _salvando = false);

    if (!mounted) return;

    if (sucesso) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => _TelaConfirmado(
            nomeClinica: widget.nomeClinica,
            dataFormatada: _dataFormatada,
            endereco: widget.endereco,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao agendar. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: const CircleAvatar(
                  backgroundColor: Color(0xFFF0F0F0),
                  radius: 16,
                  child: Icon(
                    Icons.chevron_left,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 32),
              const Text(
                'Confirmar agendamento',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              _buildLinhaResumo('Clínica', widget.nomeClinica),
              _buildLinhaResumo('Especialidade', widget.especialidade),
              _buildLinhaResumo('Data e hora', _dataFormatada),
              _buildLinhaResumo('Endereço', widget.endereco),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _confirmarAgendamento,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.greenPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _salvando
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Confirmar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinhaResumo(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }
}

class _TelaConfirmado extends StatelessWidget {
  final String nomeClinica;
  final String dataFormatada;
  final String endereco;

  const _TelaConfirmado({
    required this.nomeClinica,
    required this.dataFormatada,
    required this.endereco,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const CircleAvatar(
                    backgroundColor: Color(0xFFF0F0F0),
                    radius: 16,
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Spacer(),
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppTheme.greenPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 52),
              ),
              const SizedBox(height: 28),
              const Text(
                'Agendamento\nconfirmado!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomeClinica,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dataFormatada,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const Divider(height: 24),
                    Text(
                      endereco,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.greenPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Voltar ao início',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
