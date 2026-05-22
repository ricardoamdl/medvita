import 'package:flutter/material.dart';
import '../models/clinica_model.dart';
import 'agendamento_screen.dart';

class ClinicaDetalheScreen extends StatelessWidget {
  final ClinicaModel clinica;

  const ClinicaDetalheScreen({super.key, required this.clinica});

  // Mapa de ícones por especialidade
  // Quando vier do banco, os emojis/ícones são escolhidos pelo nome
  static const _iconeEspecialidade = {
    'clínico geral': {
      'icon': Icons.medical_services,
      'color': Color(0xFF4FC3F7),
    },
    'cardiologista': {'icon': Icons.favorite, 'color': Color(0xFF4FC3F7)},
    'pediatria': {'icon': Icons.child_care, 'color': Color(0xFF4FC3F7)},
    'odontologia': {
      'icon': Icons.medical_information,
      'color': Color(0xFF4FC3F7),
    },
    'urologia': {'icon': Icons.local_hospital, 'color': Color(0xFF4FC3F7)},
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── Header colapsável com imagem das colinas ──
          SliverAppBar(
            expandedHeight: 200,
            pinned: true, // AppBar fica fixo ao rolar
            backgroundColor: const Color(0xFFB8D9F0),
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 16,
                child: Icon(Icons.chevron_left, color: Colors.black, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Fundo azul céu
                  Container(color: const Color(0xFFB8D9F0)),
                  // Nuvens decorativas
                  Positioned(top: 40, left: 40, child: _buildNuvem(80, 30)),
                  Positioned(top: 30, right: 60, child: _buildNuvem(60, 22)),
                  // Colinas verdes
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: CustomPaint(
                      size: const Size(double.infinity, 80),
                      painter: _ColinaPainter(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Conteúdo rolável ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome da clínica
                  Text(
                    clinica.nome,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Estrelas + avaliação
                  Row(
                    children: [
                      _buildEstrelas(clinica.avaliacao),
                      const SizedBox(width: 6),
                      Text(
                        '${clinica.avaliacao} (${clinica.totalAvaliacoes})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Endereço
                  _buildInfoRow(
                    icon: Icons.location_on,
                    iconColor: Colors.blue,
                    // Quando vier do banco substitua por clinica.endereco
                    texto: clinica.endereco.isNotEmpty
                        ? '${clinica.endereco} - ${clinica.cidade}'
                        : 'Endereço não informado',
                  ),
                  const SizedBox(height: 8),

                  // Horário
                  _buildInfoRow(
                    icon: Icons.access_time,
                    iconColor: Colors.grey,
                    texto: clinica.horario.isNotEmpty
                        ? clinica.horario
                        : 'Horário não informado',
                  ),

                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Título especialidades
                  const Text(
                    'especialidades',
                    style: TextStyle(fontSize: 20, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),

                  // Grid de especialidades
                  _buildGridEspecialidades(),

                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Mapa placeholder
                  _buildMapaPlaceholder(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Linha de info (endereço / horário) ──────────────
  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String texto,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  // ── Grid de especialidades ──────────────────────────
  Widget _buildGridEspecialidades() {
    // Se ainda não tem especialidades no banco, mostra placeholder
    final lista = clinica.especialidades.isNotEmpty
        ? clinica.especialidades
        : ['clínico geral', 'cardiologista', 'pediatria', 'odontologia'];

    return GridView.builder(
      shrinkWrap: true, // importante dentro de scroll
      physics: const NeverScrollableScrollPhysics(), // desativa scroll do grid
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 colunas
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1, // quadrado
      ),
      itemCount: lista.length,
      itemBuilder: (context, index) {
        return _buildCardEspecialidade(context, lista[index]);
      },
    );
  }

  Widget _buildCardEspecialidade(BuildContext context, String nome) {
    final dados = _iconeEspecialidade[nome.toLowerCase()];
    final icone = (dados?['icon'] as IconData?) ?? Icons.local_hospital;

    final corIcone = nome.toLowerCase() == 'cardiologista'
        ? Colors.red
        : Colors.white;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AgendamentoScreen(
              especialidade: nome,
              clinicaId: clinica.id ?? 0,
              nomeClinica: clinica.nome,
              endereco: clinica.endereco,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF4FC3F7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, color: corIcone, size: 42),
            const SizedBox(height: 10),
            Text(
              nome,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mapa placeholder ────────────────────────────────
  Widget _buildMapaPlaceholder() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Grade simulando mapa
          CustomPaint(
            size: const Size(double.infinity, 150),
            painter: _MapaPainter(),
          ),
          // Ícone de pin no centro
          const Center(
            child: Icon(Icons.location_on, color: Colors.red, size: 32),
          ),
        ],
      ),
    );
  }

  // ── Nuvem decorativa ────────────────────────────────
  Widget _buildNuvem(double largura, double altura) {
    return Container(
      width: largura,
      height: altura,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  // ── Estrelas ────────────────────────────────────────
  Widget _buildEstrelas(double avaliacao) {
    return Row(
      children: List.generate(5, (index) {
        if (index < avaliacao.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        } else if (index < avaliacao) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 16);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 16);
        }
      }),
    );
  }
}

// ── Painter das colinas ─────────────────────────────
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

// ── Painter do mapa simulado ────────────────────────
class _MapaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Linhas horizontais simulando ruas
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Linhas verticais
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Blocos de quarteirão
    final paintBloco = Paint()..color = Colors.grey.shade100;
    canvas.drawRect(const Rect.fromLTWH(45, 35, 70, 55), paintBloco);
    canvas.drawRect(const Rect.fromLTWH(130, 35, 80, 55), paintBloco);
    canvas.drawRect(const Rect.fromLTWH(45, 100, 70, 45), paintBloco);
    canvas.drawRect(const Rect.fromLTWH(225, 65, 60, 50), paintBloco);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
