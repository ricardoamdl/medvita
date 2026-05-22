import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../theme/app_theme.dart';
import '../../../repositories/clinica_auth_repository.dart';
import '../../../session/sessao_clinica.dart';
import 'passo5_agenda_screen.dart';

class Passo4FotosScreen extends StatefulWidget {
  const Passo4FotosScreen({super.key});

  @override
  State<Passo4FotosScreen> createState() => _Passo4FotosScreenState();
}

class _Passo4FotosScreenState extends State<Passo4FotosScreen> {
  final _descricaoController = TextEditingController();
  File? _fotoSelecionada;
  bool _salvando = false;

  Future<void> _selecionarFoto() async {
    // Pede permissão e abre a galeria do aparelho
    final picker = ImagePicker();
    final imagem = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // comprime para não ocupar muito espaço
    );

    if (imagem != null) {
      setState(() => _fotoSelecionada = File(imagem.path));
    }
  }

  void _proximo() async {
    if (_fotoSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione ao menos uma foto (obrigatório)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _salvando = true);

    await ClinicaAuthRepository.salvarFoto(
      clinicaId: SessaoClinica.id!,
      fotoPath: _fotoSelecionada!.path,
      descricao: _descricaoController.text.trim(),
    );

    setState(() => _salvando = false);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Passo5AgendaScreen()),
      );
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Text(
              'adicionar imagens',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 32),

            // Área de seleção de foto
            GestureDetector(
              onTap: _selecionarFoto,
              child: Container(
                width: 160,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _fotoSelecionada != null
                    // Mostra a foto selecionada
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_fotoSelecionada!, fit: BoxFit.cover),
                      )
                    // Placeholder antes de selecionar
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 52,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'adicionar arquivos\n.jpeg',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 32),

            // Campo descrição
            TextField(
              controller: _descricaoController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'descrição...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.greenPrimary,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 32),

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
}
