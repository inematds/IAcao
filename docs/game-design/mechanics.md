# IAção - Game Mechanics & Progression Design

> **Versão:** 1.0
> **Data:** 2025-12-27
> **Status:** Draft

---

## 1. Core Loop

O loop principal do IAção é projetado para criar um ciclo virtuoso de **exploração → descoberta → criação → impacto**.

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│    ┌──────────┐    ┌──────────┐    ┌──────────┐            │
│    │ EXPLORAR │───▶│ DESCOBRIR│───▶│  CRIAR   │            │
│    └──────────┘    └──────────┘    └──────────┘            │
│         ▲                                │                  │
│         │                                ▼                  │
│    ┌──────────┐                    ┌──────────┐            │
│    │ EVOLUIR  │◀───────────────────│ IMPACTAR │            │
│    └──────────┘                    └──────────┘            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Fases do Loop

| Fase | Descrição | Exemplo |
|------|-----------|---------|
| **EXPLORAR** | Navegar pelo mundo, interagir com ambiente | Andar pela Vila, conversar com NPCs |
| **DESCOBRIR** | Encontrar problemas, entender contexto | Descobrir que a comunidade está dividida |
| **CRIAR** | Desenvolver soluções usando ferramentas e ARIA | Planejar uma festa para unir as pessoas |
| **IMPACTAR** | Implementar solução, ver consequências | A festa acontece, relacionamentos mudam |
| **EVOLUIR** | Ganhar competências, desbloquear habilidades | +15 Comunicação, desbloqueia "Persuasão" |

---

## 2. Sistema de Competências

### 2.1 As Seis Competências

| Competência | Ícone | Descrição | Como Desenvolver |
|-------------|-------|-----------|------------------|
| **Criatividade** | 🎨 | Capacidade de gerar ideias originais e conexões inusitadas | Criar soluções inovadoras, combinar elementos de formas novas |
| **Pensamento Crítico** | 🧠 | Analisar informações, questionar, avaliar evidências | Fazer perguntas certas, identificar falácias, considerar perspectivas |
| **Comunicação** | 💬 | Expressar ideias claramente, ouvir ativamente | Diálogos bem-sucedidos, pitches convincentes, mediar conflitos |
| **Lógica** | 🔢 | Raciocínio estruturado, resolução de problemas | Resolver puzzles, planejar sequências, otimizar recursos |
| **Ética Digital** | 🛡️ | Uso responsável de tecnologia e IA | Escolhas éticas sobre uso de ARIA, privacidade, consequências |
| **Colaboração** | 🤝 | Trabalhar efetivamente com outros | Missões em grupo, delegar, aceitar ajuda |

### 2.2 Níveis e Progressão

Cada competência vai de **0 a 100**, dividida em 5 tiers:

| Tier | Range | Nome | Descrição |
|------|-------|------|-----------|
| 1 | 0-19 | Iniciante | Primeiros passos, descobrindo a competência |
| 2 | 20-39 | Aprendiz | Entendendo conceitos básicos |
| 3 | 40-59 | Praticante | Aplicando consistentemente |
| 4 | 60-79 | Proficiente | Demonstrando maestria |
| 5 | 80-100 | Mestre | Inspirando outros, transcendendo |

### 2.3 Como Competências São Avaliadas

**Princípio:** O jogador nunca "estuda" para ganhar pontos. A avaliação é invisível, baseada em ações reais.

#### Gatilhos de Avaliação

| Ação do Jogador | Competências Avaliadas | Como É Medido |
|-----------------|------------------------|---------------|
| **Escolha em diálogo** | Varia por escolha | Tags nas opções de diálogo |
| **Criar um projeto** | Criatividade, Comunicação | IA avalia originalidade e clareza |
| **Fazer pitch** | Comunicação, Lógica | Sucesso do pitch, reação do NPC |
| **Usar ARIA estrategicamente** | Ética Digital, Lógica | Quando usou, para quê |
| **Resolver puzzle** | Lógica, Pensamento Crítico | Eficiência, tentativas |
| **Ajudar NPC** | Varia | Tipo de ajuda, impacto |
| **Missão em grupo (futuro)** | Colaboração | Participação, coordenação |

#### Algoritmo de Scoring (Simplificado)

