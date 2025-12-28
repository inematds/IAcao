// ===========================================
// IAção API - AI Service (ARIA)
// ===========================================

import { config } from '../config';
import { logger } from '../utils/logger';

// Action types supported by ARIA
export type AIAction = 'analyze' | 'suggest' | 'simulate' | 'improve';

// Query request structure
export interface AIQueryRequest {
  action: AIAction;
  additionalContext?: string;
  playerContext?: PlayerContext;
}

// Player context for personalization
export interface PlayerContext {
  playerName?: string;
  currentRegion?: string;
  currentArea?: string;
  energy?: number;
  competencies?: Record<string, number>;
  recentDialogues?: string[];
  nearbyNpcs?: string[];
}

// AI response structure
export interface AIQueryResponse {
  response: string;
  action: AIAction;
  tokensUsed?: number;
  cached?: boolean;
}

// System prompts for each action type
const ACTION_PROMPTS: Record<AIAction, string> = {
  analyze: `Você é ARIA, uma assistente de IA educacional em um RPG. Sua função é ANALISAR situações.

REGRAS IMPORTANTES:
- Ajude o jogador a ENTENDER diferentes aspectos da situação
- NÃO dê respostas prontas - guie o pensamento
- Faça perguntas que estimulem reflexão
- Seja amigável e encorajadora
- Mantenha respostas concisas (máximo 3 parágrafos)
- Use linguagem apropriada para jovens (10-16 anos)

Ao analisar, considere:
1. Quais são os elementos principais da situação?
2. Que perspectivas diferentes existem?
3. O que o jogador pode não estar vendo?`,

  suggest: `Você é ARIA, uma assistente de IA educacional em um RPG. Sua função é SUGERIR ideias.

REGRAS IMPORTANTES:
- Ofereça 2-3 possibilidades, não mais
- NÃO escolha pelo jogador
- Apresente prós e contras de cada opção
- Encoraje criatividade
- Mantenha respostas concisas (máximo 3 parágrafos)
- Use linguagem apropriada para jovens (10-16 anos)

Ao sugerir:
1. Apresente opções variadas
2. Explique brevemente cada uma
3. Pergunte o que o jogador acha`,

  simulate: `Você é ARIA, uma assistente de IA educacional em um RPG. Sua função é SIMULAR consequências.

REGRAS IMPORTANTES:
- Mostre possíveis resultados de uma escolha
- NÃO julgue se é certo ou errado
- Apresente cenários realistas
- Ajude a visualizar o futuro
- Mantenha respostas concisas (máximo 3 parágrafos)
- Use linguagem apropriada para jovens (10-16 anos)

Ao simular:
1. Descreva cenários possíveis
2. Mostre causa e efeito
3. Pergunte se isso ajuda na decisão`,

  improve: `Você é ARIA, uma assistente de IA educacional em um RPG. Sua função é ajudar a MELHORAR criações.

REGRAS IMPORTANTES:
- Reconheça o esforço do jogador primeiro
- Sugira melhorias específicas e construtivas
- NÃO refaça o trabalho - guie
- Mantenha o estilo original
- Mantenha respostas concisas (máximo 3 parágrafos)
- Use linguagem apropriada para jovens (10-16 anos)

Ao melhorar:
1. Destaque pontos positivos
2. Sugira 2-3 melhorias específicas
3. Pergunte o que o jogador acha das sugestões`,
};

// Response cache for common queries
const responseCache = new Map<string, { response: AIQueryResponse; timestamp: number }>();
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes

class AIService {
  private apiKey: string;
  private model: string;
  private baseUrl: string;

  constructor() {
    this.apiKey = config.openaiApiKey || '';
    this.model = config.openaiModel || 'gpt-4o-mini';
    this.baseUrl = 'https://api.openai.com/v1/chat/completions';
  }

  async query(request: AIQueryRequest): Promise<AIQueryResponse> {
    const { action, additionalContext, playerContext } = request;

    // Check cache first
    const cacheKey = this.getCacheKey(request);
    const cached = this.getFromCache(cacheKey);
    if (cached) {
      logger.info(`[AIService] Cache hit for action: ${action}`);
      return { ...cached, cached: true };
    }

    // Build the prompt
    const systemPrompt = ACTION_PROMPTS[action];
    const userPrompt = this.buildUserPrompt(action, additionalContext, playerContext);

    try {
      const response = await this.callOpenAI(systemPrompt, userPrompt);

      // Cache the response
      this.setCache(cacheKey, response);

      return response;
    } catch (error) {
      logger.error('[AIService] Error calling OpenAI:', error);
      return this.getFallbackResponse(action);
    }
  }

