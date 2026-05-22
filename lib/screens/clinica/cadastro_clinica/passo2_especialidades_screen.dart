import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../repositories/clinica_auth_repository.dart';
import '../../../session/sessao_clinica.dart';
import 'passo3_medicos_screen.dart';

class Passo2EspecialidadesScreen extends StatefulWidget {
  const Passo2EspecialidadesScreen({super.key});

  @override
  State<Passo2EspecialidadesScreen> createState() =>
      _Passo2EspecialidadesScreenState();
}

class _Passo2EspecialidadesScreenState
    extends State<Passo2EspecialidadesScreen> {
  List<Map<String, dynamic>> _todasEspecialidades = [];
  final List<int> _selecionadas = []; // ids selecionados
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarEspecialidades();
  }

  Future<void> _carregarEspecialidades() async {
    final lista = await ClinicaAuthRepository.buscarTodasEspecialidades();
    setState(() {
      _todasEspecialidades = lista;
      _carregando = false;
    });
  }

  void _proximo() async {
    if (_selecionadas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione ao menos uma especialidade (obrigatório)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await ClinicaAuthRepository.salvarEspecialidades(
      clinicaId: SessaoClinica.id!,
      especialidadeIds: _selecionadas,
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Passo3MedicosScreen(
            especialidadeIds: _selecionadas,
            todasEspecialidades: _todasEspecialidades,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const CircleAvatar(
            backgroundColor: Color(0xFFF0F0F0),
            radius: 16,
            child: Icon(Icons.chevron_left, color: Colors.black, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'INÍCIO',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
      ),
      body: _carregando
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.greenPrimary),
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ESPECIALIDADES',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '*OBRIGATÓRIO',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.red,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _todasEspecialidades.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final esp = _todasEspecialidades[index];
                        final id = esp['id'] as int;
                        final nome = esp['nome'] as String;
                        final selecionado = _selecionadas.contains(id);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selecionado) {
                                _selecionadas.remove(id);
                              } else {
                                _selecionadas.add(id);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: selecionado
                                  ? AppTheme.greenPrimary.withOpacity(0.1)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: selecionado
                                    ? AppTheme.greenPrimary
                                    : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    nome,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: selecionado
                                          ? AppTheme.greenPrimary
                                          : Colors.black87,
                                      fontWeight: selecionado
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (selecionado)
                                  const Icon(
                                    Icons.check,
                                    color: AppTheme.greenPrimary,
                                    size: 18,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 120,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _proximo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.greenPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'PRÓXIMO',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
