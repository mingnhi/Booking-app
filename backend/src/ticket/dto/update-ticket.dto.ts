import { IsEnum, IsOptional } from 'class-validator';

export class UpdateTicketDto {
  @IsOptional()
  @IsEnum(['booked', 'cancelled', 'completed'])
  ticket_status?: 'booked' | 'cancelled' | 'completed';
}
