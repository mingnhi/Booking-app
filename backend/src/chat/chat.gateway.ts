import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { ChatService } from './chat.service';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectModel } from '@nestjs/mongoose';
import { Message } from './message.schema';
import { Model } from 'mongoose';
import { Chatroom } from './chatroom.schema';
import { SendMessageDto } from './dto/create-message.dto';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;
  private logger: Logger = new Logger('ChatGateway');
  constructor(
    private readonly jwtService: JwtService,
    private readonly chatService: ChatService,
    @InjectModel(Message.name) private messageModel: Model<Message>,
    @InjectModel(Chatroom.name) private chatroomModel: Model<Chatroom>,
  ) {}

  afterInit() {
    this.logger.log('Websocket Server Initialized');
  }
  handleDisconnect(client: Socket) {
    this.logger.log(`Client disconnected: ${client.id}`);
  }
  async handleConnection(client: Socket) {
    const token = client.handshake.auth?.token;
    try {
      const payload = this.jwtService.verify(token);
      client.data.user = payload;
      this.logger.log(`Client connected: ${payload.email || payload.sub}`);
    } catch (err) {
      this.logger.error('Invalid token');
      client.disconnect();
    }
  }

  @SubscribeMessage('send_message')
  async handleSendMessage(
    @MessageBody() data: SendMessageDto,
    @ConnectedSocket() client: Socket,
  ) {
    const sender = client.data.user;
    if (!sender) return;

    const message = await this.chatService.createMessage(
      data.chat_room_id,
      sender.sub || sender.userId,
      data.content,
    );

    this.server.to(data.chat_room_id).emit('receive_message', message);
  }
}
