class SolicitacaoDto {
  SolicitacaoDto({
    required this.id,
    required this.origem,
    required this.destino,
    required this.dataHora,
    required this.passageirosPrevistos,
    required this.status,
    this.observacao,
    this.veiculo,
    this.motorista,
  });

  final int id;
  final String origem;
  final String destino;
  final String dataHora;
  final int passageirosPrevistos;
  final String status;
  final String? observacao;
  final String? veiculo;
  final String? motorista;

  factory SolicitacaoDto.fromJson(Map<String, dynamic> json) {
    return SolicitacaoDto(
      id: _toInt(json['id']),
      origem: (json['origem'] ?? '').toString(),
      destino: (json['destino'] ?? '').toString(),
      dataHora: (json['data_hora'] ?? json['dataHora'] ?? '').toString(),
      passageirosPrevistos: _toInt(json['passageiros_previstos']),
      status: (json['status'] ?? 'pendente').toString(),
      observacao: json['observacao']?.toString(),
      veiculo: json['veiculo']?.toString(),
      motorista: json['motorista']?.toString(),
    );
  }
}

int _toInt(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
