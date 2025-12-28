# IAção - Product Requirements Document (PRD)

> **Versão:** 1.0
> **Data:** 2025-12-27
> **Status:** Draft

---

## 1. Goals and Background Context

### Goals

- Criar um RPG educacional que seja genuinamente divertido como um game comercial
- Ensinar competências do século XXI (criatividade, pensamento crítico, comunicação, lógica, ética digital, colaboração) através de gameplay
- Implementar IA como recurso estratégico e limitado, ensinando uso consciente
- Avaliar jogadores sem provas tradicionais, através de análise de decisões e soluções
- Fornecer visibilidade real de progresso para educadores e pais
- Lançar MVP funcional para validação com público-alvo

### Background Context

O mercado de games educacionais está saturado de "LMS disfarçados" — plataformas que usam gamificação superficial (pontos, badges, rankings) sem criar engajamento real. Crianças jogam por obrigação, não por prazer, e o aprendizado não se traduz em competências aplicáveis.

Simultaneamente, a IA generativa está sendo adotada massivamente por jovens, mas sem orientação sobre uso ético e consciente. IAção resolve ambos os problemas: cria uma experiência de jogo genuína onde a IA é uma ferramenta poderosa mas limitada, e o aprendizado acontece naturalmente através de resolução de problemas e criação.

### Change Log

| Date | Version | Description | Author |
|------|---------|-------------|--------|
| 2025-12-27 | 1.0 | Initial PRD creation | BMad |

---

## 2. Requirements

### 2.1 Functional Requirements

#### Core Game Systems

- **FR1:** O sistema deve permitir criação e customização de personagem (nome, aparência, background)
- **FR2:** O sistema deve implementar um mundo 2D/2.5D navegável com áreas distintas
- **FR3:** O sistema deve suportar interação com NPCs através de sistema de diálogos com escolhas
- **FR4:** O sistema deve implementar inventário básico para itens e recursos
- **FR5:** O sistema deve salvar progresso automaticamente e permitir múltiplos saves

#### Sistema de Missões

- **FR6:** O sistema deve apresentar missões com problemas contextualizados sem resposta única correta
- **FR7:** O sistema deve permitir múltiplos caminhos de solução para cada missão
- **FR8:** O sistema deve aplicar consequências visíveis no mundo baseadas nas escolhas do jogador
- **FR9:** O sistema deve trackear decisões do jogador para análise de competências
- **FR10:** O sistema deve suportar missões sequenciais e paralelas

#### Sistema de IA (ARIA)

- **FR11:** O sistema deve implementar IA mentora (ARIA) acessível via interface in-game
- **FR12:** A IA deve oferecer 4 ações principais: Analisar, Sugerir, Simular, Melhorar
- **FR13:** Cada uso de IA deve consumir recurso limitado (energia do personagem)
- **FR14:** O sistema deve implementar rate limiting por sessão/dia
- **FR15:** A IA deve responder contextualmente baseada na missão atual
- **FR16:** O sistema deve logar todos os usos de IA para análise

#### Sistema de Competências

- **FR17:** O sistema deve trackear 6 competências: Criatividade, Pensamento Crítico, Comunicação, Lógica, Ética Digital, Colaboração
- **FR18:** Competências devem evoluir baseadas em ações e decisões, não XP arbitrário
- **FR19:** O sistema deve desbloquear habilidades/opções baseadas em competências
- **FR20:** O sistema deve gerar perfil de competências visualizável

#### Ferramentas de Criação

- **FR21:** O sistema deve oferecer editor simples para criar ideias/projetos
- **FR22:** O sistema deve permitir "pitch" de soluções para NPCs
- **FR23:** O sistema deve salvar criações do jogador como portfólio
- **FR24:** O sistema deve avaliar qualidade das criações para progressão

#### Dashboard Educador

- **FR25:** O sistema deve oferecer dashboard web separado para educadores
- **FR26:** Educadores devem visualizar progresso de competências por aluno
- **FR27:** O sistema deve gerar relatórios exportáveis (PDF)
- **FR28:** O sistema deve permitir criar "turmas" agrupando jogadores

#### Autenticação e Usuários

- **FR29:** O sistema deve suportar login via OAuth (Google, Microsoft)
- **FR30:** O sistema deve implementar perfis: Jogador, Educador, Responsável
- **FR31:** O sistema deve vincular jogadores a responsáveis (controle parental)
- **FR32:** O sistema deve permitir configurações de privacidade por perfil

### 2.2 Non-Functional Requirements

#### Performance