```
Para cada ação avaliada:
  1. Identificar competências afetadas (tags)
  2. Calcular score base (1-10) baseado em qualidade
  3. Aplicar multiplicadores:
     - Dificuldade da situação (1.0 - 2.0)
     - Consistência (bônus se padrão positivo)
     - Novidade (bônus primeira vez)
  4. Converter para delta de competência:
     - Score 1-3: +1 ponto
     - Score 4-6: +2 pontos
     - Score 7-9: +3 pontos
     - Score 10: +5 pontos
  5. Aplicar diminishing returns em níveis altos
```

### 2.4 Desbloqueio de Habilidades

Cada competência desbloqueia habilidades específicas em certos níveis:

#### Criatividade

| Nível | Habilidade | Efeito |
|-------|------------|--------|
| 10 | Improviso | Nova opção de diálogo: improvisar soluções |
| 25 | Combinador | Pode combinar ideias salvas para criar novas |
| 40 | Visão Artística | Acesso a ferramentas de customização avançadas |
| 60 | Inspiração | Bônus ao criar projetos |
| 80 | Musa | Pode "inspirar" NPCs a terem ideias |

#### Pensamento Crítico

| Nível | Habilidade | Efeito |
|-------|------------|--------|
| 10 | Pergunta Certa | Nova opção de diálogo: questionar afirmações |
| 25 | Análise | Ver "stats" ocultas de situações |
| 40 | Ceticismo Saudável | Detecta quando NPCs mentem |
| 60 | Síntese | Resume automaticamente informações longas |
| 80 | Desconstrução | Pode "desmontar" argumentos em debates |

#### Comunicação

| Nível | Habilidade | Efeito |
|-------|------------|--------|
| 10 | Clareza | Pitches têm bônus de compreensão |
| 25 | Empatia | Entende "humor" dos NPCs |
| 40 | Persuasão | Novas opções de convencimento |
| 60 | Oratória | Pitches em grupo são mais efetivos |
| 80 | Inspirador | Pode motivar NPCs desmotivados |

#### Lógica

| Nível | Habilidade | Efeito |
|-------|------------|--------|
| 10 | Sequenciador | Dicas visuais em puzzles |
| 25 | Otimizador | Mostra caminhos mais eficientes |
| 40 | Planejador | Pode criar "planos de ação" formais |
| 60 | Debugger | Identifica falhas em planos |
| 80 | Arquiteto | Projetos têm estrutura automática |

#### Ética Digital

| Nível | Habilidade | Efeito |
|-------|------------|--------|
| 10 | Consciência | Aviso quando ação pode ter consequência ética |
| 25 | Privacidade | Opções de proteger dados de NPCs |
| 40 | Responsabilidade | Bônus de energia com ARIA |
| 60 | Mentor | Pode "ensinar" NPCs sobre ética |
| 80 | Guardião | Pode reverter algumas consequências negativas |

#### Colaboração

| Nível | Habilidade | Efeito |
|-------|------------|--------|
| 10 | Ajudante | Bônus ao ajudar NPCs |
| 25 | Delegador | Pode pedir ajuda a NPCs |
| 40 | Coordenador | Missões em grupo mais eficientes |
| 60 | Líder | NPCs seguem suas sugestões |
| 80 | Catalisador | Faz grupos de NPCs colaborarem entre si |

---

## 3. Sistema de Missões

### 3.1 Estrutura de Missão

Cada missão segue uma estrutura modular:

```yaml
mission:
  id: "c1_m2_invento_teco"
  cycle: 1
  title: "O Invento de Teco"

  # Contexto
  giver: "teco"
  location: "oficina_teco"

  # Requisitos
  prerequisites:
    - mission: "c1_m1_despertar"
    - flag: "conheceu_teco"

  # Briefing
  brief: |
    Teco criou uma máquina para ajudar na colheita, mas ela
    explodiu e destruiu parte do mercado. Ele está desesperado
    e precisa de ajuda para consertar a situação.

  # Objetivos
  objectives:
    - id: "conversar_teco"
      type: "dialogue"
      target: "teco"
      required: true

    - id: "investigar_maquina"
      type: "interact"
      target: "maquina_quebrada"
      required: true

    - id: "coletar_pecas"
      type: "collect"
      items: ["engrenagem", "fio_cobre"]
      count: 3
      required: false

    - id: "apresentar_solucao"
      type: "creation"
      template: "plano_conserto"
      required: true

  # Caminhos/Branches
  branches:
    consertar:
      description: "Ajudar a consertar a máquina"
      consequences:
        - flag: "maquina_consertada"
        - relationship: { npc: "teco", delta: +20 }
        - competency: { type: "logic", delta: +5 }

    reimaginar:
      description: "Propor uma solução completamente diferente"
      consequences:
        - flag: "nova_invencao"
        - relationship: { npc: "teco", delta: +15 }
        - competency: { type: "creativity", delta: +8 }

    responsabilizar:
      description: "Ajudar Teco a assumir responsabilidade"
      consequences:
        - flag: "teco_pede_desculpas"
        - relationship: { npc: "comunidade", delta: +10 }
        - competency: { type: "ethics", delta: +10 }

  # Recompensas base
  rewards:
    competencies:
      - type: "logic"
        min: 3
        max: 8
      - type: "creativity"
        min: 2
        max: 5
    items:
      - "badge_inventor_iniciante"
```

