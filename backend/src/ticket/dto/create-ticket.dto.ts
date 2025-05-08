import { IsMongoId, IsEnum } from 'class-validator';

export class CreateTicketDto {
  @IsMongoId()
  trip_id: string;

  @IsMongoId()
  seat_id: string;

  @IsEnum(['booked', 'cancelled', 'completed'])
  ticket_status?: 'BOOKED' | 'CANCELLED' | 'COMPLETED';
}
