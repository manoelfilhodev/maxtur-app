class Funcionario {
  Funcionario({required this.id, required this.nome, required this.telefone, required this.endereco});

  final int id;
  final String nome;
  final String telefone;
  final String endereco;

  factory Funcionario.fromJson(Map<String, dynamic> json) {
    return Funcionario(
      id: _toInt(json['id']),
      nome: (json['nome'] ?? '').toString(),
      telefone: (json['telefone'] ?? '').toString(),
      endereco: (json['endereco'] ?? '').toString(),
    );
  }

  static int _toInt(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
}

class ViagemSolicitacao {
  ViagemSolicitacao({
    required this.id,
    required this.data,
    required this.hora,
    required this.rota,
    required this.endereco,
    required this.telefone,
    required this.empresa,
    required this.status,
    required this.createdAt,
    required this.funcionarioId,
    required this.funcionarioNome,
  });

  final int id;
  final String data;
  final String hora;
  final String rota;
  final String endereco;
  final String telefone;
  final String empresa;
  final String status;
  final String createdAt;
  final int funcionarioId;
  final String funcionarioNome;

  factory ViagemSolicitacao.fromJson(Map<String, dynamic> json) {
    return ViagemSolicitacao(
      id: _toInt(json['id']),
      data: (json['data'] ?? '').toString(),
      hora: (json['hora'] ?? '').toString(),
      rota: (json['rota'] ?? '').toString(),
      endereco: (json['endereco'] ?? '').toString(),
      telefone: (json['telefone'] ?? '').toString(),
      empresa: (json['empresa'] ?? '').toString(),
      status: (json['status'] ?? 'pendente').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
      funcionarioId: _toInt(json['funcionario_id']),
      funcionarioNome: (json['funcionario_nome'] ?? json['funcionario']?['nome'] ?? '').toString(),
    );
  }

  static int _toInt(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
}
