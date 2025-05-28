import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  WebSocketGateway,
} from '@nestjs/websockets';
import { ChatService } from './chat.service';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectModel } from '@nestjs/mongoose';
import { Message } from './message.schema';
import { Model } from 'mongoose';
import { Chatroom } from './chatroom.schema';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  private logger: Logger = new Logger('ChatGateway');
  constructor(
    private readonly jwtService: JwtService,
    @InjectModel(Message.name) private messageModel: Model<Message>,
    @InjectModel(Chatroom.name) private chatroomModel: Model<Chatroom>,
  ) { }

  afterInit(server: Server) {
    this.logger.log('Websocket Server Initialized');
  }
  handleDisconnect(client: Socket) {
    this.logger.log(`Client disconnected: ${client.id}`);
  }
  async handleConnection(client: Socket) {
    try {
      const token = client.handshake.auth?.token;
      const payload = this.jwtService.verify(token);
      client.data.user = payload;
      this.logger.log(`Client connected: ${payload.email}`);
    } catch (e) {
      this.logger.error('Invalid token');
      client.disconnect();
    }
  }
  
  @SubscribeMessage('message')
    async handleMessage(
      @MessageBody() data: { chat_room_id: string; content: string },
      @ConnectedSocket() client: Socket,
  ){
      const sender = client.data.user;
      const msg = await this.messageModel.create({
        chat_room_id: data.chat_room_id,
        sender_id: sender.userId,
        content: data.content,
      });
    
      client.broadcast.emit('message', msg);
      client.emit('message', msg);
    }

  @SubscribeMessage('send_message')
  async onMessage(@MessageBody() data: any, @ConnectedSocket() client: Socket) {
    const sender = client.data.user;
    const message = await this.messageModel.create({
      chat_room_id: data.chat_room_id,
      sender_id: sender.sub,
      content: data.content,
    });

    client.broadcast.emit(`chat/${data.chat_room_id}`, message);
    client.emit(`chat/${data.chat_room_id}`, message);
  }  
  
}
