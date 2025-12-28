# IAção - Relatório Completo do Projeto

**Data:** 28 de Dezembro de 2025
**Versão:** 1.0
**Status:** MVP em Desenvolvimento

---

## Índice

1. [Visão Geral](#1-visão-geral)
2. [Instalação e Configuração](#2-instalação-e-configuração)
3. [Arquitetura do Sistema](#3-arquitetura-do-sistema)
4. [Implementação por Epic](#4-implementação-por-epic)
5. [Estrutura de Arquivos](#5-estrutura-de-arquivos)
6. [Guia de Desenvolvimento](#6-guia-de-desenvolvimento)
7. [Próximos Passos](#7-próximos-passos)

---

## 1. Visão Geral

### 1.1 O que é o IAção?

**IAção** (IA + Ação) é um RPG educacional inovador para crianças e adolescentes (9-15 anos) que combina a diversão de games comerciais com aprendizado real de competências do século XXI.

### 1.2 Diferenciais

| Característica | Descrição |
|----------------|-----------|
| 🤖 **IA como recurso estratégico** | Não é um chat aberto, é uma habilidade especial que custa energia |
| 📊 **Progressão por competências** | Sem XP vazio, evolução baseada em decisões reais |
| 🎨 **Criação, não consumo** | Jogadores criam soluções, projetos e apresentações |
| 📝 **Avaliação invisível** | Sem provas, análise contínua de decisões |
| 🎭 **Narrativa envolvente** | Mundo rico com consequências para cada escolha |

### 1.3 O Mundo de Nova Aurora

O jogador é um **Catalisador** — alguém com a rara habilidade de se conectar ao Fluxo e despertar uma IA mentora chamada **ARIA**. Em um mundo cheio de problemas sociais e ambientais, o jogador usa criatividade, pensamento crítico e colaboração para ajudar comunidades.

### 1.4 As 7 Competências

| Competência | Descrição |
|-------------|-----------|
| 🎨 **Criatividade** | Gerar ideias originais e conexões inusitadas |
| 🧠 **Pensamento Crítico** | Analisar informações e questionar |
| 💬 **Comunicação** | Expressar ideias e ouvir ativamente |
| 🔢 **Lógica** | Raciocínio estruturado e resolução de problemas |
| 🛡️ **Ética Digital** | Uso responsável de tecnologia e IA |
| 🤝 **Colaboração** | Trabalhar efetivamente com outros |
| 🏛️ **Responsabilidade Cívica** | Participação ativa na comunidade |

---

## 2. Instalação e Configuração

### 2.1 Pré-requisitos

| Software | Versão | Download |
|----------|--------|----------|
| **Node.js** | 20.x LTS | https://nodejs.org/ |
| **pnpm** | 8.x+ | `npm install -g pnpm` |
| **Godot** | 4.2.x | https://godotengine.org/download |
| **Docker** | 24.x | https://docker.com/get-started |
| **Git** | 2.x+ | https://git-scm.com/ |

### 2.2 Clonando o Repositório

```bash
# Clone o repositório
git clone https://github.com/inematds/IAcao.git

# Entre no diretório
cd IAcao
```

### 2.3 Instalando Dependências

```bash
# Instale todas as dependências do workspace
pnpm install
```

### 2.4 Configurando Variáveis de Ambiente

```bash
# Copie o arquivo de exemplo
cp .env.example .env

# Edite o arquivo .env com suas configurações
```

**Variáveis necessárias:**

```env
# Servidor
NODE_ENV=development
PORT=3000
API_URL=http://localhost:3000

# Banco de Dados
DATABASE_URL=postgresql://user:password@localhost:5432/iacao

# Redis
REDIS_URL=redis://localhost:6379

# JWT (gere uma string aleatória de 32+ caracteres)
JWT_SECRET=sua_chave_secreta_muito_longa_aqui
JWT_EXPIRES_IN=15m
REFRESH_TOKEN_EXPIRES_IN=7d

# OAuth (opcional para desenvolvimento)
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_CALLBACK_URL=http://localhost:3000/api/v1/auth/google/callback

MICROSOFT_CLIENT_ID=
MICROSOFT_CLIENT_SECRET=
MICROSOFT_CALLBACK_URL=http://localhost:3000/api/v1/auth/microsoft/callback

# OpenAI (para ARIA funcionar)
OPENAI_API_KEY=sk-sua-chave-aqui
OPENAI_MODEL=gpt-4o-mini

# Rate Limiting
AI_RATE_LIMIT_PER_MINUTE=5
AI_RATE_LIMIT_PER_HOUR=20
AI_RATE_LIMIT_PER_DAY=50

# URLs do Frontend
GAME_CLIENT_URL=http://localhost:8080
DASHBOARD_URL=http://localhost:5173
CORS_ORIGINS=http://localhost:8080,http://localhost:5173
```

### 2.5 Iniciando os Serviços com Docker

```bash
# Inicie PostgreSQL e Redis
docker-compose up -d

# Verifique se os containers estão rodando
docker ps
```

**docker-compose.yml:**
```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: iacao
      POSTGRES_PASSWORD: iacao123
      POSTGRES_DB: iacao
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7
    ports:
      - "6379:6379"

volumes:
  postgres_data:
```

### 2.6 Executando a API

```bash
# Entre no diretório da API
cd apps/api

# Execute em modo de desenvolvimento
pnpm dev
```

A API estará disponível em `http://localhost:3000`

### 2.7 Executando o Game (Godot)

1. Abra o Godot 4.2
2. Clique em "Import"
3. Navegue até `apps/game/project.godot`
4. Clique em "Import & Edit"
5. Pressione F5 para rodar o jogo

### 2.8 Comandos Úteis

```bash
# Executar todos os serviços em desenvolvimento
pnpm dev

# Executar testes
pnpm test

# Build de produção
pnpm build

# Lint do código
pnpm lint

# Formatar código
pnpm format
```

---

## 3. Arquitetura do Sistema

### 3.1 Stack Tecnológica

| Componente | Tecnologia | Versão |
|------------|------------|--------|
| **Game Engine** | Godot | 4.2.x |
| **Game Language** | GDScript | 4.2 |
| **Backend Runtime** | Node.js | 20.x LTS |
| **Backend Language** | TypeScript | 5.3.x |
| **API Framework** | Express.js | 4.18.x |
| **Validação** | Zod | 3.22.x |
| **Banco de Dados** | PostgreSQL | 15.x |
| **Cache** | Redis | 7.x |
| **IA** | OpenAI GPT-4o-mini | API v1 |

### 3.2 Diagrama de Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                       CLIENTE                                │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐                 │
│  │   Game Client   │    │    Dashboard    │                 │
│  │   (Godot/WASM)  │    │   (React SPA)   │                 │
│  └────────┬────────┘    └────────┬────────┘                 │
└───────────┼──────────────────────┼──────────────────────────┘
            │                      │
            ▼                      ▼
┌─────────────────────────────────────────────────────────────┐
│                     API GATEWAY                              │
│                   (Express.js + JWT)                         │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │   Auth   │ │   Game   │ │Analytics │ │Education │       │
│  │  Module  │ │  Module  │ │  Module  │ │  Module  │       │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘       │
└───────┼────────────┼────────────┼────────────┼──────────────┘
        │            │            │            │
        ▼            ▼            ▼            ▼
┌─────────────────────────────────────────────────────────────┐
│                    CAMADA DE DADOS                           │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐                 │
│  │   PostgreSQL    │    │      Redis      │                 │
│  │  (Dados/Saves)  │    │  (Cache/Rate)   │                 │
│  └─────────────────┘    └─────────────────┘                 │
└─────────────────────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────────────────────┐
│                   SERVIÇOS EXTERNOS                          │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐                 │
│  │   OpenAI API    │    │  OAuth Providers │                │
│  │   (ARIA/GPT)    │    │ (Google/Microsoft)│               │
│  └─────────────────┘    └─────────────────┘                 │
└─────────────────────────────────────────────────────────────┘
```

### 3.3 Autoloads do Game (Godot)

| Autoload | Responsabilidade |
|----------|------------------|
| **GameManager** | Estado global do jogo, jogador, energia |
| **APIClient** | Comunicação HTTP com o backend |
| **SaveManager** | Salvar/carregar localmente e na nuvem |
| **DialogueManager** | Sistema de diálogos e escolhas |
| **ARIAManager** | Interface com a IA mentora |
| **CompetencyManager** | Sistema de competências |
| **MissionManager** | Sistema de missões e quests |
| **TutorialManager** | Sistema de tutorial e onboarding |
| **SceneManager** | Transições de cena e áreas |
| **AudioManager** | Música e efeitos sonoros |

---

## 4. Implementação por Epic

### Epic 1: Foundation & Core Infrastructure ✅

**Arquivos criados:**
- `apps/api/src/index.ts` - Entry point da API
- `apps/api/src/app.ts` - Configuração Express
- `apps/api/src/config/index.ts` - Configurações centralizadas
- `apps/api/src/utils/logger.ts` - Logger Pino
- `apps/api/src/utils/errors.ts` - Classes de erro customizadas
- `apps/api/src/middleware/auth.ts` - Autenticação JWT
- `apps/api/src/middleware/errorHandler.ts` - Tratamento de erros
- `apps/game/project.godot` - Configuração do projeto Godot

---

### Epic 2: World & Navigation ✅

**Arquivos criados:**
- `apps/game/scenes/main.tscn` - Cena principal
- `apps/game/scenes/game_world.tscn` - Mundo do jogo
- `apps/game/scripts/player/player.gd` - Controlador do jogador
- `apps/game/scripts/autoloads/game_manager.gd` - Gerenciador global
- `apps/game/scripts/autoloads/scene_manager.gd` - Transições de cena

---

### Epic 3: Dialogue & Choice System ✅

**Arquivos criados:**
- `apps/game/scripts/dialogue/dialogue_manager.gd` - Sistema de diálogos
- `apps/game/scripts/dialogue/npc_memory.gd` - Memória de NPCs
- `apps/game/scripts/ui/dialogue_ui.gd` - Interface de diálogo
- `apps/game/scenes/ui/dialogue_ui.tscn` - Cena da UI de diálogo
- `apps/game/scripts/npc/npc_base.gd` - Base para NPCs
- `apps/game/data/dialogues/*.json` - Arquivos de diálogo

**Sistema de Diálogos:**
- Suporte a condições (flags, tempo, relacionamento)
- Escolhas com consequências
- Efeitos em competências
- Memória persistente de NPCs
- Substituição de variáveis ({player_name}, etc.)

---

### Epic 4: ARIA - AI Mentor System ✅

**Arquivos criados:**
- `apps/game/scripts/aria/aria_manager.gd` - Gerenciador da ARIA
- `apps/game/scripts/aria/aria_ui.gd` - Interface da ARIA
- `apps/game/scenes/ui/aria_ui.tscn` - Cena da UI

**Ações da ARIA:**

| Ação | Custo | Descrição |
|------|-------|-----------|
| 🔍 **Analisar** | 10 energia | Examina a situação e ajuda a entender |
| 💡 **Sugerir** | 15 energia | Oferece 2-3 ideias ou possibilidades |
| 🔮 **Simular** | 15 energia | Mostra possíveis consequências |
| ✨ **Melhorar** | 20 energia | Sugere melhorias para criações |

**Tecla:** Q para abrir ARIA

---

### Epic 5: Competency System ✅

**Arquivos criados:**
- `apps/game/scripts/competency/competency_manager.gd` - Gerenciador
- `apps/game/scripts/competency/competency_ui.gd` - Interface
- `apps/game/scenes/ui/competency_ui.tscn` - Cena da UI

**Sistema de Níveis:**

| Nível | Nome | XP Necessário |
|-------|------|---------------|
| 1 | Iniciante | 0-9 |
| 2 | Aprendiz | 10-24 |
| 3 | Praticante | 25-44 |
| 4 | Competente | 45-69 |
| 5 | Proficiente | 70-89 |
| 6 | Mestre | 90-100 |

**Tecla:** C para ver competências

---

### Epic 6: Mission System ✅

**Arquivos criados:**
- `apps/game/scripts/mission/mission_manager.gd` - Sistema de missões
- `apps/game/scripts/mission/mission_ui.gd` - Interface
- `apps/game/scenes/ui/mission_ui.tscn` - Cena da UI

**Tipos de Objetivos:**
- TALK_TO_NPC - Falar com NPC
- COLLECT_ITEM - Coletar itens
- REACH_LOCATION - Chegar em local
- MAKE_CHOICE - Fazer escolha
- USE_ARIA - Usar ARIA
- REACH_COMPETENCY - Atingir nível
- COMPLETE_DIALOGUE - Completar diálogo

**Tecla:** M para ver missões

---

### Epic 7: Save/Load & Persistence ✅

**Arquivos criados:**
- `apps/game/scripts/autoloads/save_manager.gd` - Gerenciador de saves
- `apps/game/scripts/ui/save_load_ui.gd` - Interface de save/load
- `apps/game/scenes/ui/save_load_ui.tscn` - Cena da UI

**Recursos:**
- 3 slots de save
- Auto-save a cada 60 segundos
- Sincronização com nuvem (quando logado)
- Dados salvos: jogador, competências, flags, NPCs, missões, histórico ARIA

---

### Epic 8: Backend AI Integration ✅

**Arquivos criados:**
- `apps/api/src/services/ai.service.ts` - Serviço de IA
- `apps/api/src/middleware/aiRateLimit.ts` - Rate limiting
- `apps/api/src/modules/ai/ai.routes.ts` - Rotas de IA

**Recursos:**
- Integração com OpenAI GPT-4o-mini
- Prompts de sistema por tipo de ação
- Cache de respostas (5 min TTL)
- Respostas de fallback
- Rate limiting configurável
- Contexto do jogador enriquecido

---

### Epic 9: MVP Polish & Content ✅

**Arquivos criados:**
- `apps/game/scripts/tutorial/tutorial_manager.gd` - Tutorial
- `apps/game/scripts/tutorial/tutorial_ui.gd` - UI do tutorial
- `apps/game/scenes/ui/tutorial_ui.tscn` - Cena do tutorial
- `apps/game/scripts/debug/debug_console.gd` - Console de debug
- `apps/game/scenes/ui/debug_console.tscn` - Cena do debug
- `apps/game/data/dialogues/flora_problem.json` - Diálogo missão
- `apps/game/data/dialogues/flora_present.json` - Diálogo missão
- `apps/game/data/dialogues/seu_antonio.json` - NPC cético
- `apps/game/data/dialogues/final_pitch.json` - Apresentação final

**Missões do Capítulo 1:**

1. **O Projeto do Teco** - Ajudar com robótica
2. **O Problema da Comunidade** - Descobrir problema da praça
3. **A Solução Criativa** - Propor solução
4. **A Decisão da Vila** - Convencer e apresentar
5. **Um Novo Começo** - Celebração e reflexão

**Console de Debug (F12):**
```
help            - Mostra ajuda
energy [valor]  - Define energia
comp [nome] [valor] - Define competência
flag [nome] [valor] - Define flag
mission [id] [start|complete] - Controla missões
teleport [area] - Teletransporta
skip_tutorial   - Pula tutorial
save / load     - Salvar/carregar
```

---

## 5. Estrutura de Arquivos

```
iacao/
├── .github/workflows/        # CI/CD
├── apps/
│   ├── api/                  # Backend Node.js
│   │   ├── src/
│   │   │   ├── config/       # Configurações
│   │   │   ├── middleware/   # Middlewares Express
│   │   │   ├── modules/      # Módulos (auth, ai, game)
│   │   │   ├── services/     # Serviços (ai.service)
│   │   │   ├── types/        # Tipos TypeScript
│   │   │   └── utils/        # Utilitários
│   │   ├── package.json
│   │   └── tsconfig.json
│   │
│   ├── game/                 # Cliente Godot
│   │   ├── assets/           # Sprites, áudio, fontes
│   │   ├── data/
│   │   │   └── dialogues/    # Arquivos JSON de diálogo
│   │   ├── scenes/
│   │   │   ├── ui/           # Cenas de interface
│   │   │   └── areas/        # Cenas de áreas do jogo
│   │   ├── scripts/
│   │   │   ├── autoloads/    # Managers globais
│   │   │   ├── aria/         # Sistema ARIA
│   │   │   ├── competency/   # Sistema de competências
│   │   │   ├── debug/        # Ferramentas de debug
│   │   │   ├── dialogue/     # Sistema de diálogo
│   │   │   ├── mission/      # Sistema de missões
│   │   │   ├── npc/          # NPCs
│   │   │   ├── player/       # Jogador
│   │   │   ├── tutorial/     # Tutorial
│   │   │   └── ui/           # Scripts de UI
│   │   └── project.godot
│   │
│   └── dashboard/            # Dashboard React (futuro)
│
├── docs/                     # Documentação
│   ├── architecture.md       # Arquitetura técnica
│   ├── brief.md              # Visão do projeto
│   ├── prd.md                # Requisitos detalhados
│   └── game-design/          # Design do jogo
│
├── infrastructure/           # Docker, Terraform
├── .env.example              # Exemplo de variáveis
├── docker-compose.yml        # Serviços locais
├── package.json              # Workspace config
└── README.md
```

---

## 6. Guia de Desenvolvimento

### 6.1 Adicionando um Novo NPC

1. Crie o arquivo de diálogo em `apps/game/data/dialogues/nome_npc.json`
2. Siga a estrutura:

```json
{
  "id": "nome_npc",
  "npc_name": "Nome do NPC",
  "npc_id": "nome_npc",
  "start": "greeting",
  "lines": {
    "greeting": {
      "id": "greeting",
      "speaker": "Nome do NPC",
      "text": "Olá, {player_name}!",
      "choices": [
        {
          "id": "opcao1",
          "text": "Texto da opção",
          "next": "proxima_linha",
          "competency_effects": {"communication": 2}
        }
      ]
    }
  }
}
```

3. Adicione o NPC na cena com script `npc_base.gd`

### 6.2 Adicionando uma Nova Missão

Em `apps/game/scripts/mission/mission_manager.gd`, adicione na função `_define_chapter1_missions()`:

```gdscript
var nova_missao := Mission.new()
nova_missao.id = "ch1_nova_missao"
nova_missao.title = "Título da Missão"
nova_missao.description = "Descrição da missão."
nova_missao.giver_npc = "nome_npc"
nova_missao.is_main_quest = true
nova_missao.order = 60  # Ordem na lista
nova_missao.requirements = {"missao_anterior": true}

# Adicione objetivos
var obj := MissionObjective.new()
obj.id = "objetivo1"
obj.type = ObjectiveType.TALK_TO_NPC
obj.description = "Falar com alguém"
obj.target = "nome_npc"
obj.target_count = 1
nova_missao.objectives.append(obj)

# Adicione recompensas
var rew := MissionReward.new()
rew.type = "competency"
rew.key = "creativity"
rew.value = 5
rew.description = "+5 Criatividade"
nova_missao.rewards.append(rew)

all_missions[nova_missao.id] = nova_missao
```

### 6.3 Modificando os Prompts da ARIA

Em `apps/api/src/services/ai.service.ts`, edite o objeto `ACTION_PROMPTS`:

```typescript
const ACTION_PROMPTS: Record<AIAction, string> = {
  analyze: `Você é ARIA... (seu prompt aqui)`,
  suggest: `...`,
  simulate: `...`,
  improve: `...`
};
```

### 6.4 Executando Testes

```bash
# Testes unitários
pnpm test

# Testes com cobertura
pnpm test:coverage

# Testes E2E
pnpm test:e2e
```

---

## 7. Próximos Passos

### 7.1 Epics Pendentes

- [ ] **Epic 7: Creation Tools** - Sistema de criação de projetos
- [ ] **Epic 8 (PRD): Educator Dashboard** - Painel web para educadores

### 7.2 Melhorias Sugeridas

1. **Áudio e Música**
   - Implementar trilha sonora por área
   - Adicionar efeitos sonoros de UI
   - Sons para ações da ARIA

2. **Assets Visuais**
   - Criar sprites dos NPCs
   - Implementar animações de expressão
   - Adicionar tilesets para novas áreas

3. **Balanceamento**
   - Ajustar custos de energia
   - Balancear recompensas de competências
   - Testar fluxo de missões

4. **Testes com Usuários**
   - Recrutar 10+ playtesters da faixa etária
   - Documentar feedback
   - Iterar sobre problemas encontrados

### 7.3 Deploy em Produção

1. Configurar AWS/GCP
2. Criar pipelines de CI/CD
3. Configurar domínio e SSL
4. Implementar monitoramento
5. Criar processo de backup

---

## Contato

- **Email:** inematds@gmail.com
- **GitHub:** [@inematds](https://github.com/inematds)
- **Repositório:** https://github.com/inematds/IAcao

---

*Relatório gerado com Claude Code*
*Desenvolvido com BMad Method*
