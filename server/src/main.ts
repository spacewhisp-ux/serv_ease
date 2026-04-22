import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { NextFunction, Request, Response } from 'express';

import { AppModule } from './app.module';
import { AppExceptionFilter } from './common/exceptions/app.exception-filter';
import { ResponseInterceptor } from './common/interceptors/response.interceptor';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);
  const apiPrefix = configService.get<string>('app.apiPrefix', 'v1');
  const port = configService.get<number>('app.port', 3001);

  app.enableCors({
    origin: [
      'http://localhost:5174',
      'http://127.0.0.1:5174',
    ],
    credentials: true,
  });
  app.setGlobalPrefix(apiPrefix);
  app.use((req: Request, _res: Response, next: NextFunction) => {
    console.log(`${req.method} ${req.url}`);
    next();
  });
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    }),
  );
  app.useGlobalInterceptors(new ResponseInterceptor());
  app.useGlobalFilters(new AppExceptionFilter());

  await app.listen(port);
}

void bootstrap();