- **NFR1:** O jogo deve carregar em menos de 5 segundos em conexão 4G
- **NFR2:** O jogo deve manter 60 FPS em hardware médio (Chromebook escolar)
- **NFR3:** Latência de resposta da IA deve ser < 3 segundos
- **NFR4:** O sistema deve suportar 1000 usuários simultâneos no MVP

#### Segurança

- **NFR5:** O sistema deve ser compliant com LGPD
- **NFR6:** O sistema deve implementar considerações COPPA para menores
- **NFR7:** Não deve existir chat livre entre jogadores (comunicação mediada)
- **NFR8:** Conteúdo gerado por IA deve passar por filtros de segurança
- **NFR9:** Dados sensíveis devem ser criptografados em repouso e trânsito

#### Usabilidade

- **NFR10:** O tutorial deve ser completável em < 15 minutos
- **NFR11:** Controles devem ser intuitivos para jogadores de 9 anos
- **NFR12:** Interface deve suportar navegação por teclado e mouse
- **NFR13:** Textos devem usar linguagem apropriada para faixa etária

#### Disponibilidade

- **NFR14:** Uptime mínimo de 99% durante horário escolar (7h-18h BRT)
- **NFR15:** Sistema de backup com recovery < 1 hora
- **NFR16:** Degradação graciosa quando IA estiver indisponível

#### Escalabilidade

- **NFR17:** Arquitetura deve suportar escala para 100k usuários
- **NFR18:** Custo de IA por usuário ativo deve ser < R$5/mês

---

## 3. User Interface Design Goals

### 3.1 Overall UX Vision

Uma experiência de jogo imersiva que lembra jogos comerciais como Stardew Valley ou Pokemon, mas com mecânicas educacionais invisíveis. A interface deve ser lúdica, colorida e convidativa, sem parecer "software escolar". ARIA (a IA) deve ser uma presença amigável e não invasiva.

### 3.2 Key Interaction Paradigms

- **Exploração livre:** Jogador navega pelo mundo usando teclado/mouse ou touch
- **Diálogos com escolhas:** Conversas com NPCs apresentam opções que afetam a história
- **Menus radiais:** Acesso rápido a inventário, competências, ARIA
- **Drag-and-drop:** Para ferramentas de criação
- **Feedback visual:** Partículas, animações e sons para ações importantes

### 3.3 Core Screens and Views

| Tela | Propósito | Prioridade MVP |
|------|-----------|----------------|
| Tela de Título | Login, novo jogo, continuar | Essencial |
| Criação de Personagem | Customização inicial | Essencial |
| Mundo do Jogo (HUD) | Gameplay principal | Essencial |
| Interface ARIA | Interação com IA | Essencial |
| Painel de Competências | Visualizar progresso | Essencial |
| Inventário | Gerenciar itens | Essencial |
| Editor de Criação | Criar projetos/ideias | Essencial |
| Tela de Missão | Briefing e progresso | Essencial |
| Dashboard Educador | Web separado | Essencial |
| Painel Responsável | Web separado | Fase 2 |

### 3.4 Accessibility

**WCAG AA** - O jogo deve ser acessível para jogadores com deficiências visuais ou motoras moderadas:
- Suporte a leitores de tela para menus
- Opções de alto contraste
- Legendas para áudio
- Controles remapeáveis
- Tamanho de fonte ajustável

### 3.5 Branding

**Estilo Visual:**
- Paleta vibrante mas não saturada (tons de azul, verde, laranja)
- Arte 2D estilizada (inspiração: Celeste, Hollow Knight, mas mais colorido)
- Personagens expressivos com animações fluidas
- UI limpa com bordas arredondadas
- Tipografia amigável e legível (sans-serif)

**Tom:**
- Esperançoso e empoderador
- Curioso e exploratório
- Jovem mas não infantilizado

### 3.6 Target Platforms

**Primário:** Web Responsive (Chrome, Firefox, Safari, Edge)
- Deve funcionar em Chromebooks escolares
- Suporte a teclado/mouse e touch

**Secundário (Fase 2):** Desktop (Windows, Mac) via builds dedicadas

**Futuro:** Mobile nativo (iOS, Android)

---

## 4. Technical Assumptions

### 4.1 Repository Structure

**Monorepo** usando workspaces (npm/yarn)

```
/iacao
├── /apps
│   ├── /game          # Cliente Godot (exportado para web)
│   ├── /api           # Backend Node.js/Python
│   └── /dashboard     # Web app educador (React/Vue)
├── /packages
│   ├── /shared        # Tipos e utilitários compartilhados
│   └── /ai-client     # SDK para integração com IA
├── /docs              # Documentação
└── /infrastructure    # IaC (Terraform/Pulumi)
```

