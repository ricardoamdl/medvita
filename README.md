# 🏥 MedVita — Saúde na Palma da Sua Mão

<p align="center">
  <span style="font-size: 48px;">❤️📅</span><br/>
  <strong style="font-size: 32px; color: #0D5C35;">MedVita</strong>
</p>

<p align="center">
  <b>Aplicativo mobile de agendamento de consultas médicas</b><br/>
  Conectando pacientes e clínicas de forma simples e eficiente
</p>

---

## 📱 Sobre o Projeto

O **MedVita** é um aplicativo mobile desenvolvido como projeto acadêmico para a disciplina de Desenvolvimento Mobile. O app permite que usuários encontrem clínicas, visualizem especialidades disponíveis e agendem consultas médicas diretamente pelo celular — tudo de forma prática e intuitiva.

Clínicas podem se cadastrar como pessoa jurídica, gerenciar médicos, especialidades, horários e agenda diretamente pelo aplicativo.

---

## ✨ Funcionalidades

### 👤 Usuário (Pessoa Física)
- Cadastro e login com autenticação segura (senha criptografada com SHA-256)
- Confirmação de cadastro com CPF e data de nascimento
- Listagem de clínicas disponíveis
- Visualização de especialidades por clínica
- Agendamento de consultas por data e horário
- Bloqueio automático de horários já agendados
- Confirmação de agendamento com resumo completo

### 🏥 Clínica (Pessoa Jurídica)
- Cadastro como pessoa jurídica com fluxo em 5 etapas:
  1. Dados cadastrais (Razão Social, CNPJ, endereço completo)
  2. Seleção de especialidades oferecidas
  3. Cadastro de médicos com valor de consulta
  4. Upload de fotos da clínica
  5. Configuração de dias e horários de atendimento
- Painel administrativo exclusivo

---

## 🛠️ Tecnologias Utilizadas

| Tecnologia | Finalidade |
|---|---|
| Flutter | Framework principal (UI e lógica) |
| Dart | Linguagem de programação |
| SQLite (sqflite) | Banco de dados local |
| crypto (SHA-256) | Criptografia de senhas |
| image_picker | Acesso à galeria do dispositivo |
| path | Gerenciamento de caminhos do banco |

---

## 🗄️ Estrutura do Banco de Dados

O banco foi projetado com **7 tabelas** interligadas:


usuarios          → dados dos pacientes
clinicas          → dados das clínicas (PJ)
especialidades    → especialidades médicas disponíveis
clinica_especialidade → relação entre clínicas e especialidades
medicos           → médicos vinculados às clínicas
horarios          → agenda de horários disponíveis
consultas         → agendamentos realizados

---

## 📁 Estrutura do Projeto

lib/
├── database/
│   └── database_helper.dart       # Conexão e criação do banco
├── models/
│   └── clinica_model.dart         # Model de clínica
├── repositories/
│   ├── usuario_repository.dart    # CRUD de usuários
│   ├── clinica_repository.dart    # Listagem de clínicas
│   ├── clinica_auth_repository.dart # Autenticação PJ + cadastro
│   ├── horario_repository.dart    # Gerenciamento de horários
│   └── consulta_repository.dart   # Agendamentos
├── session/
│   ├── sessao_usuario.dart        # Sessão do usuário logado
│   └── sessao_clinica.dart        # Sessão da clínica logada
├── theme/
│   └── app_theme.dart             # Cores e tema global
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── cadastro_screen.dart
│   ├── home_screen.dart
│   ├── confirmacao_screen.dart
│   ├── clinica_detalhe_screen.dart
│   ├── agendamento_screen.dart
│   ├── confirmacao_agendamento_screen.dart
│   └── clinica/
│       ├── home_clinica_screen.dart
│       └── cadastro_clinica/
│           ├── passo1_dados_screen.dart
│           ├── passo2_especialidades_screen.dart
│           ├── passo3_medicos_screen.dart
│           ├── passo4_fotos_screen.dart
│           └── passo5_agenda_screen.dart
└── widgets/
├── custom_text_field.dart
├── custom_button.dart
└── medvita_logo.dart


---

## 🎨 Identidade Visual

- **Paleta de cores:** Preto e verde marinho escuro (`#0D5C35`)
- **Destaque:** Verde vibrante (`#1DB954`)
- **Tipografia:** Clean e moderna
- **Logo:** Linha de batimento cardíaco + ícone de calendário

---

## 🚀 Como Rodar o Projeto

### Pré-requisitos
- Flutter SDK instalado
- Android Studio ou VS Code
- Dispositivo Android ou emulador

### Passo a passo

```bash
# Clone o repositório
git clone https://github.com/ricardoamdl/medvita

# Entre na pasta
cd medvita

# Instale as dependências
flutter pub get

# Rode o app
flutter run
```

---

## 📋 Dependências

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  sqflite: ^2.3.0
  path: ^1.8.3
  crypto: ^3.0.3
  image_picker: ^1.0.7
```

---

## 🔐 Segurança

- Senhas armazenadas com hash **SHA-256** — nunca em texto puro
- Sessão de usuário mantida em memória durante o uso
- Horários bloqueados via **transação atômica** no banco, impedindo agendamentos duplicados

---

## 📌 Observações

> ⚠️ O pagamento das consultas é realizado **presencialmente** na clínica. O app serve apenas para agendamento.

> 📱 O app foi desenvolvido e testado para plataforma **Android**.

---

## 🤖 Ferramentas Utilizadas no Desenvolvimento

Este projeto foi desenvolvido com o auxílio do **[Claude](https://claude.ai)** (Anthropic) como ferramenta de apoio ao desenvolvimento — auxiliando na arquitetura do código, resolução de erros, estruturação do banco de dados e geração dos componentes Flutter ao longo de todo o ciclo de desenvolvimento.

---

## 👨‍💻 Desenvolvido por

**Ricardo Augusto**  
Estudante de Desenvolvimento Mobile  
📧 ricardoamdl3@gmail.com
---

## 📄 Licença

Este projeto foi desenvolvido para fins acadêmicos.

---

<p align="center">
  Feito com 💚 e muito Flutter
</p>