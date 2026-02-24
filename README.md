# Maxtur App (Flutter)

Aplicativo Flutter do ecossistema Maxtur, com autenticação por perfil e integração com a API Laravel.

## Repositórios

- App Flutter: `https://github.com/manoelfilhodev/maxtur-app`
- API Laravel: `https://github.com/manoelfilhodev/maxtur-sistema`

## Perfis suportados

- `motorista`
- `cliente`
- `admin`

O app roteia automaticamente após login com base no retorno de `GET /api/me`.

## Stack

- Flutter (Dart)
- Dio (HTTP client)
- Hive + Secure Storage (sessão/token)
- UI Dark/Glass custom

## Estrutura principal

```text
lib/
  core/
    api/
    storage/
    theme/
    widgets/
  modules/
    auth/
    checklist/
    solicitacoes/
    notificacoes/
    home/
```

## Pré-requisitos

- Flutter SDK instalado
- API Laravel rodando localmente

## Configuração local

### 1) Subir API Laravel

No projeto Laravel:

```bash
php artisan optimize:clear
php artisan serve --host=localhost --port=8000
```

### 2) CORS (Laravel)

Em `config/cors.php`, garantir:

```php
'paths' => ['api/*', 'login', 'sanctum/csrf-cookie'],
```

### 3) Rodar Flutter

```bash
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

Se não passar `--dart-define`, o app usa por padrão:

```text
http://localhost:8000
```

## Endpoints esperados (API)

- `POST /api/auth/login`
- `GET /api/me`
- `POST /api/checklists/iniciar`
- `POST /api/checklists/{id}/respostas`
- `POST /api/checklists/{id}/finalizar`
- `POST /api/cliente/solicitacoes`
- `GET /api/cliente/solicitacoes`
- `GET /api/notifications`
- `PATCH /api/notifications/{id}/read`
- `PATCH /api/admin/solicitacoes/{id}/status`
- `PATCH /api/admin/solicitacoes/{id}/atribuir`

## Qualidade

```bash
flutter analyze
flutter test
```

## Observações

- Erro `419` no login normalmente indica rota web com CSRF (`/login`). O app usa rota de API (`/api/auth/login`).
- Em Flutter Web, erro `connection error` costuma indicar CORS ou API offline.
