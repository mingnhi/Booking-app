import { Module } from '@nestjs/common';
import { ChatService } from './chat.service';
import { ChatController } from './chat.controller';
import { UsersModule } from 'src/users/users.module';
import { MongooseModule } from '@nestjs/mongoose';
import { Chatroom, ChatroomSchema } from './chatroom.schema';
import { Message, MessageSchema } from './message.schema';
import { ChatGateway } from './chat.gateway';

@Module({
  imports: [
    UsersModule,
    MongooseModule.forFeature([
      { name: Chatroom.name, schema: ChatroomSchema },
      { name: Message.name, schema: MessageSchema },
    ]),
  ],
  controllers: [ChatController],
  providers: [ChatService, ChatGateway],
  exports:[ChatService],
})
export class ChatModule {}
