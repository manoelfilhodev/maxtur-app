import 'package:flutter/material.dart';
import 'package:systex_frotas/core/widgets/dg_toast.dart';
import 'package:systex_frotas/modules/auth/models/me_dto.dart';
import 'package:systex_frotas/modules/auth/models/role_type.dart';
import 'package:systex_frotas/modules/auth/screens/login_screen.dart';
import 'package:systex_frotas/modules/auth/services/auth_storage.dart';
import 'package:systex_frotas/modules/funcionario/screens/home_funcionario_screen.dart';
import 'package:systex_frotas/modules/home/screens/home_admin_screen.dart';
import 'package:systex_frotas/modules/home/screens/home_cliente_screen.dart';
import 'package:systex_frotas/modules/home/screens/home_motorista_screen.dart';

class AuthRouteGuard {
  static RoleType resolveRole(MeDto me) {
    final parsed = RoleParser.parse(me.role);
    if (parsed != RoleType.unknown) return parsed;
    if (me.clienteId != null) return RoleType.clientUser;
    return RoleType.unknown;
  }

  static Widget? resolveHome(MeDto me) {
    switch (resolveRole(me)) {
      case RoleType.master:
        return HomeAdminScreen(me: me);
      case RoleType.clientAdmin:
      case RoleType.clientUser:
        return HomeClienteScreen(me: me);
      case RoleType.funcionario:
        return HomeFuncionarioScreen(me: me);
      case RoleType.motorista:
        return HomeMotoristaScreen(me: me);
      case RoleType.unknown:
        return null;
    }
  }

  static Future<void> goPostAuth(
    BuildContext context,
    MeDto me, {
    bool clearStack = true,
  }) async {
    final destination = resolveHome(me);
    if (destination == null) {
      await AuthStorage.clearSession(clearProfile: false);
      if (!context.mounted) return;
      DgToast.show(context, 'Perfil de acesso não reconhecido. Faça login novamente.', isError: true);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      return;
    }

    if (!context.mounted) return;
    if (clearStack) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => destination),
        (route) => false,
      );
      return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => destination));
  }
}
