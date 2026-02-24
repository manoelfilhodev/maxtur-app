import 'package:flutter/material.dart';
import 'package:systex_frotas/modules/auth/models/me_dto.dart';
import 'package:systex_frotas/modules/home/screens/home_admin_screen.dart';
import 'package:systex_frotas/modules/home/screens/home_cliente_screen.dart';
import 'package:systex_frotas/modules/home/screens/home_motorista_screen.dart';

Widget buildHomeForRole(MeDto me) {
  if (me.isMotorista) return HomeMotoristaScreen(me: me);
  if (me.isCliente) return HomeClienteScreen(me: me);
  if (me.clienteId != null) return HomeClienteScreen(me: me);
  if (me.isAdmin) return HomeAdminScreen(me: me);
  return HomeAdminScreen(me: me);
}
