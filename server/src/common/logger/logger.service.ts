import { mkdirSync, appendFileSync, existsSync, readdirSync, readFileSync, statSync } from 'fs';
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

export interface LogFileInfo {
  date: string;
  fileName: string;
  fileSize: number;
}

export interface LogLine {
  timestamp: string;
  ip: string;
  userId: string;
  account: string;
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

  /** List all available log dates (newest first) */
  listLogDates(): LogFileInfo[] {
    if (!existsSync(this.logDir)) {
      return [];
    }
    const files = readdirSync(this.logDir)
      .filter((f) => f.startsWith('access-') && f.endsWith('.log'))
      .sort()
      .reverse();

    return files.map((fileName) => {
      const date = fileName.replace('access-', '').replace('.log', '');
      const fileSize = statSync(join(this.logDir, fileName)).size;
      return { date, fileName, fileSize };
    });
  }

  /** Read and parse a log file for a given date, with pagination & optional keyword filter */
  readLog(
    date: string,
    options?: { page?: number; pageSize?: number; keyword?: string },
  ): { items: LogLine[]; pagination: { page: number; pageSize: number; total: number; totalPages: number } } {
    const fileName = `access-${date}.log`;
    const filePath = join(this.logDir, fileName);

    if (!existsSync(filePath)) {
      return {
        items: [],
        pagination: { page: 1, pageSize: 20, total: 0, totalPages: 0 },
      };
    }

    const content = readFileSync(filePath, 'utf-8');
    const allLines = content
      .split('\n')
      .filter(Boolean)
      .map((line) => this.parseLine(line))
      .filter(Boolean) as LogLine[];

    const filtered = options?.keyword
      ? allLines.filter((line) =>
          Object.values(line).some((v) =>
            String(v).toLowerCase().includes(options.keyword!.toLowerCase()),
          ),
        )
      : allLines;

    const page = options?.page ?? 1;
    const pageSize = options?.pageSize ?? 20;
    const total = filtered.length;
    const totalPages = Math.ceil(total / pageSize);
    const start = (page - 1) * pageSize;
    const items = filtered.slice(start, start + pageSize);

    return { items, pagination: { page, pageSize, total, totalPages } };
  }

  /** Get the absolute file path for a given date (for downloading) */
  getLogFilePath(date: string): string | null {
    const filePath = join(this.logDir, `access-${date}.log`);
    return existsSync(filePath) ? filePath : null;
  }

  private parseLine(line: string): LogLine | null {
    const parts = line.split(' | ');
    if (parts.length < 8) return null;
    // parts[4] = "METHOD /path" — split back into method & path
    const [method, ...pathParts] = parts[4].split(' ');
    return {
      timestamp: parts[0],
      ip: parts[1],
      userId: parts[2],
      account: parts[3],
      method,
      path: pathParts.join(' '),
      statusCode: Number(parts[5]),
      duration: Number(parts[6].replace('ms', '')),
      response: parts.slice(7).join(' | '), // response itself may contain ' | '
    };
  }
}
