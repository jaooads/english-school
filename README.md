# English School

English School é um caderno digital compartilhado para as aulas particulares de inglês de João e Camila. A aplicação organiza conteúdo, exercícios, respostas e correções por data, preservando o fluxo simples que antes existia em um documento compartilhado.

## O que existe na V1

- login por e-mail e senha, sem cadastro público na interface;
- perfis `TEACHER` e `STUDENT`;
- aulas agrupadas por mês e ordenadas da mais recente para a mais antiga;
- conteúdo em blocos de texto, grammar, vocabulary, examples e links;
- editor de aulas com ordenação simples dos blocos;
- exercícios de resposta curta ou longa;
- exercícios de assinalar com alternativas A, B, C e D;
- homework usando a mesma estrutura de exercícios;
- respostas parciais que podem ser salvas e retomadas;
- correções com status, resposta correta e comentário da professora;
- visão geral de exercícios com filtros Todos, Pendentes e Corrigidos;
- sidebar no desktop e navegação inferior no celular;
- tabelas editáveis para verbos, vocabulário e outros materiais de estudo.
- deploy preparado para GitHub Pages.

O modelo foi definido após a análise do `Digital English Notebook`. O documento usa a data como principal separador e repete, com frequência, o fluxo explicação → estrutura → exemplos → atividade → resposta → correção. A V1 traduz esse padrão em blocos e atividades sem criar um page builder complexo. O histórico completo não é importado automaticamente.

## Stack

- React 19, TypeScript e Vite;
- Supabase Auth e PostgreSQL;
- Row Level Security (RLS) para permissões;
- GitHub Pages;
- React Router com `HashRouter`, evitando erros de refresh no Pages.

## Requisitos

- Node.js 22 ou mais recente;
- npm;
- um projeto no Supabase.

## Instalação local

```bash
npm install
```

Copie `.env.example` para `.env` e preencha os valores do projeto:

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
```

Use somente a chave pública/anon no frontend. Nunca coloque a `service_role` no `.env` da aplicação ou nos secrets do deploy.

Execute o projeto:

```bash
npm run dev
```

Validações disponíveis:

```bash
npm run typecheck
npm run build
```

## Configuração do Supabase

### 1. Banco e políticas

Execute [`supabase/migrations/202610270001_initial_schema.sql`](supabase/migrations/202610270001_initial_schema.sql) no SQL Editor do Supabase. A migration cria:

- tabelas e tipos;
- índices e timestamps;
- criação automática do perfil de novos usuários;
- políticas RLS;
- funções seguras para o aluno salvar respostas e para a professora corrigir.

As gravações de resposta e correção passam por funções do banco. Assim, João não consegue alterar o status ou o feedback da professora manipulando o frontend.

Depois da migration inicial, execute também as migrations seguintes em ordem cronológica. As mais recentes habilitam:

- [`202611040001_add_multiple_choice_options.sql`](supabase/migrations/202611040001_add_multiple_choice_options.sql): alternativas para questões de assinalar;
- [`202611040002_add_table_blocks.sql`](supabase/migrations/202611040002_add_table_blocks.sql): blocos de tabela nas matérias.

### 2. Authentication

No dashboard do Supabase:

1. mantenha o provider Email habilitado;
2. desabilite novos cadastros públicos nas configurações de Authentication;
3. em **Authentication → Users**, crie manualmente os dois usuários e marque os e-mails como confirmados;
4. crie os usuários somente depois de executar a migration, para que o trigger crie seus perfis.

Use os e-mails reais desejados. Depois, no SQL Editor, associe os nomes e papéis:

```sql
update public.profiles
set name = 'Camila', role = 'TEACHER'
where id = (select id from auth.users where email = 'email-da-camila@exemplo.com');

