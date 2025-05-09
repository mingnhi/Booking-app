import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Delete,
  Put,
  UseGuards,
  SetMetadata,
} from '@nestjs/common';
import { SeatService } from './seat.service';
// import { CreateSeatDto } from './dto/create-seat.dto';
import { UpdateSeatDto } from './dto/update-seat.dto';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { RolesGuard } from 'src/auth/roles.guard';

@Controller('seats')
@UseGuards(JwtAuthGuard, RolesGuard)
export class SeatController {
  constructor(private readonly seatService: SeatService) { }

  // @SetMetadata('roles', ['admin'])
  // @Post()
  // createSeat(@Body() createSeatDto: CreateSeatDto) {
  //   return this.seatService.create(createSeatDto);
  // }

  @SetMetadata('roles', ['user', 'admin'])
  @Get()
  getAll() {
    return this.seatService.findAll();
  }

  @SetMetadata('roles', ['user', 'admin'])
  @Get(':id')
  getOne(@Param('id') id: string) {
    return this.seatService.findOne(id);
  }
  @SetMetadata('roles', ['user', 'admin'])
  @Get('trip/:tripId')
  getByTripId(@Param('tripId') tripId: string) {
    return this.seatService.findByTripId(tripId);
  }

  // @SetMetadata('roles', ['admin'])
  // @Put(':id')
  // updateSeat(@Param('id') id: string, @Body() updateSeatDto: UpdateSeatDto) {
  //   return this.seatService.update(id, updateSeatDto);
  // }

  // @SetMetadata('roles', ['admin'])
  // @Delete(':id')
  // delete(@Param('id') id: string) {
  //   return this.seatService.remove(id);
  // }
}