### 3.2 Tipos de Objetivos

| Tipo | Descrição | Exemplo |
|------|-----------|---------|
| `dialogue` | Conversar com NPC | Falar com Teco |
| `interact` | Interagir com objeto | Examinar máquina quebrada |
| `collect` | Coletar itens | Encontrar 3 engrenagens |
| `travel` | Ir a um local | Visitar o mercado |
| `creation` | Criar algo | Escrever plano de ação |
| `pitch` | Apresentar ideia | Convencer Dona Rosa |
| `choice` | Fazer escolha específica | Decidir quem ajudar |
| `time` | Esperar tempo passar | Voltar no dia seguinte |

### 3.3 Sistema de Consequências

Toda missão tem consequências que afetam o mundo:

#### Flags do Mundo

Booleanos que mudam o estado do jogo:

```
maquina_consertada = true
festa_aconteceu = true
teco_e_rafa_amigos = false
comunidade_unida = true
```

#### Mudanças Visuais

Flags podem ativar mudanças no mundo:

| Flag | Mudança Visual |
|------|----------------|
| `maquina_consertada` | Máquina funciona na praça |
| `festa_aconteceu` | Bandeirinhas decorando a praça |
| `arvore_plantada` | Nova árvore no jardim |
| `loja_aberta` | Loja de Dona Rosa com portas abertas |

#### Relationships (Relacionamentos)

Cada NPC tem um valor de relacionamento com o jogador:

```
-100 ────────── 0 ────────── +100
 Hostil      Neutro      Amigo Próximo
```

| Range | Status | Efeito |
|-------|--------|--------|
| -100 a -50 | Hostil | Recusa ajudar, diálogos curtos |
| -49 a -20 | Desconfiado | Respostas frias |
| -19 a +19 | Neutro | Comportamento normal |
| +20 a +49 | Amigável | Oferece dicas, ajuda |
| +50 a +100 | Amigo | Missões especiais, segredos |

---

## 4. Sistema de Energia (para ARIA)

### 4.1 Conceito

A energia é o recurso que limita o uso de ARIA. Ela representa o "esforço mental" de manter a conexão com o Fluxo.

### 4.2 Parâmetros

| Parâmetro | Valor | Descrição |
|-----------|-------|-----------|
| Máximo | 100 | Energia máxima |
| Inicial | 100 | Começa cheio |
| Regeneração passiva | 1/min | Recupera com o tempo |
| Regeneração ativa | Variável | Ações no jogo recuperam |

### 4.3 Custos de ARIA

| Ação | Custo | Descrição |
|------|-------|-----------|
| **Analisar** | 10 | ARIA analisa situação/problema |
| **Sugerir** | 15 | ARIA oferece alternativas |
| **Simular** | 20 | ARIA prevê consequências |
| **Melhorar** | 15 | ARIA ajuda a refinar ideia |

### 4.4 Formas de Recuperar Energia

| Ação | Energia Ganha | Condição |
|------|---------------|----------|
| Resolver puzzle | 5-15 | Baseado em dificuldade |
| Completar objetivo | 5 | Por objetivo |
| Completar missão | 20-30 | Baseado em tamanho |
| Ajudar NPC | 5 | Sem usar ARIA |
| Descobrir segredo | 10 | Exploração |
| Descansar (tempo real) | 1/min | Passivo |
| Novo dia no jogo | 30 | Reset parcial |

### 4.5 Design Intencional

O sistema de energia ensina:

1. **Planejamento:** Não pode usar ARIA para tudo
2. **Estratégia:** Guardar energia para momentos importantes
3. **Autonomia:** Recompensa por resolver sem IA
4. **Consequências:** Ficar sem energia é inconveniente

---

## 5. Sistema de Criação

### 5.1 Editor de Ideias

O jogador pode criar "documentos" dentro do jogo para resolver missões.

