import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../repositories/usuario_repository.dart';
import '../repositories/clinica_auth_repository.dart';
import '../session/sessao_usuario.dart';
import '../session/sessao_clinica.dart';
import 'home_screen.dart';
import 'cadastro_screen.dart';
import 'clinica/home_clinica_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isPessoaJuridica = false;
  bool _carregando = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _entrar() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      return;
    }

    setState(() => _carregando = true);

    try {
      if (_isPessoaJuridica) {
        final clinica = await ClinicaAuthRepository.login(
          email: email,
          senha: senha,
        );

        setState(() => _carregando = false);

        if (clinica != null) {
          SessaoClinica.iniciar(clinica);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeClinicaScreen()),
          );
        } else {
          // Mostra mensagem específica em vez de travar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email ou senha incorretos'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        final usuario = await UsuarioRepository.login(
          email: email,
          senha: senha,
        );

        setState(() => _carregando = false);

        if (usuario != null) {
          SessaoUsuario.iniciar(usuario);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email ou senha incorretos'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Mostra o erro real na tela em vez de travar
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
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

                  // Logo
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

                  const SizedBox(height: 48),

                  // Campo email
                  _buildTextField(
                    controller: _emailController,
                    label: 'LOGIN',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  // Campo senha
                  _buildTextField(
                    controller: _senhaController,
                    label: 'SENHA',
                    icon: Icons.lock_outline,
                    obscure: true,
                  ),

                  const SizedBox(height: 10),

                  // Esqueci minha senha
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'ESQUECI MINHA SENHA',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Toggle Pessoa Física / Jurídica
                  GestureDetector(
                    onTap: () {
                      setState(() => _isPessoaJuridica = !_isPessoaJuridica);
                      // Limpa os campos ao trocar de tipo
                      _emailController.clear();
                      _senhaController.clear();
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

                  // Botão entrar
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _carregando ? null : _entrar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.greenPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _carregando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'ENTRAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 2,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Cadastre-se
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CadastroScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'CADASTRE-SE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1.5,
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
    required IconData icon,
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
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
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
