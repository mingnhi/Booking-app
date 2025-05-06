/* eslint-disable @typescript-eslint/no-unsafe-member-access */
import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { MongooseModule } from '@nestjs/mongoose';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { LocationModule } from './location/location.module';
@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    // MongooseModule.forRoot(process.env.MONGO_URL as string),
    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => ({
        uri: configService.get<string>('MONGODB_URI'),
      }),
      inject: [ConfigService],
    }),
    UsersModule,
    AuthModule,
    LocationModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