#### Templates Disponíveis

| Template | Uso | Estrutura |
|----------|-----|-----------|
| **Ideia Livre** | Qualquer coisa | Título + Texto livre |
| **Plano de Ação** | Missões de planejamento | Problema → Passos → Resultado esperado |
| **Proposta** | Convencer NPCs | Situação → Proposta → Benefícios |
| **Análise** | Missões investigativas | Fatos → Hipóteses → Conclusão |
| **Projeto** | Criações maiores | Objetivo → Recursos → Etapas → Impacto |

#### Interface do Editor

```
┌─────────────────────────────────────────────────┐
│ [📝 Nova Criação]  [📂 Minhas Criações]         │
├─────────────────────────────────────────────────┤
│ Título: [________________________]              │
│                                                 │
│ Template: [Plano de Ação ▼]                     │
├─────────────────────────────────────────────────┤
│ 📌 PROBLEMA                                     │
│ ┌─────────────────────────────────────────────┐ │
│ │ A comunidade está dividida porque...        │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ 📋 PASSOS                                       │
│ ┌─────────────────────────────────────────────┐ │
│ │ 1. Conversar com líderes de cada lado       │ │
│ │ 2. Encontrar interesse comum                │ │
│ │ 3. Organizar reunião conjunta               │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ 🎯 RESULTADO ESPERADO                           │
│ ┌─────────────────────────────────────────────┐ │
│ │ As pessoas vão colaborar novamente          │ │
│ └─────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────┤
│ [💾 Salvar] [🤖 Pedir Ajuda da ARIA] [📤 Submeter] │
└─────────────────────────────────────────────────┘
```

### 5.2 Avaliação de Criações

Quando o jogador submete uma criação, ela é avaliada:

#### Critérios de Avaliação

| Critério | Peso | O que Avalia |
|----------|------|--------------|
| Clareza | 25% | A ideia é compreensível? |
| Criatividade | 25% | É original? Faz conexões novas? |
| Viabilidade | 25% | Pode ser implementada? É realista? |
| Impacto | 25% | Resolve o problema? Causa mudança? |

#### Rubrica de Scoring (1-5)

| Score | Descrição |
|-------|-----------|
| 1 | Incompleto ou não faz sentido |
| 2 | Básico, falta desenvolvimento |
| 3 | Adequado, cumpre o mínimo |
| 4 | Bom, mostra reflexão |
| 5 | Excelente, surpreende positivamente |

#### Feedback

O jogador recebe feedback contextualizado (não notas):

> "Seu plano é claro e mostra que você entendeu o problema! A ideia de fazer uma reunião é boa, mas você pensou no que acontece se as pessoas não quiserem vir? Talvez precisemos de algo para atrair elas..."

### 5.3 Sistema de Pitch

Em algumas missões, o jogador precisa "apresentar" sua ideia a NPCs.

#### Mecânica de Pitch

1. Jogador seleciona uma criação para apresentar
2. Escolhe NPC(s) para quem apresentar
3. Cutscene mostra o pitch acontecendo
4. NPC reage baseado em:
   - Qualidade da criação
   - Relacionamento com jogador
   - Alinhamento com valores do NPC
   - Competência de Comunicação

#### Resultados Possíveis

| Resultado | Condição | Efeito |
|-----------|----------|--------|
| **Sucesso Total** | Score alto + bom relacionamento | NPC aceita e ajuda ativamente |
| **Sucesso** | Score adequado | NPC aceita |
| **Parcial** | Score médio | NPC aceita com ressalvas |
| **Fracasso Construtivo** | Score baixo | NPC recusa mas dá dicas |
| **Fracasso** | Score muito baixo | NPC recusa |

---

## 6. Sistema de Diálogo

### 6.1 Estrutura de Diálogo

```yaml
dialogue:
  id: "teco_primeira_conversa"
  npc: "teco"

  nodes:
    - id: "start"
      speaker: "teco"
      text: "Ah... você é o novo Catalisador, né? Eu sou Teco. Invento coisas... quando elas não explodem."
      portrait: "teco_nervoso"
      next: "resposta_1"

    - id: "resposta_1"
      type: "choice"
      choices:
        - text: "Explodem? Isso parece perigoso!"
          tags: ["curious", "critical_thinking"]
          next: "teco_explica"

        - text: "Legal! Você pode me mostrar alguma coisa?"
          tags: ["friendly", "creativity"]
          next: "teco_animado"

        - text: "Por que você continua inventando se elas explodem?"
          tags: ["direct", "logic"]
          next: "teco_reflexivo"

    - id: "teco_explica"
      speaker: "teco"
      text: "Bom, às vezes... Mas é assim que se aprende! Você não pode ter medo de errar."
      competency_gain:
        - type: "critical_thinking"
          amount: 1
      next: "continua"
```

