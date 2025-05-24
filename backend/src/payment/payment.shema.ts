// src/payment/schemas/payment.schema.ts
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type PaymentDocument = Payment & Document;

@Schema()
export class Payment {
  @Prop({ type: Types.ObjectId, ref: 'Ticket', required: true })
  ticket_id: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'User', required: true })
  user_id: Types.ObjectId;

  @Prop({ required: true })
  amount: number;

  @Prop({ enum: ['paypal', 'cash'], required: true })
  payment_method: string;

  @Prop({
    enum: ['PENDING', 'COMPLETED', 'FAILED', 'REFUNDED'],
    default: 'PENDING',
  })
  payment_status: string;

  @Prop()
  payment_date: Date;
  @Prop()
  paypal_payment_id?: string;
}

export const PaymentSchema = SchemaFactory.createForClass(Payment);
