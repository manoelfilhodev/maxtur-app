enum FuncionarioFeedbackTipo {
  sugestao,
  critica,
}

class FuncionarioFeedbackDto {
  FuncionarioFeedbackDto({
    required this.tipo,
    required this.mensagem,
  });

  final FuncionarioFeedbackTipo tipo;
  final String mensagem;

  String get tipoApi {
    switch (tipo) {
      case FuncionarioFeedbackTipo.sugestao:
        return 'sugestao';
      case FuncionarioFeedbackTipo.critica:
        return 'critica';
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'tipo': tipoApi,
      'mensagem': mensagem.trim(),
    };
  }
}