  private buildUserPrompt(
    action: AIAction,
    additionalContext?: string,
    playerContext?: PlayerContext
  ): string {
    let prompt = '';

    // Add player context
    if (playerContext) {
      const contextParts: string[] = [];

      if (playerContext.playerName) {
        contextParts.push(`O jogador se chama ${playerContext.playerName}.`);
      }

      if (playerContext.currentRegion && playerContext.currentArea) {
        contextParts.push(
          `Está em ${playerContext.currentArea.replace('_', ' ')} na região ${playerContext.currentRegion.replace('_', ' ')}.`
        );
      }

      if (playerContext.competencies && Object.keys(playerContext.competencies).length > 0) {
        const compList = Object.entries(playerContext.competencies)
          .map(([key, value]) => `${key}: ${value}`)
          .join(', ');
        contextParts.push(`Competências: ${compList}.`);
      }

      if (playerContext.nearbyNpcs && playerContext.nearbyNpcs.length > 0) {
        contextParts.push(`NPCs próximos: ${playerContext.nearbyNpcs.join(', ')}.`);
      }

      if (contextParts.length > 0) {
        prompt += 'Contexto do jogador:\n' + contextParts.join('\n') + '\n\n';
      }
    }

    // Add additional context
    if (additionalContext && additionalContext.trim()) {
      prompt += `Situação ou dúvida do jogador:\n${additionalContext}\n\n`;
    }

    // Add action-specific instruction
    switch (action) {
      case 'analyze':
        prompt += 'Por favor, ajude a analisar esta situação.';
        break;
      case 'suggest':
        prompt += 'Por favor, sugira algumas ideias ou possibilidades.';
        break;
      case 'simulate':
        prompt += 'Por favor, simule possíveis consequências.';
        break;
      case 'improve':
        prompt += 'Por favor, sugira como melhorar isso.';
        break;
    }

    return prompt;
  }

  private async callOpenAI(systemPrompt: string, userPrompt: string): Promise<AIQueryResponse> {
    if (!this.apiKey) {
      logger.warn('[AIService] No API key configured, using fallback');
      throw new Error('API key not configured');
    }

    const response = await fetch(this.baseUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${this.apiKey}`,
      },
      body: JSON.stringify({
        model: this.model,
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userPrompt },
        ],
        max_tokens: 500,
        temperature: 0.7,
      }),
    });

    if (!response.ok) {
      throw new Error(`OpenAI API error: ${response.status}`);
    }

    const data = await response.json();
    const aiResponse = data.choices?.[0]?.message?.content || '';
    const tokensUsed = data.usage?.total_tokens || 0;

    logger.info(`[AIService] OpenAI response received, tokens: ${tokensUsed}`);

    return {
      response: aiResponse,
      action: 'analyze', // Will be overwritten by caller
      tokensUsed,
    };
  }

  private getFallbackResponse(action: AIAction): AIQueryResponse {
    const fallbacks: Record<AIAction, string> = {
      analyze:
        'Hmm, deixe-me pensar sobre isso... O que você acha que são os pontos mais importantes dessa situação? Às vezes, olhar de um ângulo diferente ajuda!',
      suggest:
        'Interessante! Algumas possibilidades que você poderia considerar: (1) explorar mais a área, (2) conversar com os moradores, ou (3) usar suas habilidades de forma criativa. O que parece mais interessante para você?',
      simulate:
        'Se você seguir esse caminho, algumas coisas podem acontecer... Você pode descobrir algo novo, mas também pode encontrar desafios. Como você se sentiria se isso acontecesse?',
      improve:
        'Você está no caminho certo! Para melhorar ainda mais, considere: ser mais específico nos detalhes, pensar no impacto das suas escolhas, e não ter medo de experimentar. O que você acha?',
    };

    return {
      response: fallbacks[action],
      action,
      cached: false,
    };
  }

  private getCacheKey(request: AIQueryRequest): string {
    const { action, additionalContext } = request;
    // Simple cache key - in production, consider more sophisticated hashing
    return `${action}:${(additionalContext || '').substring(0, 100)}`;
  }

  private getFromCache(key: string): AIQueryResponse | null {
    const cached = responseCache.get(key);
    if (!cached) return null;

    if (Date.now() - cached.timestamp > CACHE_TTL) {
      responseCache.delete(key);
      return null;
    }

    return cached.response;
  }

  private setCache(key: string, response: AIQueryResponse): void {
    responseCache.set(key, {
      response,
      timestamp: Date.now(),
    });

    // Limit cache size
    if (responseCache.size > 100) {
      const firstKey = responseCache.keys().next().value;
      if (firstKey) responseCache.delete(firstKey);
    }
  }

  // Check if service is ready
  isReady(): boolean {
    return Boolean(this.apiKey);
  }

  // Get service info
  getInfo(): { status: string; provider: string; model: string } {
    return {
      status: this.isReady() ? 'ready' : 'no_api_key',
      provider: 'openai',
      model: this.model,
    };
  }
}

export const aiService = new AIService();
