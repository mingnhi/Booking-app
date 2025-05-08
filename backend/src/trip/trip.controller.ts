import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  SetMetadata,
  UseGuards,
} from '@nestjs/common';
import { TripService } from './trip.service';
// import { CreateTripDto } from './dto/create-trip.dto';
// import { UpdateTripDto } from './dto/update-trip.dto';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { RolesGuard } from 'src/auth/roles.guard';

@Controller('trip')
@UseGuards(JwtAuthGuard, RolesGuard)
export class TripController {
  constructor(private readonly tripService: TripService) {}
  // @SetMetadata('roles', ['admin'])
  // @Post()
  // createTrip(@Body() createTripDto: CreateTripDto) {
  //   return this.tripService.create(createTripDto);
  // }

  @SetMetadata('roles', ['user', 'admin'])
  @Get()
  getAll() {
    return this.tripService.findAll();
  }

  @Post('search')
  searchTrips(@Body() body: any) {
    const { departure_location, arrival_location, departure_time } = body;
    return this.tripService.searchTrips(departure_location, arrival_location, departure_time);
  }
  // @Get('search')
  // searchTrips(
  //   @Query('departure') departureId: string,
  //   @Query('arrival') arrivalId: string,
  // ) {
  //   return this.tripService.searchTrips(departureId, arrivalId);
  // }

  @SetMetadata('roles', ['user', 'admin'])
  @Get(':id')
  getOne(@Param('id') id: string) {
    return this.tripService.findOne(id);
  }
}
