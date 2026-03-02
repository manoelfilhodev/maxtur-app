class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  // Auth
  static const String loginPath = '/api/auth/login';
  static const String mePath = '/api/me';

  // Checklist (motorista)
  static const String checklistsVeiculosPath = '/api/checklists/veiculos';
  static const String checklistIniciarPath = '/api/checklists/iniciar';
  static String checklistDetailPath(int id) => '/api/checklists/$id';
  static String checklistRespostasPath(int id) => '/api/checklists/$id/respostas';
  static String checklistFinalizarPath(int id) => '/api/checklists/$id/finalizar';

  // Cliente solicitacoes
  static const String clienteSolicitacoesPath = '/api/cliente/solicitacoes';

  // Funcionario
  static const String funcionarioTripActivePath = '/api/app/funcionario/trip/active';
  static const String funcionarioFeedbackPath = '/api/app/funcionario/feedback';

  // Admin / notificacoes
  static const String notificationsPath = '/api/notifications';
  static String notificationReadPath(int id) => '/api/notifications/$id/read';
  static String adminSolicitacaoStatusPath(int id) => '/api/admin/solicitacoes/$id/status';
  static String adminSolicitacaoAtribuirPath(int id) => '/api/admin/solicitacoes/$id/atribuir';

  // Compatibilidade legado
  static const String checklistsPath = '/api/v1/checklists';
  static const String funcionariosPath = '/api/v1/viagens/funcionarios';
  static const String viagensSolicitacoesPath = '/api/v1/viagens/solicitacoes';
  static const String viagensMinhasPath = '/api/v1/viagens/minhas';
}
