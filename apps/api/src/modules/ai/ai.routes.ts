// ===========================================
// IAção API - AI (ARIA) Routes
// ===========================================

import { Router, Request, Response, NextFunction } from 'express';
import type { Router as IRouter } from 'express';
import { ApiResponse } from '../../types';
import { aiService, AIAction, AIQueryRequest } from '../../services/ai.service';
import { authenticateToken } from '../../middleware/auth';
import { aiRateLimit } from '../../middleware/aiRateLimit';
import { logger } from '../../utils/logger';
import { BadRequestError } from '../../utils/errors';

export const aiRoutes: IRouter = Router();

// Valid actions
const VALID_ACTIONS: AIAction[] = ['analyze', 'suggest', 'simulate', 'improve'];

// Energy costs for each action
const ACTION_ENERGY_COST: Record<AIAction, number> = {
  analyze: 10,
  suggest: 15,
  simulate: 15,
  improve: 20,
};

/**
 * POST /ai/query
 * Query ARIA with an action and context
 */
aiRoutes.post(
  '/query',
  authenticateToken,
  aiRateLimit,
  async (req: Request, res: Response<ApiResponse>, next: NextFunction) => {
    try {
      const { action, additionalContext } = req.body as {
        action?: string;
        additionalContext?: string;
      };

      // Validate action
      if (!action || !VALID_ACTIONS.includes(action as AIAction)) {
        throw new BadRequestError(
          `Invalid action. Valid actions are: ${VALID_ACTIONS.join(', ')}`
        );
      }

      const aiAction = action as AIAction;

      // Check energy cost (optional - can be enforced client-side)
      const energyCost = ACTION_ENERGY_COST[aiAction];

      logger.info(`[AI] Query received: action=${aiAction}, context length=${additionalContext?.length || 0}`);

      // Build request
      const queryRequest: AIQueryRequest = {
        action: aiAction,
        additionalContext,
        // Player context can be sent from client or fetched from user data
        playerContext: req.body.playerContext,
      };

      // Query AI service
      const result = await aiService.query(queryRequest);

      // Log usage for analytics
      logger.info(`[AI] Response generated: tokens=${result.tokensUsed}, cached=${result.cached}`);

      res.json({
        success: true,
        data: {
          response: result.response,
          action: aiAction,
          energyCost,
          cached: result.cached || false,
        },
      });
    } catch (error) {
      next(error);
    }
  }
);

/**
 * GET /ai/health
 * Check AI service health
 */
aiRoutes.get('/health', (req: Request, res: Response<ApiResponse>) => {
  const info = aiService.getInfo();

  res.json({
    success: true,
    data: info,
  });
});

/**
 * GET /ai/actions
 * Get available AI actions with their costs
 */
aiRoutes.get('/actions', (req: Request, res: Response<ApiResponse>) => {
  const actions = VALID_ACTIONS.map((action) => ({
    id: action,
    name: getActionName(action),
    description: getActionDescription(action),
    energyCost: ACTION_ENERGY_COST[action],
  }));

  res.json({
    success: true,
    data: { actions },
  });
});

// Helper functions
function getActionName(action: AIAction): string {
  const names: Record<AIAction, string> = {
    analyze: 'Analisar',
    suggest: 'Sugerir',
    simulate: 'Simular',
    improve: 'Melhorar',
  };
  return names[action];
}

function getActionDescription(action: AIAction): string {
  const descriptions: Record<AIAction, string> = {
    analyze: 'Examina a situação atual e ajuda a entender diferentes aspectos',
    suggest: 'Oferece ideias e possibilidades para você considerar',
    simulate: 'Mostra possíveis consequências de uma escolha',
    improve: 'Analisa algo que você criou e sugere melhorias',
  };
  return descriptions[action];
}
