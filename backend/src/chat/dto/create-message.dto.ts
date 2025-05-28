// src/chat/dto/create-message.dto.ts
import { IsNotEmpty, IsString, IsMongoId } from 'class-validator';

export class CreateMessageDto {
  @IsMongoId()
  @IsNotEmpty()
  chat_room_id: string;

  @IsMongoId()
  @IsNotEmpty()
  sender_id: string;

  @IsString()
  @IsNotEmpty()
  content: string;
}