**Rationale:** Monorepo simplifica gestão de dependências, versionamento e CI/CD para equipe pequena.

### 4.2 Service Architecture

**Híbrido: Monolith Modular + Serviço de IA separado**

```
┌─────────────────────────────────────────────────────────┐
│                    Game Client (Godot)                   │
│                    (WebAssembly Export)                  │
└─────────────────┬───────────────────────────────────────┘
                  │ REST/WebSocket
                  ▼
┌─────────────────────────────────────────────────────────┐
│                     API Gateway                          │
│              (Authentication, Rate Limiting)             │
└─────────────────┬───────────────────────────────────────┘
                  │
      ┌───────────┼───────────┐
      ▼           ▼           ▼
┌──────────┐ ┌──────────┐ ┌──────────┐
│   Game   │ │  User    │ │ Analytics│
│ Service  │ │ Service  │ │ Service  │
└────┬─────┘ └────┬─────┘ └────┬─────┘
     │            │            │
     └────────────┼────────────┘
                  ▼
         ┌───────────────┐
         │  PostgreSQL   │
         │    + Redis    │
         └───────────────┘

┌─────────────────────────────────────────────────────────┐
│                    AI Proxy Service                      │
│         (Rate Limiting, Prompt Engineering,              │
│          Content Filtering, Cost Control)                │
└─────────────────┬───────────────────────────────────────┘
                  │
                  ▼
         ┌───────────────┐
         │ OpenAI/Claude │
         │      API      │
         └───────────────┘
```

**Rationale:**
- Monolith modular é mais simples para MVP e equipe pequena
- Serviço de IA separado para controle de custos e segurança
- Pode evoluir para microserviços se necessário

### 4.3 Testing Requirements

**Full Testing Pyramid:**

| Nível | Cobertura | Ferramentas |
|-------|-----------|-------------|
| Unit | 80% do código crítico | Jest/Vitest, GDUnit |
| Integration | APIs e banco | Supertest, Testcontainers |
| E2E | Fluxos críticos | Playwright (dashboard), Manual (game) |
| Manual | Gameplay, UX | Protocolo de testes com usuários |

**Requisitos Específicos:**
- CI/CD deve rodar testes antes de merge
- Testes de carga para API de IA
- Testes de segurança (SAST/DAST) antes de release

### 4.4 Additional Technical Assumptions

- **Game Engine:** Godot 4.x com GDScript (priorizar simplicidade)
- **Backend Language:** TypeScript (Node.js) ou Python (FastAPI) - decisão final com Architect
- **Database:** PostgreSQL 15+ com extensão pgvector (futuro: embeddings)
- **Cache:** Redis para sessões e rate limiting
- **AI Provider:** OpenAI GPT-4o-mini (custo-benefício) ou Claude Haiku
- **AI Proxy:** Próprio, não usar diretamente do cliente
- **Hosting:** AWS (ECS/EKS) ou GCP (Cloud Run) com CDN para assets
- **CI/CD:** GitHub Actions
- **Monitoring:** Datadog ou Grafana Cloud
- **Feature Flags:** LaunchDarkly ou Unleash (para rollout gradual)

---

## 5. Epic List

### Epic 1: Foundation & Core Infrastructure
**Goal:** Estabelecer projeto base com autenticação, estrutura do game client, e pipeline de deploy funcional. Entregar "Hello World" jogável.

### Epic 2: World & Navigation
**Goal:** Implementar mundo navegável com Vila Esperança, NPCs básicos, e sistema de áreas/transições.

### Epic 3: Dialogue & Choice System
**Goal:** Criar sistema de diálogos com NPCs, escolhas com consequências, e tracking básico de decisões.

### Epic 4: ARIA - AI Mentor System
**Goal:** Integrar IA mentora com as 4 ações core, sistema de energia, e prompts contextuais seguros.

### Epic 5: Mission System
**Goal:** Implementar sistema de missões com objetivos, progresso, múltiplos caminhos, e consequências no mundo.

### Epic 6: Competency & Progression
**Goal:** Criar sistema de competências, avaliação invisível, desbloqueio de habilidades, e visualização de progresso.

### Epic 7: Creation Tools
**Goal:** Implementar editor de ideias/projetos, sistema de pitch, e portfólio do jogador.

### Epic 8: Educator Dashboard
**Goal:** Criar dashboard web para educadores com visão de turmas, progresso por aluno, e relatórios.

### Epic 9: MVP Polish & Content
**Goal:** Finalizar conteúdo do Ciclo 1 (5-10 missões), polish de UX, testes com usuários, e preparação para launch.

---

## 6. Epic Details

