import 'package:flutter/material.dart';

class TripDraft {
  TripDraft({
    this.origem = 'Empresa',
    this.destino = '',
    this.rotaZona = 'Zona Sul',
    this.rotaOutroTexto,
    this.data,
    this.hora,
    this.funcionarioId,
    this.funcionarioNome,
    this.endereco,
    this.telefone,
    this.empresa = '',
    this.observacao,
    this.solicitanteEmail = '',
    this.solicitanteNome,
  });

  String origem;
  String destino;
  String rotaZona;
  String? rotaOutroTexto;
  DateTime? data;
  TimeOfDay? hora;
  int? funcionarioId;
  String? funcionarioNome;
  String? endereco;
  String? telefone;
  String empresa;
  String? observacao;
  String solicitanteEmail;
  String? solicitanteNome;

  String get rotaFinal {
    final base = '${origem.trim()} -> ${destino.trim()}';
    if (rotaZona == 'Outro') {
      final outro = (rotaOutroTexto ?? '').trim();
      return outro.isEmpty ? base : '$base ($outro)';
    }
    return '$base ($rotaZona)';
  }
}
