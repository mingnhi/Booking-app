import {
  IsNotEmpty,
  IsMongoId,
  IsDateString,
  IsNumber,
  IsString,
} from 'class-validator';

export class CreateTripDto {
  @IsMongoId()
  @IsNotEmpty()
  location_id: string;

  @IsMongoId()
  @IsNotEmpty()
  departure_location: string;

  @IsMongoId()
  @IsNotEmpty()
  arrival_location: string;

  @IsDateString()
  @IsNotEmpty()
  departure_time: Date;

  @IsDateString()
  @IsNotEmpty()
  arrival_time: Date;

  @IsNumber()
  @IsNotEmpty()
  price: number;

  @IsString()
  @IsNotEmpty()
  bus_type: string;

  @IsNumber()
  @IsNotEmpty()
  total_seats: number;
}