### Epic 1: Foundation & Core Infrastructure

**Goal:** Estabelecer a fundação técnica do projeto com autenticação funcional, estrutura base do game client em Godot, backend operacional, e pipeline CI/CD. Entregar uma versão "Hello World" jogável que prove a stack completa funcionando end-to-end.

#### Story 1.1: Project Setup & Repository Structure

**As a** developer,
**I want** a properly structured monorepo with all necessary configurations,
**so that** the team can begin development with consistent tooling.

**Acceptance Criteria:**
1. Monorepo criado com estrutura de workspaces (apps/game, apps/api, apps/dashboard)
2. Configuração de linting (ESLint/Prettier para TS, gdlint para Godot)
3. Git hooks configurados (pre-commit, pre-push)
4. README com instruções de setup local
5. .env.example com variáveis necessárias
6. Docker Compose para desenvolvimento local

---

#### Story 1.2: CI/CD Pipeline Foundation

**As a** developer,
**I want** automated build and deploy pipelines,
**so that** changes are validated and deployed consistently.

**Acceptance Criteria:**
1. GitHub Actions workflow para build em PRs
2. Testes automatizados executam em cada PR
3. Build do game Godot para web funcionando
4. Deploy automático para ambiente de staging
5. Proteção de branch main (requer PR aprovado)

---

#### Story 1.3: Backend API Foundation

**As a** developer,
**I want** a basic backend API running,
**so that** the game client can communicate with the server.

**Acceptance Criteria:**
1. API Node.js/Python configurada com framework escolhido
2. Health check endpoint funcionando (/health)
3. Conexão com PostgreSQL configurada
4. Migrations setup funcionando
5. Logging estruturado implementado
6. Documentação OpenAPI básica

---

#### Story 1.4: Authentication System

**As a** player,
**I want** to login with my Google or Microsoft account,
**so that** I can access the game securely.

**Acceptance Criteria:**
1. OAuth2 com Google funcionando
2. OAuth2 com Microsoft funcionando
3. JWT tokens para sessões
4. Refresh token rotation implementado
5. Logout funcional
6. Proteção CSRF implementada

---

#### Story 1.5: Godot Game Client Foundation

**As a** player,
**I want** to see a basic game screen in my browser,
**so that** I know the game is working.

**Acceptance Criteria:**
1. Projeto Godot 4.x configurado
2. Export para HTML5/WebAssembly funcionando
3. Tela de título básica com logo
4. Conexão com backend API funcionando
5. Login via OAuth redirecionando corretamente
6. Build size < 50MB

---

#### Story 1.6: Database Schema Foundation

**As a** developer,
**I want** the core database schema implemented,
**so that** we can persist game data.

**Acceptance Criteria:**
1. Tabela users com campos básicos
2. Tabela player_profiles para dados do jogo
3. Tabela game_saves para progresso
4. Índices apropriados criados
5. Seed data para desenvolvimento
6. Migrations versionadas

---

### Epic 2: World & Navigation

**Goal:** Criar o mundo navegável de Vila Esperança com áreas distintas, sistema de câmera, e transições fluidas. O jogador deve poder explorar livremente o ambiente inicial.

#### Story 2.1: Tilemap & Base World Structure

**As a** player,
**I want** to see the game world rendered,
**so that** I can understand the environment.

**Acceptance Criteria:**
1. Tileset de Vila Esperança criado/importado
2. Tilemap do hub central (Praça) implementado
3. Sistema de camadas (ground, objects, above-player)
4. Colisões configuradas corretamente
5. Iluminação básica funcionando

---

#### Story 2.2: Player Character & Movement

**As a** player,
**I want** to control my character smoothly,
**so that** I can explore the world.

**Acceptance Criteria:**
1. Sprite de personagem com animações (idle, walk 4 direções)
2. Movimento responsivo via teclado (WASD/arrows)
3. Movimento via mouse/touch (click-to-move)
4. Colisão com objetos funcionando
5. Velocidade de movimento balanceada
6. Câmera seguindo o jogador suavemente

---

#### Story 2.3: Area Transitions & Scene Loading

**As a** player,
**I want** to move between areas seamlessly,
**so that** the world feels connected.

**Acceptance Criteria:**
1. Sistema de transição entre cenas implementado
2. Fade in/out durante transições
3. Spawn points configuráveis por entrada
4. Loading assíncrono sem travamentos
5. Mínimo 3 áreas conectadas (Praça, Escola, Casa do jogador)

---

#### Story 2.4: Interactive Objects Foundation

**As a** player,
**I want** to interact with objects in the world,
**so that** the environment feels alive.

