import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type TripDocument = Trip & Document;

@Schema({ timestamps: { createdAt: 'create_at' } })
export class Trip {
  @Prop({ type: Types.ObjectId, ref: 'Location', required: true })
  location_id: Types.ObjectId;
  @Prop({ required: true })
  departure_location: string;

  @Prop({ required: true })
  arrival_location: string;

  @Prop({ required: true })
  departure_time: Date;

  @Prop({ required: true })
  arrival_time: Date;

  @Prop({ required: true })
  price: number;

  @Prop({ required: true })
  bus_type: string;

  @Prop({ required: true })
  total_seats: number;
}

export const TripSchema = SchemaFactory.createForClass(Trip);
