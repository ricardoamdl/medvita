// Classe simples que guarda os dados da sessão em memória
// Quando o app fechar, a sessão é limpa automaticamente
class SessaoUsuario {
  static int? id;
  static String? nome;
  static String? email;
  static bool cadastroConfirmado = false;

  // Preenche a sessão após o login
  static void iniciar(Map<String, dynamic> usuario) {
    id = usuario['id'];
    nome = usuario['nome'];
    email = usuario['email'];
    cadastroConfirmado = usuario['cpf'] != null;
  }

  // Limpa tudo ao fazer logout
  static void encerrar() {
    id = null;
    nome = null;
    email = null;
    cadastroConfirmado = false;
  }
}
