import {
  CallHandler,
  ExecutionContext,
  Inject,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable, tap } from 'rxjs';
import { Request } from 'express';

import { LoggerService } from '../logger/logger.service';

@Injectable()
export class AccessLogInterceptor implements NestInterceptor {
  constructor(
    @Inject(LoggerService) private readonly loggerService: LoggerService,
  ) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const request = context.switchToHttp().getRequest<Request>();
    const startTime = Date.now();

    const ip =
      (request.headers['x-forwarded-for'] as string)?.split(',')[0]?.trim() ??
      request.ip ??
      '-';

    const user = (request as any).user;
    const userId = user?.id ?? null;
    const account = user?.email ?? user?.phone ?? null;

    const method = request.method;
    const path = request.originalUrl;

    return next.handle().pipe(
      tap({
        next: (data) => {
          const duration = Date.now() - startTime;
          this.loggerService.log({
            timestamp: new Date().toISOString(),
            ip,
            userId,
            account,
            method,
            path,
            statusCode: 200,
            duration,
            response: this.truncateResponse(data),
          });
        },
        error: (err) => {
          const duration = Date.now() - startTime;
          const statusCode =
            typeof err?.getStatus === 'function' ? err.getStatus() : 500;
          this.loggerService.log({
            timestamp: new Date().toISOString(),
            ip,
            userId,
            account,
            method,
            path,
            statusCode,
            duration,
            response: this.truncateResponse(
              err?.message ?? 'Internal server error',
            ),
          });
        },
      }),
    );
  }

  private truncateResponse(data: unknown): string {
    const str = typeof data === 'string' ? data : JSON.stringify(data);
    return str.length > 500 ? str.slice(0, 500) + '...[truncated]' : str;
  }
}
