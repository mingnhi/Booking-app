import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type TripDocument = Trip & Document;

@Schema({ timestamps: { createdAt: 'created_at' } })
export class Trip {
  @Prop({ type: Types.ObjectId, ref: 'Location', required: true })
  location_id: Types.ObjectId;

  @Prop({ required: true })
  departure_location: string;

  @Prop({ required: true })
  arrival_location: string;

  @Prop({ type: Date, required: true })
  departure_time: Date;

  @Prop({ type: Date, required: true })
  arrival_time: Date;

  @Prop({ type: Number, required: true })
  price: number;

  @Prop({ required: true })
  bus_type: string;

  @Prop({ type: Number, required: true })
  total_seats: number;
}

export const TripSchema = SchemaFactory.createForClass(Trip);
