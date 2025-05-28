import {
  Body,
  Controller,
  // Delete,
  Get,
  Param,
  Post,
  Put,
  Req,
  SetMetadata,
  UseGuards,
} from '@nestjs/common';
import { ChatService } from './chat.service';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { CreateMessageDto } from './dto/create-message.dto';
import { Types } from 'mongoose';

@Controller('chat')
@UseGuards(JwtAuthGuard)
@SetMetadata('roles', ['user', 'admin'])
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Post('message')
  async sendMessage(@Body() dto: CreateMessageDto, @Req() req) {
    const senderId = new Types.ObjectId(req.user.userId);
    return this.chatService.sendMessage(dto, senderId);
  }

  // @Put('read/:chatRoomId')
  // async markAsRead(@Param('chatRoomId') chatRoomId: string, @Req() req) {
  //   const userId = new Types.ObjectId(req.user.userId);
  //   return this.chatService.markMessagesAsRead(
  //     new Types.ObjectId(chatRoomId),
  //     userId,
  //   );
  // }

  // chat.controller.ts
  @Put('read/:chatRoomId')
  async markAsRead(@Param('chatRoomId') chatRoomId: string, @Req() req) {
    const userId = new Types.ObjectId(req.user.userId);
    const roomId = new Types.ObjectId(chatRoomId);
    return this.chatService.markMessagesAsRead(roomId, userId);
  }


  @Get('rooms')
  async getUserChatRooms(@Req() req) {
    const userId = new Types.ObjectId(req.user.userId);
    return this.chatService.getUserChatRoomsAndMessages(userId);
  }

  @Get('messages/:chatRoomId')
  async getMessages(@Param('chatRoomId') chatRoomId: string) {
    return this.chatService.getMessages(new Types.ObjectId(chatRoomId));
  }
}
