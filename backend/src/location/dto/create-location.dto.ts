import { IsString } from 'class-validator';

export class CreateLocationDto {
  @IsString()
  location: string;
}
