import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
} from '@nestjs/websockets';
import { ChatService } from './chat.service';
import { Socket } from 'socket.io';
import { CreateMessageDto } from './dto/create-message.dto';
import { Types } from 'mongoose';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  private clients: Record<string, string> = {};

  constructor(private readonly chatService: ChatService) {}

  handleConnection(client: Socket) {
    const userId = client.handshake.query.userId as string;
    if (userId) {
      this.clients[client.id] = userId;
      console.log(`User ${userId} conected`);
    }
  }

  handleDisconnect(client: Socket) {
    const userId = this.clients[client.id];
    delete this.clients[client.id];
    console.log(`User ${userId} disconected`);
  }

  @SubscribeMessage('send_message')
  async handleSendMessage(
    @MessageBody() dto: CreateMessageDto,
    @ConnectedSocket() client: Socket,
  ) {
    const senderId = this.clients[client.id];
    const message = await this.chatService.sendMessage(
      dto,
      new Types.ObjectId(senderId),
    );
    client.broadcast.emit(`chat room ${dto.chat_room_id}`, message);
    return message;
  }

  @SubscribeMessage('mark_as_read')
  async handleMarkAsRead(
    @MessageBody() payload: { chatRoomId: string },
    @ConnectedSocket() client: Socket,
  ) {
    const userId = this.clients[client.id];
    await this.chatService.markMessagesAsRead(
      new Types.ObjectId(payload.chatRoomId),
      new Types.ObjectId(userId),
    );

    client.broadcast.emit(`read_update_${payload.chatRoomId}`, {
      userId,
    });

    return { message: 'Marked as read' };
  }
}