**Acceptance Criteria:**
1. Sistema de interação (tecla E ou click)
2. Indicador visual de objetos interativos
3. Objetos básicos: portas, placas, baús
4. Feedback sonoro e visual na interação
5. Sistema extensível para novos tipos de objetos

---

#### Story 2.5: NPC Placement & Basic Behavior

**As a** player,
**I want** to see NPCs in the world,
**so that** Vila Esperança feels populated.

**Acceptance Criteria:**
1. Sistema de NPC com sprites e animações
2. NPCs posicionados nas áreas principais
3. Movimento idle básico (olhar ao redor, andar curto)
4. Indicador de NPC interativo
5. Mínimo 5 NPCs distintos colocados

---

### Epic 3: Dialogue & Choice System

**Goal:** Implementar sistema de diálogos rico com NPCs, incluindo escolhas significativas que afetam a narrativa e são trackeadas para análise de competências.

#### Story 3.1: Dialogue UI System

**As a** player,
**I want** to read dialogues in a clear interface,
**so that** I can follow conversations.

**Acceptance Criteria:**
1. Caixa de diálogo estilizada no bottom da tela
2. Retrato do NPC falando
3. Nome do NPC exibido
4. Texto com efeito de digitação (typewriter)
5. Indicador de "continuar" (seta piscando)
6. Skip de animação de texto (click/space)

---

#### Story 3.2: Dialogue Data Structure & Parser

**As a** developer,
**I want** dialogues defined in data files,
**so that** content can be created without code changes.

**Acceptance Criteria:**
1. Formato de arquivo de diálogo definido (JSON/YAML)
2. Parser de diálogo funcionando
3. Suporte a variáveis (nome do jogador, etc.)
4. Suporte a condicionais básicos
5. Hot reload de diálogos em dev mode
6. Mínimo 3 diálogos de exemplo criados

---

#### Story 3.3: Choice System Implementation

**As a** player,
**I want** to make choices during dialogues,
**so that** I can influence the story.

**Acceptance Criteria:**
1. UI de escolhas com 2-4 opções
2. Highlight visual da opção selecionada
3. Seleção via teclado ou mouse
4. Branching de diálogo baseado em escolha
5. Feedback visual após escolha
6. Mínimo 2 diálogos com escolhas significativas

---

#### Story 3.4: Choice Tracking & Persistence

**As a** developer,
**I want** choices tracked and saved,
**so that** they can affect the game and be analyzed.

**Acceptance Criteria:**
1. Todas as escolhas são enviadas ao backend
2. Tabela de choice_logs no banco
3. Timestamp e contexto salvos
4. Escolhas recuperadas ao carregar save
5. Flags de mundo atualizadas baseadas em escolhas
6. API para consultar histórico de escolhas

---

#### Story 3.5: NPC Memory & State

**As a** player,
**I want** NPCs to remember my choices,
**so that** conversations feel meaningful.

**Acceptance Criteria:**
1. NPCs referenciam escolhas anteriores em diálogos
2. Diálogos mudam baseados no estado do mundo
3. NPCs têm estados (não falou, falou, resolveu problema)
4. Indicador visual de NPC com novidade
5. Sistema de relationship/reputation básico

---

### Epic 4: ARIA - AI Mentor System

**Goal:** Implementar a IA mentora ARIA com as 4 ações core, sistema de energia como recurso limitado, prompts contextuais seguros, e logging completo.

#### Story 4.1: ARIA UI & Access

**As a** player,
**I want** to summon ARIA easily,
**so that** I can get help when needed.

**Acceptance Criteria:**
1. Botão/hotkey para abrir interface ARIA
2. ARIA aparece como overlay flutuante
3. Animação de entrada/saída suave
4. Barra de energia visível
5. 4 ações disponíveis como botões
6. Descrição de cada ação ao hover

---

#### Story 4.2: AI Proxy Service

**As a** developer,
**I want** AI calls proxied through our backend,
**so that** we can control costs and ensure safety.

**Acceptance Criteria:**
1. Endpoint /api/ai/query implementado
2. Integração com OpenAI ou Anthropic API
3. Rate limiting por usuário (X calls/hora)
4. Timeout handling (max 10s)
5. Fallback para respostas pré-definidas
6. Logging de todas as requests

---

#### Story 4.3: Contextual Prompt Engineering

**As a** developer,
**I want** prompts to include game context,
**so that** ARIA's responses are relevant.

**Acceptance Criteria:**
1. System prompt define personalidade ARIA
2. Contexto da missão atual incluído
3. Histórico recente de conversa incluído
4. Inventário/competências do jogador incluídos
5. Prompts limitam escopo de resposta
6. Testes de prompt com casos comuns

