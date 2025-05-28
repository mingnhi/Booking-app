import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Date, Types } from 'mongoose';

export type ChatroomDocument = Chatroom & Document;

@Schema()
export class Chatroom {
  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  participants: Types.ObjectId[];

  @Prop()
  name?: string;

  @Prop({ default: false })
  is_group: boolean;

  @Prop({ type: Date })
  create_at: Date;
}

export const ChatroomSchema = SchemaFactory.createForClass(Chatroom);
