import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

import { AppModule } from './app.module';
import { AppExceptionFilter } from './common/exceptions/app.exception-filter';
import { ResponseInterceptor } from './common/interceptors/response.interceptor';
import { AccessLogInterceptor } from './common/interceptors/access-log.interceptor';
import { LoggerService } from './common/logger/logger.service';

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
  app.useGlobalInterceptors(
    new AccessLogInterceptor(app.get(LoggerService)),
    new ResponseInterceptor(),
  );
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    }),
  );
  app.useGlobalFilters(new AppExceptionFilter());

  await app.listen(port);
}

void bootstrap();
