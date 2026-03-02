enum RoleType {
  master,
  clientAdmin,
  clientUser,
  funcionario,
  motorista,
  unknown,
}

class RoleParser {
  static RoleType parse(String? rawRole) {
    final roleKey = (rawRole ?? '').toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (roleKey == 'master') return RoleType.master;
    if (roleKey == 'clientadmin') return RoleType.clientAdmin;
    if (roleKey == 'clientuser') return RoleType.clientUser;
    if (roleKey == 'funcionario' || roleKey == 'employee') return RoleType.funcionario;
    if (roleKey == 'motorista' || roleKey == 'driver') return RoleType.motorista;

    // Compatibilidade com roles legados.
    if (roleKey == 'admin' || roleKey == 'administrador' || roleKey == 'operador') return RoleType.master;
    if (roleKey == 'cliente' || roleKey == 'client' || roleKey == 'clientefinal') return RoleType.clientUser;

    return RoleType.unknown;
  }
}
