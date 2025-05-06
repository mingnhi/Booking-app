import { IsBoolean, IsNumber, IsMongoId } from 'class-validator';

export class CreateSeatDto {
  @IsMongoId()
  trip_id: string;

  @IsNumber()
  seat_number: number;

  @IsBoolean()
  is_available: boolean;
}
