import 'dart:io';
import 'package:flutter/material.dart';
import '../models/clinica_model.dart';
import '../theme/app_theme.dart';
import 'confirmacao_screen.dart';
import 'clinica_detalhe_screen.dart';
import '../session/sessao_usuario.dart';
import '../repositories/clinica_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _buscaController = TextEditingController();
  String _filtroAtivo = 'Clínica geral';

  final List<String> _filtros = [
    'Clínica geral',
    'Odontologia',
    'Urologia',
    'Cardiologia',
    'Pediatria',
  ];

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildBuscaEFiltros(),
          Expanded(child: _buildListaClinicas()),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
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
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  Future<List<ClinicaModel>> _carregarClinicas() async {
    return await ClinicaRepository.buscarTodas();
  }

  Widget _buildListaClinicas() {
    return FutureBuilder<List<ClinicaModel>>(
      future: _carregarClinicas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.greenPrimary),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erro ao carregar clínicas',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_hospital_outlined,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma clínica cadastrada',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                ),
              ],
            ),
          );
        }

        final clinicas = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: clinicas.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildCardClinica(clinicas[index]);
          },
        );
      },
    );
  }

  Widget _buildBuscaEFiltros() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          TextField(
            controller: _buscaController,
            style: const TextStyle(color: Colors.black, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Buscar clínica...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => _buscaController.clear(),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.greenPrimary),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filtros.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filtro = _filtros[index];
                final ativo = filtro == _filtroAtivo;
                return GestureDetector(
                  onTap: () => setState(() => _filtroAtivo = filtro),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: ativo ? AppTheme.greenPrimary : Colors.transparent,
                      border: Border.all(
                        color: ativo
                            ? AppTheme.greenPrimary
                            : Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      filtro,
                      style: TextStyle(
                        color: ativo ? Colors.white : Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildCardClinica(ClinicaModel clinica) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClinicaDetalheScreen(clinica: clinica),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem da clínica quando disponível, senão decoração padrão
            Container(
              height: 140,
              color: const Color(0xFFB8D9F0),
              child:
                  (clinica.fotoPath.isNotEmpty &&
                      File(clinica.fotoPath).existsSync())
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      child: Image.file(
                        File(clinica.fotoPath),
                        width: double.infinity,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Stack(
                      children: [
                        Container(color: const Color(0xFFB8D9F0)),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: CustomPaint(
                            size: const Size(double.infinity, 60),
                            painter: _ColinaPainter(),
                          ),
                        ),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clinica.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    clinica.especialidade,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildEstrelas(clinica.avaliacao),
                      const SizedBox(width: 4),
                      Text(
                        '${clinica.avaliacao}(${clinica.totalAvaliacoes})',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.location_on,
                        color: Colors.blue,
                        size: 14,
                      ),
                      Text(
                        '${clinica.distanciaKm} km',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstrelas(double avaliacao) {
    return Row(
      children: List.generate(5, (index) {
        if (index < avaliacao.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 14);
        } else if (index < avaliacao) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 14);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 14);
        }
      }),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.grey.shade300,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.grey.shade400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Mostra o nome do usuário logado
                  Text(
                    SessaoUsuario.nome ?? '',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.black54),
              title: const Text(
                'Meus Dados',
                style: TextStyle(color: Colors.black87),
              ),
              onTap: () {
                Navigator.pop(context);
                if (!SessaoUsuario.cadastroConfirmado) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConfirmacaoScreen(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cadastro já confirmado!')),
                  );
                }
              },
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}

class _ColinaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF5A9E3A);
    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.25,
      0,
      size.width * 0.5,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.8,
      size.width,
      size.height * 0.3,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);

    final paint2 = Paint()..color = const Color(0xFF3D7A25);
    final path2 = Path();
    path2.moveTo(0, size.height * 0.9);
    path2.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.5,
      size.width * 0.6,
      size.height * 0.75,
    );
    path2.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.9,
      size.width,
      size.height * 0.65,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
