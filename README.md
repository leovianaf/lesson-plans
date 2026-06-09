# Avaliador de Planos de Aula

Aplicação Rails para apoiar a avaliação humana de planos de aula e comparar respostas geradas por múltiplos modelos de IA.

O fluxo principal é:
1. importar um conjunto de planos e avaliações automáticas a partir de um CSV;
2. autenticar um professor avaliador;
3. apresentar um plano por vez com avaliações de IA embaralhadas;
4. registrar a escolha humana e observações;
5. consultar o histórico das avaliações realizadas.

## Stack

- Ruby 3.3.6
- Rails 8.1
- PostgreSQL
- Hotwire (`turbo-rails`, `stimulus-rails`)
- Tailwind CSS v4 via `tailwindcss-rails`

## Rotas e endpoints

Todas as rotas abaixo, exceto login, recuperação de senha e healthcheck, exigem autenticação.

### Healthcheck
- `GET /up`
- Controller: `Rails::HealthController#show`
- Uso: verificação simples de disponibilidade da aplicação

### Sessão
- `GET /session/new`
- Controller: `SessionsController#new`
- Uso: tela de login

- `POST /session`
- Controller: `SessionsController#create`
- Params esperados:
  - `email_address`
  - `password`
- Uso: autenticar usuário

- `DELETE /session`
- Controller: `SessionsController#destroy`
- Uso: encerrar sessão

### Recuperação de senha
- `GET /passwords/new`
- Controller: `PasswordsController#new`
- Uso: tela para solicitar reset de senha

- `POST /passwords`
- Controller: `PasswordsController#create`
- Params esperados:
  - `email_address`
- Uso: enviar instruções de redefinição

- `GET /passwords/:token/edit`
- Controller: `PasswordsController#edit`
- Uso: formulário de redefinição de senha

- `PATCH /passwords/:token`
- Controller: `PasswordsController#update`
- Params esperados:
  - `password`
  - `password_confirmation`
- Uso: efetivar redefinição de senha

### Avaliação de planos
- `GET /`
- Controller: `LessonPlansController#evaluate_next`
- Query params opcionais:
  - `discipline`
- Uso: buscar o próximo plano ainda não avaliado para uma disciplina

- `PATCH /save_evaluation/:id`
- Controller: `LessonPlansController#save_evaluation`
- Params esperados:
  - `chosen_llm_evaluation_id`
  - `observation`
- Uso: salvar a escolha humana para o plano

- `GET /historico`
- Controller: `LessonPlansController#history`
- Query params opcionais:
  - `query`
- Uso: listar avaliações já realizadas pelo usuário autenticado

## Setup local

### Pré-requisitos

- Ruby 3.3.6
- Bundler
- PostgreSQL
- Node.js não é obrigatório para o fluxo principal, já que o projeto usa import maps e Tailwind via Rails

### Variáveis de ambiente

Arquivo de exemplo: [.env.example](/home/leovianaf/projetos/aibox/avaliador_planos/.env.example:1)

Variáveis reconhecidas pelo banco:
- `DB_HOST`
- `DB_USER`
- `DB_PASSWORD`

Por padrão, o app tenta conectar em:
- host: `127.0.0.1`
- usuário: `postgres`
- senha: vazia

### Bootstrap

Para instalar dependências e preparar o banco:

```bash
bin/setup
```

O script:
- instala gems
- roda `bin/rails db:prepare`
- limpa logs e arquivos temporários
- inicia `bin/dev`, salvo se você passar `--skip-server`

### Rodando manualmente

```bash
bin/rails db:migrate
bin/rails db:seed
bin/dev
```

O `Procfile.dev` sobe:
- servidor Rails
- watcher do Tailwind

## Seed por CSV

O seed atual não usa dados sintéticos. Ele importa os registros a partir de um CSV em `db/seeds_data`.

### Local esperado do CSV

O importador procura automaticamente o arquivo mais recente em:

```text
db/seeds_data/*.csv
```

### Serviço de importação

Arquivo: [app/services/csv_lesson_plan_importer.rb](/home/leovianaf/projetos/aibox/avaliador_planos/app/services/csv_lesson_plan_importer.rb:1)

Responsabilidades do serviço:
- ler CSV com `headers: true`
- normalizar BOM no cabeçalho
- mapear cada linha para um `LessonPlan`
- detectar modelos dinamicamente por colunas `*_nota_geral`
- criar `LlmEvaluation` com score geral, scores `d1..d5` e resumo
- reaproveitar `csv_uuid` como chave natural do plano

### Formato esperado do CSV

Campos de plano identificados atualmente:
- `uuid`
- `titulo`
- `disciplina`
- `tema`
- `habilidades_bncc`
- `serie_escolar`
- `objetivos`
- `materiais`
- `etapas`
- `duracao`
- `url`
- `url_key`
- `conteudo_completo`
- `avaliacao`
- `nivel_bloom`

Campos de avaliação por modelo:
- `{modelo}_nota_geral`
- `{modelo}_resumo`
- `{modelo}_d1`
- `{modelo}_d2`
- `{modelo}_d3`
- `{modelo}_d4`
- `{modelo}_d5`

Exemplo:
- `gpt_5_mini_nota_geral`
- `gpt_5_mini_resumo`
- `gpt_5_mini_d1`
- `deepseek_chat_nota_geral`

### Rodando apenas a importação

Hoje o `db:seed` já chama o serviço. Se quiser testar em console/runner:

```bash
bin/rails runner 'CsvLessonPlanImporter.call'
```

Ou apontando um arquivo específico:

```bash
bin/rails runner 'CsvLessonPlanImporter.call(csv_path: "db/seeds_data/meu_arquivo.csv")'
```

## Usuário inicial

O seed cria um usuário padrão para acesso manual:

- email: `professor@teste.com`
- senha: `admin`

## Testes e validações

### Testes

```bash
bin/rails test
```

### Segurança

```bash
bundle exec bundler-audit check --update
bin/brakeman --no-pager
```

## Estrutura relevante do projeto

```text
app/
  controllers/
  models/
  services/
  views/
db/
  migrate/
  seeds.rb
  seeds_data/
config/
  database.yml
  deploy.yml
Procfile.dev
```
