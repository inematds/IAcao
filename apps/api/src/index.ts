// ===========================================
// IAção API - Entry Point
// ===========================================

import { createApp } from './app';
import { config } from './config';
import { logger } from './utils/logger';

async function main() {
  try {
    const app = await createApp();

    app.listen(config.port, () => {
      logger.info(`🚀 IAção API running on port ${config.port}`);
      logger.info(`📚 Environment: ${config.nodeEnv}`);
      logger.info(`🔗 API URL: ${config.apiUrl}`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
}

main();
