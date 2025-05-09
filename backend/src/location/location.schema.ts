import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type LocationDocument = Location & Document;

@Schema({ timestamps: true })
export class Location {
  @Prop({ required: true })
  departure_location: string;

  @Prop({ required: true })
  arrival_location: string;
}

export const LocationSchema = SchemaFactory.createForClass(Location);
