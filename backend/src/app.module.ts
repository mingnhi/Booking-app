/* eslint-disable @typescript-eslint/no-unsafe-member-access */
import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { MongooseModule } from '@nestjs/mongoose';
import { ConfigModule } from '@nestjs/config';
@Module({
  // imports: [MongooseModule.forRoot('mongodb://localhost:27017/flutterproject')],
  imports: [
    ConfigModule.forRoot(),
    MongooseModule.forRoot(process.env.MONGO_URL as string),
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
