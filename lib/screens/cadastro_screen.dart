import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../repositories/usuario_repository.dart';
import '../repositories/clinica_auth_repository.dart';
import '../session/sessao_clinica.dart';
import 'clinica/home_clinica_screen.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _emailController = TextEditingController();
  final _nomeController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _isPessoaJuridica = false; // controla o toggle

  @override
  void dispose() {
    _emailController.dispose();
    _nomeController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  void _cadastrar() async {
    final email = _emailController.text.trim();
    final nome = _nomeController.text.trim();
    final senha = _senhaController.text;
    final confirmar = _confirmarSenhaController.text;

    if (email.isEmpty || nome.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    if (senha != confirmar) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('As senhas não coincidem')));
      return;
    }

    if (_isPessoaJuridica) {
      // Cadastro da clínica
      final id = await ClinicaAuthRepository.cadastrar(
        email: email,
        senha: senha,
      );

      if (id != null) {
        // Inicia sessão da clínica e vai para o painel
        SessaoClinica.iniciar({'id': id, 'email': email, 'razao_social': ''});
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeClinicaScreen()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Email já cadastrado')));
      }
    } else {
      // Cadastro pessoa física (já existia)
      final id = await UsuarioRepository.cadastrar(
        nome: nome,
        email: email,
        senha: senha,
      );

      if (id != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado! Faça login.')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Email já cadastrado')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF0D5C35), Color(0xFF0A0A0A)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Icon(
                    Icons.monitor_heart_outlined,
                    color: AppTheme.greenPrimary,
                    size: 52,
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Med',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: 'Vita',
                          style: TextStyle(
                            color: AppTheme.greenPrimary,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildTextField(
                    controller: _emailController,
                    label: 'E-MAIL',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nomeController,
                    // Muda o label conforme o tipo
                    label: _isPessoaJuridica ? 'RAZÃO SOCIAL' : 'NOME',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _senhaController,
                    label: 'SENHA',
                    obscure: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _confirmarSenhaController,
                    label: 'CONFIRMAR SENHA',
                    obscure: true,
                  ),

                  const SizedBox(height: 16),

                  // Toggle Pessoa Física / Jurídica
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPessoaJuridica = !_isPessoaJuridica;
                      });
                    },
                    child: Text(
                      _isPessoaJuridica
                          ? 'SOU PESSOA FÍSICA'
                          : 'SOU PESSOA JURÍDICA',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        letterSpacing: 1.2,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white70,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _cadastrar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.greenPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'CADASTRAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, letterSpacing: 1),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white70,
          letterSpacing: 1.5,
          fontSize: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.greenPrimary, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
    );
  }
}
