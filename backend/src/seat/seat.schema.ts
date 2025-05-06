import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type SeatDocument = Seat & Document;
@Schema({ timestamps: true })
export class Seat {
  @Prop({ type: Types.ObjectId, ref: 'Trip', required: true })
  trip_id: Types.ObjectId;

  @Prop({ required: true })
  seat_number: number;

  @Prop({ default: true })
  is_available: boolean;
}
export const SeatSchema = SchemaFactory.createForClass(Seat);