### 6.2 Tags de Escolha

Cada escolha de diálogo tem tags que:
1. Indicam o "tom" da resposta
2. Afetam competências
3. Podem desbloquear branches

| Tag | Descrição | Competência Associada |
|-----|-----------|----------------------|
| `curious` | Demonstra curiosidade | Pensamento Crítico |
| `creative` | Propõe algo novo | Criatividade |
| `logical` | Usa raciocínio | Lógica |
| `empathetic` | Mostra empatia | Comunicação |
| `ethical` | Considera impacto | Ética Digital |
| `collaborative` | Inclui outros | Colaboração |
| `direct` | Vai direto ao ponto | - |
| `friendly` | Amigável | Comunicação |
| `skeptical` | Questiona | Pensamento Crítico |

### 6.3 Condições de Diálogo

Diálogos podem ter condições para aparecer:

```yaml
conditions:
  - type: "flag"
    flag: "conheceu_aria"
    value: true

  - type: "competency"
    competency: "communication"
    min: 25

  - type: "relationship"
    npc: "dona_rosa"
    min: 20

  - type: "mission"
    mission: "c1_m1_despertar"
    status: "completed"
```

---

## 7. Sistema de Itens e Inventário

### 7.1 Tipos de Itens

| Tipo | Descrição | Exemplo |
|------|-----------|---------|
| **Consumível** | Uso único | Lanche (recupera energia) |
| **Ferramenta** | Equipável, durável | Caderno (melhor criação) |
| **Colecionável** | Sem uso mecânico | Cristal decorativo |
| **Quest Item** | Específico de missão | Peça da máquina do Teco |
| **Badge** | Conquista | "Primeiro Pitch" |

### 7.2 Inventário

- **Limite:** 20 slots (expansível)
- **Organização:** Por categoria
- **Favoritos:** 4 slots de acesso rápido

### 7.3 Itens Especiais

| Item | Efeito | Como Obter |
|------|--------|------------|
| **Cristal de Foco** | +50 energia | Missão especial |
| **Caderno do Inventor** | Criações têm bônus | Completar arc do Teco |
| **Lente da Verdade** | Mostra intenções de NPCs | Nível 60 Pensamento Crítico |
| **Emblema da Academia** | Acesso a áreas restritas | Progressão da história |

---

## 8. Economia do Jogo

### 8.1 Moeda: Créditos de Fluxo

Moeda simbólica que representa contribuição para a comunidade.

### 8.2 Formas de Ganhar

| Ação | Créditos |
|------|----------|
| Completar missão | 50-200 |
| Ajudar NPC (side quest) | 20-50 |
| Vender item | Variável |
| Descobrir segredo | 30 |

### 8.3 Formas de Gastar

| Item | Custo |
|------|-------|
| Consumíveis | 10-30 |
| Ferramentas | 50-200 |
| Customização | 20-100 |
| Acesso a áreas | 100+ |

### 8.4 Anti-Grind

O jogo não incentiva farming:
- Missões são a fonte principal
- NPCs têm ofertas limitadas
- Não há pay-to-win

---

## 9. Mundo e Exploração

### 9.1 Estrutura do Mundo

```
NOVA AURORA
├── CICLO 1: Vila Esperança
│   ├── Praça Central (hub)
│   ├── Escola Comunitária
│   ├── Casa do Jogador
│   ├── Oficina do Teco
│   ├── Casa da Vó Lena
│   ├── Mercado
│   └── Floresta Próxima
│
├── CICLO 2: Distrito Industrial (futuro)
├── CICLO 3: Floresta Viva (futuro)
├── CICLO 4: Metrópolis (futuro)
└── CICLO 5: Torre do Fluxo (futuro)
```

### 9.2 Tipos de Áreas

| Tipo | Características | Exemplo |
|------|-----------------|---------|
| **Hub** | Central, muitos NPCs, missões | Praça Central |
| **Funcional** | Serviço específico | Escola (tutorial) |
| **Residencial** | NPCs importantes, lore | Casa da Vó Lena |
| **Exploração** | Segredos, puzzles | Floresta Próxima |
| **Transição** | Conecta áreas | Caminhos |

