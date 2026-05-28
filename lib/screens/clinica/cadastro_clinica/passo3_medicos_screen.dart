import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../repositories/clinica_auth_repository.dart';
import '../../../session/sessao_clinica.dart';
import 'passo4_fotos_screen.dart';

class Passo3MedicosScreen extends StatefulWidget {
  final List<int> especialidadeIds;
  final List<Map<String, dynamic>> todasEspecialidades;

  const Passo3MedicosScreen({
    super.key,
    required this.especialidadeIds,
    required this.todasEspecialidades,
  });

  @override
  State<Passo3MedicosScreen> createState() => _Passo3MedicosScreenState();
}

class _Passo3MedicosScreenState extends State<Passo3MedicosScreen> {
  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();
  int? _especialidadeSelecionadaId;

  // Lista de médicos adicionados na sessão atual
  final List<Map<String, dynamic>> _medicosCadastrados = [];
  bool _salvando = false;

  // Apenas as especialidades que a clínica selecionou no passo 2
  List<Map<String, dynamic>> get _especialidadesDaClinica {
    return widget.todasEspecialidades
        .where((e) => widget.especialidadeIds.contains(e['id'] as int))
        .toList();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _adicionarMedico() async {
    final nome = _nomeController.text.trim();
    final valorText = _valorController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Informe o nome do médico')));
      return;
    }

    if (_especialidadeSelecionadaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a especialidade')),
      );
      return;
    }

    if (valorText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o valor da consulta')),
      );
      return;
    }

    final valor = double.tryParse(valorText.replaceAll(',', '.')) ?? 0.0;

    setState(() => _salvando = true);

    final sucesso = await ClinicaAuthRepository.salvarMedico(
      clinicaId: SessaoClinica.id!,
      nome: nome,
      especialidadeId: _especialidadeSelecionadaId!,
      valorConsulta: valor,
    );

    setState(() => _salvando = false);

    if (sucesso) {
      // Acha o nome da especialidade selecionada
      final nomeEsp = _especialidadesDaClinica.firstWhere(
        (e) => e['id'] == _especialidadeSelecionadaId,
      )['nome'];

      setState(() {
        _medicosCadastrados.add({
          'nome': nome,
          'especialidade': nomeEsp,
          'valor': valor,
        });
        // Limpa os campos para adicionar outro
        _nomeController.clear();
        _valorController.clear();
        _especialidadeSelecionadaId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dr(a). $nome adicionado!'),
          backgroundColor: AppTheme.greenPrimary,
        ),
      );
    }
  }

  void _proximo() {
    if (_medicosCadastrados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione ao menos um médico (obrigatório)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const Passo4FotosScreen()),
    );
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MÉDICOS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              '*OBRIGATÓRIO — adicione ao menos 1',
              style: TextStyle(
                fontSize: 11,
                color: Colors.red,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),

            // Campo nome do médico
            _buildCampo(_nomeController, 'nome do médico'),
            const SizedBox(height: 12),

            // Dropdown especialidade
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _especialidadeSelecionadaId,
                  isExpanded: true,
                  hint: Text(
                    'especialidade',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                  items: _especialidadesDaClinica
                      .map(
                        (e) => DropdownMenuItem<int>(
                          value: e['id'] as int,
                          child: Text(
                            e['nome'] as String,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _especialidadeSelecionadaId = val),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Campo valor
            _buildCampo(
              _valorController,
              'valor da consulta (R\$)',
              tipo: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Botão adicionar médico
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: _salvando ? null : _adicionarMedico,
                icon: _salvando
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.greenPrimary,
                        ),
                      )
                    : const Icon(Icons.add, color: AppTheme.greenPrimary),
                label: const Text(
                  'Adicionar médico',
                  style: TextStyle(color: AppTheme.greenPrimary),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.greenPrimary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            // Lista de médicos já adicionados
            if (_medicosCadastrados.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Médicos adicionados:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              ..._medicosCadastrados.map(
                (m) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.greenPrimary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.greenPrimary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: AppTheme.greenPrimary,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m['nome'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${m['especialidade']} — R\$ ${(m['valor'] as double).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
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

  Widget _buildCampo(
    TextEditingController controller,
    String label, {
    TextInputType tipo = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
      ),
    );
  }
}
