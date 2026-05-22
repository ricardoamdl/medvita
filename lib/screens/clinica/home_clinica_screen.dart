import 'package:flutter/material.dart';
import 'cadastro_clinica/passo1_dados_screen.dart';

class HomeClinicaScreen extends StatelessWidget {
  const HomeClinicaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Passo1DadosScreen()),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade400, width: 2),
                ),
                child: Icon(Icons.add, size: 32, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 12),
              Text(
                'Cadastrar clínica',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
