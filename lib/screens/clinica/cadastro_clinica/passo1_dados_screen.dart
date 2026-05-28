import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../repositories/clinica_auth_repository.dart';
import '../../../session/sessao_clinica.dart';
import 'passo2_especialidades_screen.dart';

class Passo1DadosScreen extends StatefulWidget {
  const Passo1DadosScreen({super.key});

  @override
  State<Passo1DadosScreen> createState() => _Passo1DadosScreenState();
}

class _Passo1DadosScreenState extends State<Passo1DadosScreen> {
  final _razaoSocialController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();

  bool _salvando = false;

  @override
  void dispose() {
    _razaoSocialController.dispose();
    _cnpjController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _bairroController.dispose();
    _ruaController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    super.dispose();
  }

  void _proximo() async {
    // Validação — todos obrigatórios exceto complemento
    if (_razaoSocialController.text.trim().isEmpty ||
        _cnpjController.text.trim().isEmpty ||
        _cidadeController.text.trim().isEmpty ||
        _estadoController.text.trim().isEmpty ||
        _bairroController.text.trim().isEmpty ||
        _ruaController.text.trim().isEmpty ||
        _numeroController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios')),
      );
      return;
    }

    setState(() => _salvando = true);

    final sucesso = await ClinicaAuthRepository.salvarDadosBasicos(
      clinicaId: SessaoClinica.id!,
      razaoSocial: _razaoSocialController.text.trim(),
      cnpj: _cnpjController.text.trim(),
      cidade: _cidadeController.text.trim(),
      estado: _estadoController.text.trim(),
      bairro: _bairroController.text.trim(),
      rua: _ruaController.text.trim(),
      numero: _numeroController.text.trim(),
      complemento: _complementoController.text.trim(),
    );

    setState(() => _salvando = false);

    if (sucesso && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Passo2EspecialidadesScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar. Tente novamente.')),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildCampo(_razaoSocialController, 'razão social'),
            _buildCampo(_cnpjController, 'CNPJ', tipo: TextInputType.number),
            // Label endereço
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
                child: Text(
                  'endereço',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ),
            ),
            _buildCampo(_cidadeController, 'cidade'),
            _buildCampo(_estadoController, 'estado'),
            _buildCampo(_bairroController, 'bairro'),
            _buildCampo(_ruaController, 'rua'),
            _buildCampo(
              _numeroController,
              'número',
              tipo: TextInputType.number,
            ),
            _buildCampo(_complementoController, 'complemento'),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 120,
                height: 44,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _proximo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.greenPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _salvando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
        style: const TextStyle(color: Colors.black, fontSize: 14),
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
      ),
    );
  }
}
