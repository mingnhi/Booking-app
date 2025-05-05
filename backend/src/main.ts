import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors({
    origin: '*', // Thay bằng domain frontend của bạn
    methods: 'GET,POST,PUT,DELETE', // Các phương thức HTTP được phép
    allowedHeaders: 'Content-Type, Authorization', // Các header được phép
  });
  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