update public.profiles
set name = 'João', role = 'STUDENT'
where id = (select id from auth.users where email = 'email-do-joao@exemplo.com');
```

Todo perfil novo começa como `STUDENT`. O papel de professora só pode ser atribuído diretamente no banco, evitando elevação de privilégio por metadados de cadastro.

### 3. URLs permitidas

Em **Authentication → URL Configuration**, configure:

- desenvolvimento: `http://localhost:5173`;
- produção: `https://jaooads.github.io/english-school/`.

### 4. Aula representativa opcional

Para validar a interface com conteúdo real, execute manualmente [`supabase/seed.example.sql`](supabase/seed.example.sql) depois de configurar Camila. O seed adiciona somente a aula **Simple Past Question**, de **02/09/2026**, extraída do caderno fornecido. Ele não importa as demais aulas.

### 5. Importação completa do caderno

Para migrar todo o `Digital English Notebook`, execute no SQL Editor, nesta ordem:

1. [`supabase/migrations/202610270002_add_image_blocks.sql`](supabase/migrations/202610270002_add_image_blocks.sql);
2. [`supabase/migrations/202610270003_add_lesson_source_reference.sql`](supabase/migrations/202610270003_add_lesson_source_reference.sql);
3. [`supabase/imports/digital_notebook_full.sql`](supabase/imports/digital_notebook_full.sql).

O import completo cria 27 aulas e 231 blocos, preservando os 1.624 parágrafos úteis, 19 links identificados e 6 imagens do documento. A operação é transacional e pode ser repetida: cada aula importada possui uma referência de origem, evitando duplicação.

As respostas e correções históricas permanecem no texto original, pois no DOCX elas estão misturadas no mesmo parágrafo. Elas não são convertidas automaticamente em respostas interativas para evitar atribuições incorretas. Novos exercícios continuam usando normalmente o fluxo estruturado de respostas e correções.

Não execute o seed opcional se pretende usar o import completo. Caso já tenha executado o seed, exclua a aula de demonstração antes da importação para evitar uma cópia visual da aula de 02/09/2026.

O arquivo SQL pode ser regenerado a partir do DOCX com:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\scripts\generate-notebook-import.ps1 `
  -DocxPath "C:\caminho\Digital English Notbook.docx" `
  -OutputPath "supabase\imports\digital_notebook_full.sql"
```

## Papéis e permissões

| Ação | Camila (`TEACHER`) | João (`STUDENT`) |
| --- | --- | --- |
| Ver aulas e atividades | Sim | Sim |
| Criar, editar e excluir aulas | Sim | Não |
| Criar e editar exercícios/homework | Sim | Não |
| Responder ou editar a própria resposta | Não | Sim |
| Corrigir e comentar respostas | Sim | Não |
| Ver correções | Sim | Sim |

As restrições são aplicadas no Supabase e não apenas na interface.

## Build e GitHub Pages

O Vite usa o base path `/english-school/`, correspondente ao nome do repositório.

Para testar o build local:

```bash
npm run build
npm run preview
```

O workflow [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml) publica o diretório `dist` no GitHub Pages quando houver push na branch `main`.

Antes do primeiro deploy:

1. em **Settings → Pages**, selecione **GitHub Actions** como source;
2. em **Settings → Secrets and variables → Actions**, crie:
   - `VITE_SUPABASE_URL`;
   - `VITE_SUPABASE_ANON_KEY`;
3. faça push somente quando a publicação estiver autorizada.

## Estrutura principal

```text
src/
  components/       layout, blocos de aula e atividades
  contexts/         sessão e perfil autenticado
  lib/              cliente Supabase e datas
  pages/            páginas e editores
  services/         consultas e gravações no Supabase
  styles/           estilos responsivos da aplicação
  types/            tipos do domínio
supabase/
  migrations/       esquema e políticas RLS
  seed.example.sql  uma aula real opcional
```

## Escopo

A V1 foi intencionalmente mantida pequena. Não há organizações, gamificação, chat, notificações, IA, analytics ou backend próprio. O foco é o ciclo real de uso: Camila cria a aula e os exercícios, João estuda e responde, Camila corrige, e João revisa depois.