### 9.3 Segredos e Descobertas

O mundo tem segredos escondidos:

| Tipo | Exemplo | Recompensa |
|------|---------|------------|
| **Interativo** | Árvore com buraco | Item escondido |
| **Observação** | Padrão no chão | Entrada secreta |
| **Temporal** | Só aparece à noite | NPC misterioso |
| **Condicional** | Após missão X | Nova área |

---

## 10. Progressão Narrativa

### 10.1 Ciclo 1: Vila Esperança (MVP)

**Duração estimada:** 3-4 horas

**Arco Principal:**
1. **O Despertar** - Jogador descobre ser Catalisador
2. **Primeiros Passos** - Aprende mecânicas com ARIA
3. **Problemas da Vila** - Descobre conflitos locais
4. **A Festa da Colheita** - Grande evento para unir comunidade
5. **O Chamado** - Convite para a Academia

**Missões:**

| # | Missão | Tipo | Competência Foco |
|---|--------|------|------------------|
| 1 | O Despertar | Tutorial | Todas |
| 2 | Conhecendo ARIA | Tutorial | Ética Digital |
| 3 | A Festa Esquecida | Principal | Comunicação |
| 4 | O Invento de Teco | Principal | Lógica, Criatividade |
| 5 | Memórias de Vó Lena | Side | Pensamento Crítico |
| 6 | Ponte Quebrada | Principal | Colaboração |
| 7 | O Sonho de Rafa | Side | Comunicação |
| 8 | A Festa da Colheita | Principal | Todas |
| 9 | O Chamado | Conclusão | - |

### 10.2 Desbloqueio de Conteúdo

| Requisito | Desbloqueia |
|-----------|-------------|
| Completar missão 1-2 | Vila livre para explorar |
| Completar missão 4 | Oficina do Teco acessível |
| 20+ em qualquer competência | Primeira habilidade |
| Completar Ciclo 1 | Acesso ao Ciclo 2 |

---

## 11. Feedback e Tutoriais

### 11.1 Onboarding

O tutorial é integrado à narrativa:

| Etapa | O que Ensina | Contexto Narrativo |
|-------|--------------|-------------------|
| 1 | Movimento | Acordar e explorar quarto |
| 2 | Interação | Conversar com família |
| 3 | Diálogo/Escolhas | Encontro com Rafa |
| 4 | ARIA | Despertar na caverna |
| 5 | Energia | ARIA explica o Fluxo |
| 6 | Criação | Primeira missão da escola |
| 7 | Competências | Feedback após primeira missão |

### 11.2 Feedback Contínuo

| Tipo | Quando | Como |
|------|--------|------|
| **Notificação** | Competência sobe | Toast + som |
| **Popup** | Habilidade desbloqueada | Modal com explicação |
| **ARIA** | Momentos importantes | Diálogo in-game |
| **Journal** | Sempre disponível | Tela de progresso |

### 11.3 Tooltips Contextuais

Tooltips aparecem quando:
- Jogador fica parado muito tempo
- Primeira vez em uma mecânica
- Após falha

> 💡 "Você pode pedir ajuda da ARIA se estiver com dificuldade. Clique no ícone dela ou pressione A!"

---

## 12. Balanceamento

### 12.1 Tempo por Sessão

**Meta:** 20-45 minutos por sessão

| Atividade | Tempo Médio |
|-----------|-------------|
| Missão pequena | 10-15 min |
| Missão principal | 20-30 min |
| Exploração livre | 10-20 min |

### 12.2 Progressão de Competências

**Meta:** Jogador atinge nível 40-60 em todas ao final do Ciclo 1

| Competência | Oportunidades no Ciclo 1 |
|-------------|-------------------------|
| Criatividade | 8 (missões 2, 4, 6, 7, 8 + criações) |
| Pensamento Crítico | 6 (missões 3, 5, 6 + diálogos) |
| Comunicação | 10 (todos os pitches + diálogos) |
| Lógica | 6 (missões 4, 6 + puzzles) |
| Ética Digital | 5 (uso de ARIA) |
| Colaboração | 4 (missões 3, 6, 8) |

### 12.3 Uso de ARIA

**Meta:** 2-4 usos por missão é ótimo

| Comportamento | Indicador |
|---------------|-----------|
| Muito pouco uso | Jogador pode estar frustrado |
| Uso ótimo | Estratégico, em momentos-chave |
| Uso excessivo | Jogador dependente, ajustar dificuldade |

---

*Documento gerado com BMad Method*
