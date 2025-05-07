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

@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
@SetMetadata('roles', ['admin'])
export class AdminController {
  constructor(
    private readonly adminService: AdminService,
    private readonly seatService: SeatService,
    private readonly tripService: TripService,
    private readonly ticketService: TicketService,
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
}