---

#### Story 4.4: Four Core AI Actions

**As a** player,
**I want** ARIA to help me in specific ways,
**so that** I can use her strategically.

**Acceptance Criteria:**
1. **Analisar:** ARIA analisa situação/problema atual
2. **Sugerir:** ARIA oferece alternativas de abordagem
3. **Simular:** ARIA prevê consequências de uma ação
4. **Melhorar:** ARIA ajuda a refinar uma ideia
5. Cada ação tem custo de energia diferente
6. Respostas são apresentadas de forma narrativa (in-character)

---

#### Story 4.5: Energy System & Regeneration

**As a** player,
**I want** ARIA's help to cost energy,
**so that** I use it thoughtfully.

**Acceptance Criteria:**
1. Barra de energia (0-100)
2. Custos: Analisar=10, Sugerir=15, Simular=20, Melhorar=15
3. Regeneração passiva (1/minuto)
4. Regeneração por ações no jogo (resolver problemas)
5. Feedback visual quando energia insuficiente
6. Energia persiste entre sessões

---

#### Story 4.6: Content Safety Filters

**As a** parent/educator,
**I want** AI responses to be safe and appropriate,
**so that** children are protected.

**Acceptance Criteria:**
1. Filtro de input (bloqueio de prompts maliciosos)
2. Filtro de output (moderação de respostas)
3. Lista de palavras/tópicos bloqueados
4. Fallback para resposta segura se filtro ativar
5. Logging de tentativas bloqueadas
6. Painel admin para revisar logs

---

### Epic 5: Mission System

**Goal:** Criar sistema completo de missões com objetivos, progresso, múltiplos caminhos de solução, e consequências visíveis no mundo.

#### Story 5.1: Mission Data Structure

**As a** developer,
**I want** missions defined in data files,
**so that** content creators can add missions easily.

**Acceptance Criteria:**
1. Schema de missão definido (JSON/YAML)
2. Suporte a objetivos múltiplos e opcionais
3. Suporte a pré-requisitos
4. Suporte a branches baseadas em abordagem
5. Validador de missão implementado
6. Mínimo 2 missões exemplo criadas

---

#### Story 5.2: Mission Journal UI

**As a** player,
**I want** to track my missions in a journal,
**so that** I know what I'm doing.

**Acceptance Criteria:**
1. Tela de journal acessível via menu
2. Lista de missões ativas
3. Lista de missões concluídas
4. Detalhes de missão com objetivos
5. Indicador de progresso por objetivo
6. Filtros por status/região

---

#### Story 5.3: Objective Tracking & Completion

**As a** developer,
**I want** objectives tracked automatically,
**so that** missions progress correctly.

**Acceptance Criteria:**
1. Sistema de eventos para objetivos
2. Tipos de objetivo: falar com NPC, coletar item, fazer escolha, criar algo
3. Objetivos podem ter contagem (3/5 itens)
4. Callback de completion por objetivo
5. Missão completa quando todos os required objectives completam
6. Sync com backend para persistência

---

#### Story 5.4: Mission Consequences & World State

**As a** player,
**I want** my mission choices to change the world,
**so that** my actions matter.

**Acceptance Criteria:**
1. Sistema de world flags (booleans)
2. Missões podem setar/ler flags
3. NPCs/objetos reagem a flags
4. Áreas podem mudar baseadas em flags
5. Mínimo 3 consequências visíveis implementadas
6. Flags persistem no save

---

#### Story 5.5: Mission Rewards & Feedback

**As a** player,
**I want** to be rewarded for completing missions,
**so that** I feel accomplished.

**Acceptance Criteria:**
1. Tela de conclusão de missão
2. Sumário de escolhas feitas
3. Competências ganhas mostradas
4. Itens ganhos mostrados
5. Efeitos visuais de celebração
6. Sound design para conclusão

---

### Epic 6: Competency & Progression

**Goal:** Implementar sistema de avaliação por competências, tracking invisível de habilidades, desbloqueio de opções baseado em competências, e visualização clara de progresso.

#### Story 6.1: Competency Data Model

**As a** developer,
**I want** competencies tracked in the database,
**so that** we can analyze player growth.

**Acceptance Criteria:**
1. 6 competências definidas: Criatividade, Pensamento Crítico, Comunicação, Lógica, Ética Digital, Colaboração
2. Cada competência tem nível 0-100
3. Histórico de mudanças de competência salvo
4. Eventos que afetam competências mapeados
5. API para consultar competências
6. Seed com valores iniciais

---

#### Story 6.2: Invisible Assessment Logic

