import { mkdirSync, appendFileSync, existsSync } from 'fs';
import { join } from 'path';

import { Injectable, Logger } from '@nestjs/common';

export interface AccessLogEntry {
  timestamp: string;
  ip: string;
  userId: string | null;
  account: string | null;
  method: string;
  path: string;
  statusCode: number;
  duration: number;
  response: string;
}

@Injectable()
export class LoggerService {
  private readonly logger = new Logger('AccessLog');
  private readonly logDir: string;

  constructor() {
    this.logDir = join(process.cwd(), 'logs');
    if (!existsSync(this.logDir)) {
      mkdirSync(this.logDir, { recursive: true });
    }
  }

  log(entry: AccessLogEntry): void {
    const logLine = [
      entry.timestamp,
      entry.ip,
      entry.userId ?? '-',
      entry.account ?? '-',
      `${entry.method} ${entry.path}`,
      entry.statusCode,
      `${entry.duration}ms`,
      entry.response,
    ].join(' | ');

    // Console output
    this.logger.log(logLine);

    // File output — one file per day
    const dateStr = new Date().toISOString().slice(0, 10);
    const filePath = join(this.logDir, `access-${dateStr}.log`);
    appendFileSync(filePath, logLine + '\n', 'utf-8');
  }
}
