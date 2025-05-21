// src/payment/dto/create-payment.dto.ts
import {
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
} from 'class-validator';

export class CreatePaymentDto {
  @IsString()
  @IsNotEmpty()
  ticket_id: string;

  @IsNumber()
  amount: number;

  @IsEnum(['paypal', 'cash'])
  payment_method: 'paypal' | 'cash';

  @IsEnum(['PENDING', 'COMPLETED', 'FAILED'])
  @IsOptional()
  payment_status?: 'PENDING' | 'COMPLETED' | 'FAILED';

  @IsOptional()
  payment_date?: Date;

  @IsOptional()
  @IsString()
  paypal_payment_id?: string;
}
