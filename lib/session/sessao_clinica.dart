class SessaoClinica {
  static int? id;
  static String? email;
  static String? razaoSocial;

  static void iniciar(Map<String, dynamic> clinica) {
    id = clinica['id'];
    email = clinica['email'];
    razaoSocial = clinica['razao_social'];
  }

  static void encerrar() {
    id = null;
    email = null;
    razaoSocial = null;
  }

  static bool get estaLogada => id != null;
}
