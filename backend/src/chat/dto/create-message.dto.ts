// src/chat/dto/create-message.dto.ts
import { IsNotEmpty, IsString, IsMongoId } from 'class-validator';

export class SendMessageDto {
  @IsMongoId()
  @IsNotEmpty()
  chat_room_id: string;

  @IsString()
  @IsNotEmpty()
  content: string;
}
