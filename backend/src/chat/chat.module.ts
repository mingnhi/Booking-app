import { Module } from '@nestjs/common';
import { ChatService } from './chat.service';
import { ChatController } from './chat.controller';
import { UsersModule } from 'src/users/users.module';
import { MongooseModule } from '@nestjs/mongoose';
import { Chatroom, ChatroomSchema } from './chatroom.schema';
import { Message, MessageSchema } from './message.schema';
import { ChatGateway } from './chat.gateway';
import { JwtModule } from '@nestjs/jwt';

@Module({
  imports: [
    UsersModule,
    JwtModule.register({ secret: 'dc429f605ae3fdd0bd7d644c968489db7ff08ece3a7b7082942102ee5dd03dad' }),
    MongooseModule.forFeature([
      { name: Chatroom.name, schema: ChatroomSchema },
      { name: Message.name, schema: MessageSchema },
    ]),
  ],
  controllers: [ChatController],
  providers: [ChatService, ChatGateway],
  exports: [ChatService],
})
export class ChatModule {}
