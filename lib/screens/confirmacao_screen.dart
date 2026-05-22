import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../repositories/usuario_repository.dart';
import '../session/sessao_usuario.dart';

class ConfirmacaoScreen extends StatefulWidget {
  const ConfirmacaoScreen({super.key});

  @override
  State<ConfirmacaoScreen> createState() => _ConfirmacaoScreenState();
}

class _ConfirmacaoScreenState extends State<ConfirmacaoScreen> {
  final _cpfController = TextEditingController();
  final _nascimentoController = TextEditingController();

  @override
  void dispose() {
    _cpfController.dispose();
    _nascimentoController.dispose();
    super.dispose();
  }

  void _confirmar() async {
    final cpf = _cpfController.text.trim();
    final nascimento = _nascimentoController.text.trim();

    if (cpf.isEmpty || nascimento.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    // Usa o id do usuário logado que está na sessão
    final sucesso = await UsuarioRepository.confirmarCadastro(
      usuarioId: SessaoUsuario.id!,
      cpf: cpf,
      nascimento: nascimento,
    );

    if (sucesso) {
      // Atualiza a sessão para refletir que já confirmou
      SessaoUsuario.cadastroConfirmado = true;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro confirmado com sucesso!')),
      );

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('CPF já cadastrado')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo verde claro como na imagem
      backgroundColor: const Color(0xFFD4F5E2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Botão de voltar no canto esquerdo
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              const SizedBox(height: 10),

              // Logo com fundo escuro (como na imagem)
              Container(
                width: 140,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1F1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.monitor_heart_outlined,
                      color: AppTheme.greenPrimary,
                      size: 36,
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Med',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: 'Vita',
                            style: TextStyle(
                              color: AppTheme.greenPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'saúde na palma da sua mão',
                      style: TextStyle(color: Colors.white54, fontSize: 8),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Título
              const Text(
                'CONFIRMAÇÃO DE USUÁRIO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 32),

              // Campo CPF
              _buildCampoClaro(
                controller: _cpfController,
                label: 'DIGITE SEU CPF',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              // Campo Data de Nascimento
              _buildCampoClaro(
                controller: _nascimentoController,
                label: 'DATA DE NASCIMENTO',
                keyboardType: TextInputType.datetime,
              ),

              const SizedBox(height: 32),

              // Botão CONFIRMAR DADOS
              SizedBox(
                width: 200,
                height: 48,
                child: ElevatedButton(
                  onPressed: _confirmar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.greenPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'CONFIRMAR DADOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1.5,
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

  // Campo de texto com estilo da tela clara (diferente do login)
  Widget _buildCampoClaro({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.greenPrimary.withOpacity(0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.greenPrimary, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
      ),
    );
  }
}
