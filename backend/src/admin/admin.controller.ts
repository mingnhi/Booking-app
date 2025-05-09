import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
  SetMetadata,
  UseGuards,
} from '@nestjs/common';
import { AdminService } from './admin.service';
import { SeatService } from 'src/seat/seat.service';
import { TripService } from 'src/trip/trip.service';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { RolesGuard } from 'src/auth/roles.guard';
import { CreateSeatDto } from 'src/seat/dto/create-seat.dto';
import { UpdateSeatDto } from 'src/seat/dto/update-seat.dto';
import { CreateTripDto } from 'src/trip/dto/create-trip.dto';
import { UpdateTripDto } from 'src/trip/dto/update-trip.dto';
import { TicketService } from 'src/ticket/ticket.service';
import { UpdateTicketDto } from 'src/ticket/dto/update-ticket.dto';
import { UsersService } from 'src/users/user.service';
import { Users } from 'src/users/users.schema';
import { LocationService } from 'src/location/location.service';
import { UpdateLocationDto } from 'src/location/dto/update-location.dto';
import { CreateLocationDto } from 'src/location/dto/create-location.dto';

@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@SetMetadata('roles', ['admin'])
export class AdminController {
  constructor(
    private readonly adminService: AdminService,
    private readonly seatService: SeatService,
    private readonly tripService: TripService,
    private readonly ticketService: TicketService,
    private readonly userService: UsersService,
    private readonly locationService: LocationService,
  ) {}
  @Post('seat')
  createSeat(@Body() createSeatDto: CreateSeatDto) {
    return this.seatService.create(createSeatDto);
  }
  @Get('seat')
  getAllSeat() {
    return this.seatService.findAll();
  }

  @Get('seat/:id')
  getOneSeat(@Param('id') id: string) {
    return this.seatService.findOne(id);
  }
  @Put('seat/:id')
  updateSeat(@Param('id') id: string, @Body() updateSeatDto: UpdateSeatDto) {
    return this.seatService.update(id, updateSeatDto);
  }
  @Delete('seat/:id')
  deleteSeat(@Param('id') id: string) {
    return this.seatService.remove(id);
  }
  @Post('trip')
  createTrip(@Body() createTripDto: CreateTripDto) {
    return this.tripService.create(createTripDto);
  }
  @Get('trip')
  getAllTrip() {
    return this.tripService.findAll();
  }
  @Get('trip/:id')
  getOneTrip(@Param('id') id: string) {
    return this.tripService.findOne(id);
  }

  @Put('trip/:id')
  updateTrip(@Param('id') id: string, @Body() updateTripDto: UpdateTripDto) {
    return this.tripService.update(id, updateTripDto);
  }
  @Delete('trip/:id')
  deleteTrip(@Param('id') id: string) {
    return this.tripService.remove(id);
  }
  @Get('ticket')
  getAllTicket() {
    return this.ticketService.findAll();
  }
  @Get('ticket/:id')
  getOneTicket(@Param('id') id: string) {
    return this.ticketService.findOne(id);
  }
  @Put('ticket/:id')
  updateTicker(@Param('id') id: string, @Body() dto: UpdateTicketDto) {
    return this.ticketService.update(id, dto);
  }
  @Delete('ticket/:id')
  deleteTicket(@Param('id') id: string) {
    return this.ticketService.remove(id);
  }
  @Get('users')
  async getAllUser() {
    return this.userService.findAll();
  }
  @Put('users/:id')
  async updateUser(
    @Param('id') id: string,
    @Body() updateData: Partial<Users>,
  ) {
    return this.userService.update(id, updateData);
  }
  @Delete('users/:id')
  async deleteUser(@Param('id') id: string) {
    await this.userService.delete(id);
    return { message: 'xoá người dùng thành công' };
  }
  @Post('location')
  createLocation(@Body() dto: CreateLocationDto) {
    return this.locationService.create(dto);
  }

  @Get('location')
  getAllLocation() {
    return this.locationService.findAll();
  }

  @Get('location/:id')
  getOneLocation(@Param('id') id: string) {
    return this.locationService.findOne(id);
  }

  @Put('location/:id')
  updateLocation(@Param('id') id: string, @Body() dto: UpdateLocationDto) {
    return this.locationService.update(id, dto);
  }

  @Delete('loaction/:id')
  deleteLocation(@Param('id') id: string) {
    return this.locationService.remove(id);
  }
}
