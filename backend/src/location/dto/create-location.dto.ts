import { IsNotEmpty, IsString } from 'class-validator';

export class CreateLocationDto {
  @IsString()
  @IsNotEmpty()
  departure_location: string;

  @IsString()
  @IsNotEmpty()
  arrival_location: string;
}
