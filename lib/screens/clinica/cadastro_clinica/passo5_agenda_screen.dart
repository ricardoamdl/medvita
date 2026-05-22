import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../repositories/clinica_auth_repository.dart';
import '../../../session/sessao_clinica.dart';
import '../home_clinica_screen.dart';

class Passo5AgendaScreen extends StatefulWidget {
  const Passo5AgendaScreen({super.key});

  @override
  State<Passo5AgendaScreen> createState() => _Passo5AgendaScreenState();
}

class _Passo5AgendaScreenState extends State<Passo5AgendaScreen> {
  final _valorController = TextEditingController();
  final _horarioController = TextEditingController();

  // Dias selecionados
  final List<int> _diasSelecionados = [];
  // Horários adicionados
  final List<String> _horariosCadastrados = [];

  bool _salvando = false;

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

  // Próximos 7 dias para seleção
  List<DateTime> get _proximosDias =>
      List.generate(7, (i) => DateTime.now().add(Duration(days: i)));

  void _adicionarHorario() {
    final hora = _horarioController.text.trim();

    // Valida formato HH:MM
    final regex = RegExp(r'^\d{2}:\d{2}$');
    if (!regex.hasMatch(hora)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Use o formato HH:MM (ex: 08:00)')),
      );
      return;
    }

    if (_horariosCadastrados.contains(hora)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Horário já adicionado')));
      return;
    }

    setState(() {
      _horariosCadastrados.add(hora);
      _horariosCadastrados.sort(); // ordena crescente
      _horarioController.clear();
    });
  }

  Future<void> _cadastrar() async {
    if (_diasSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione ao menos um dia'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_horariosCadastrados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione ao menos um horário'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _salvando = true);

    // Converte índices de dias para datas reais
    final datas = _diasSelecionados
        .map((i) => _formatarData(_proximosDias[i]))
        .toList();

    // Busca os médicos da clínica para associar os horários
    final medicos = await ClinicaAuthRepository.buscarMedicos(
      SessaoClinica.id!,
    );

    // Salva os horários para cada médico
    for (final medico in medicos) {
      await ClinicaAuthRepository.salvarAgenda(
        medicoId: medico['id'] as int,
        datas: datas,
        horarios: _horariosCadastrados,
      );
    }

    setState(() => _salvando = false);

    if (mounted) {
      // Mostra sucesso e volta para Home da clínica limpando a pilha
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: AppTheme.greenPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'Clínica cadastrada\ncom sucesso!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HomeClinicaScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.greenPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Concluir',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  String _formatarData(DateTime data) {
    return '${data.year}-'
        '${data.month.toString().padLeft(2, '0')}-'
        '${data.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _valorController.dispose();
    _horarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dias = _proximosDias;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            // ── Seção dias ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: IconButton(
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'CADASTRAR DIAS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 72,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: dias.length,
                      itemBuilder: (context, index) {
                        final dia = dias[index];
                        final selecionado = _diasSelecionados.contains(index);
                        return GestureDetector(
                          onTap: () => setState(() {
                            if (selecionado) {
                              _diasSelecionados.remove(index);
                            } else {
                              _diasSelecionados.add(index);
                            }
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
                                    color: selecionado
                                        ? Colors.white
                                        : Colors.black87,
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
            ),

            // ── Conteúdo rolável ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CADASTRAR HORÁRIOS',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Campo para digitar horário
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _horarioController,
                            keyboardType: TextInputType.datetime,
                            decoration: InputDecoration(
                              hintText: 'ex: 08:00',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: _adicionarHorario,
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.greenPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),

                    // Grid de horários adicionados
                    if (_horariosCadastrados.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 2.8,
                            ),
                        itemCount: _horariosCadastrados.length,
                        itemBuilder: (context, index) {
                          final hora = _horariosCadastrados[index];
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    hora,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              // Botão remover horário
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () => setState(
                                    () => _horariosCadastrados.remove(hora),
                                  ),
                                  child: const CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.close,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Campo valor da consulta
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Text(
                        'CADASTRAR VALORES DA CONSULTA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '* Os valores são definidos por médico no passo anterior.\n'
                        'O pagamento é realizado presencialmente na clínica.',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Botão cadastrar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _salvando ? null : _cadastrar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.greenPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _salvando
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'CADASTRAR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