**As a** educator,
**I want** competencies assessed through gameplay,
**so that** evaluation is authentic.

**Acceptance Criteria:**
1. Decisões mapeadas para competências
2. Qualidade de criações afeta competências
3. Uso de IA afeta competências (positivo se estratégico)
4. Colaboração em missões afeta competência
5. Algoritmo de scoring documentado
6. Testes unitários para assessment logic

---

#### Story 6.3: Competency Visualization

**As a** player,
**I want** to see my competencies visually,
**so that** I understand my growth.

**Acceptance Criteria:**
1. Tela de perfil de competências
2. Gráfico radar com as 6 competências
3. Animação de aumento de competência
4. Histórico de evolução (gráfico de linha)
5. Comparação com média (opt-in)
6. Descrição de cada competência

---

#### Story 6.4: Ability Unlocks Based on Competency

**As a** player,
**I want** new abilities as I grow,
**so that** progress feels meaningful.

**Acceptance Criteria:**
1. Habilidades mapeadas para níveis de competência
2. Notificação de desbloqueio
3. Mínimo 2 habilidades por competência
4. Habilidades afetam gameplay (novas opções de diálogo, ações)
5. Árvore de habilidades visual
6. Preview de próximas habilidades

---

#### Story 6.5: Educator Competency API

**As an** educator,
**I want** to access competency data via API,
**so that** the dashboard can display it.

**Acceptance Criteria:**
1. Endpoint /api/students/{id}/competencies
2. Endpoint /api/classes/{id}/competencies (agregado)
3. Autenticação de educador validada
4. Filtros por período
5. Rate limiting apropriado
6. Documentação OpenAPI

---

### Epic 7: Creation Tools

**Goal:** Implementar ferramentas para jogadores criarem ideias, projetos e soluções dentro do jogo, com sistema de pitch e portfólio pessoal.

#### Story 7.1: Idea Editor UI

**As a** player,
**I want** to write and organize my ideas,
**so that** I can create solutions.

**Acceptance Criteria:**
1. Editor de texto simples in-game
2. Suporte a formatação básica (negrito, listas)
3. Templates de estrutura (problema, solução, impacto)
4. Autosave durante edição
5. Lista de ideias salvas
6. Busca em ideias

---

#### Story 7.2: Creation Submission System

**As a** player,
**I want** to submit creations for missions,
**so that** I can progress.

**Acceptance Criteria:**
1. Botão "Submeter" em missões de criação
2. Seleção de ideia a submeter
3. Preview antes de submeter
4. Confirmação de submissão
5. Criação vinculada à missão
6. Não pode editar após submissão

---

#### Story 7.3: AI Evaluation of Creations

**As a** developer,
**I want** creations evaluated by AI,
**so that** we can give feedback and score.

**Acceptance Criteria:**
1. Prompt de avaliação definido
2. Critérios: clareza, criatividade, viabilidade, impacto
3. Score 1-5 por critério
4. Feedback textual gerado
5. Avaliação influencia competências
6. Avaliação salva no banco

---

#### Story 7.4: Pitch System

**As a** player,
**I want** to present my ideas to NPCs,
**so that** I can convince them.

**Acceptance Criteria:**
1. NPCs podem pedir pitch
2. Interface de pitch com tempo limitado
3. NPC reage ao pitch (aprovação, dúvidas, rejeição)
4. Qualidade do pitch afeta missão
5. Competência Comunicação avaliada
6. Feedback específico do NPC

---

#### Story 7.5: Portfolio & Creation History

**As a** player,
**I want** to see all my creations,
**so that** I can track my growth.

**Acceptance Criteria:**
1. Tela de portfólio acessível
2. Lista cronológica de criações
3. Score e feedback visíveis
4. Filtros por missão/tipo
5. Estatísticas agregadas
6. Exportável para educador/responsável

---

### Epic 8: Educator Dashboard

**Goal:** Criar aplicação web separada para educadores gerenciarem turmas, visualizarem progresso de alunos, e gerarem relatórios de competências.

#### Story 8.1: Dashboard Authentication

**As an** educator,
**I want** to login securely,
**so that** I can access student data.

**Acceptance Criteria:**
1. Login via OAuth (Google, Microsoft)
2. Verificação de papel (educator)
3. Processo de onboarding para novos educadores
4. Termos de uso aceitos
5. Logout funcional
6. Sessão com timeout apropriado

---

#### Story 8.2: Class Management

**As an** educator,
**I want** to create and manage classes,
**so that** I can organize students.

**Acceptance Criteria:**
1. CRUD de turmas
2. Código de convite para turma
3. Alunos podem entrar via código
4. Limite de alunos por turma (config)
5. Arquivar turmas antigas
6. Transferir aluno entre turmas

---

#### Story 8.3: Student Progress Overview

**As an** educator,
**I want** to see student progress at a glance,
**so that** I can identify who needs help.

**Acceptance Criteria:**
1. Lista de alunos com indicadores visuais
2. Competências em mini-gráfico
3. Tempo de jogo
4. Missões completadas
5. Último acesso
6. Ordenação e filtros

---

#### Story 8.4: Individual Student View

**As an** educator,
**I want** to see detailed student data,
**so that** I can give personalized feedback.

**Acceptance Criteria:**
1. Perfil completo do aluno
2. Gráfico de competências detalhado
3. Histórico de missões
4. Decisões importantes listadas
5. Portfólio de criações
6. Uso de IA (quantidade, tipos)

---

#### Story 8.5: Report Generation

**As an** educator,
**I want** to generate reports,
**so that** I can share with pais/coordenação.

**Acceptance Criteria:**
1. Seleção de aluno(s) ou turma
2. Período do relatório
3. Tipos de relatório (progresso, competências)
4. Preview em tela
5. Export para PDF
6. Template personalizável

---

### Epic 9: MVP Polish & Content

**Goal:** Finalizar conteúdo jogável do Ciclo 1 com 5-10 missões completas, polish de UX, testes com usuários reais, e preparação para lançamento.

#### Story 9.1: Ciclo 1 Content - Main Quest Line

**As a** player,
**I want** a complete first chapter,
**so that** I can experience the full game loop.

**Acceptance Criteria:**
1. 5 missões principais conectadas narrativamente
2. Arco de história completo para Vila Esperança
3. Todas as cutscenes/diálogos escritos
4. Consequências implementadas
5. Teste de gameplay (2-3 horas de conteúdo)
6. Balanceamento de dificuldade

---

#### Story 9.2: NPC & Dialogue Polish

**As a** player,
**I want** NPCs to feel alive,
**so that** the world is immersive.

**Acceptance Criteria:**
1. Todos os NPCs têm diálogos únicos
2. Variações de diálogo por estado
3. Personalidades distintas
4. Diálogos revisados por qualidade
5. Vozes placeholder ou sound effects
6. Animações de expressão

---

#### Story 9.3: Audio & Music Implementation

**As a** player,
**I want** sound and music,
**so that** the experience is complete.

**Acceptance Criteria:**
1. Música de background por área
2. Sound effects para ações (passos, portas, etc.)
3. Sons de UI (click, hover, etc.)
4. Sons de ARIA
5. Volume controls funcionando
6. Mute option

---

#### Story 9.4: Tutorial & Onboarding

**As a** new player,
**I want** to learn the game naturally,
**so that** I'm not overwhelmed.

**Acceptance Criteria:**
1. Tutorial integrado à narrativa
2. Tooltips contextuais
3. Introdução gradual de mecânicas
4. Skip option para replays
5. Checklist de aprendizado
6. Completável em < 15 min

---

#### Story 9.5: User Testing & Bug Fixes

**As a** product owner,
**I want** the game tested with real users,
**so that** we can fix issues before launch.

**Acceptance Criteria:**
1. 10+ playtesters da faixa etária alvo
2. Protocolo de teste documentado
3. Bugs críticos corrigidos
4. Feedback de UX endereçado
5. Performance testada em Chromebooks
6. Relatório de testes gerado

---

#### Story 9.6: Launch Preparation

**As a** developer,
**I want** everything ready for launch,
**so that** we can release confidently.

**Acceptance Criteria:**
1. Ambiente de produção configurado
2. Monitoring e alertas ativos
3. Backup automatizado testado
4. Documentação de operação
5. Plano de rollback definido
6. Landing page/site pronto

---

## 7. Checklist Results Report

*(A ser preenchido após execução do PM Checklist)*

---

## 8. Next Steps

### UX Expert Prompt

> "Revise o PRD do IAção e crie o Front-End Specification detalhado. Foque no game client (Godot) e no educator dashboard (React/Vue). Priorize acessibilidade WCAG AA e a experiência mobile-friendly. Use o documento de narrativa para informar o tom visual."

### Architect Prompt

> "Revise o PRD do IAção e crie o documento de Arquitetura Técnica. A stack sugerida é Godot 4 (client), Node.js/TypeScript (backend), PostgreSQL + Redis (dados), e OpenAI/Anthropic (IA). Priorize MVP com monolith modular e serviço de IA separado. Detalhe a integração client-server e o sistema de proxy de IA."

---

*Documento gerado com BMad Method*
