import { Module } from '@nestjs/common';
import { AdminService } from './admin.service';
import { AdminController } from './admin.controller';
import { UsersModule } from 'src/users/users.module';
import { TripModule } from 'src/trip/trip.module';
import { SeatModule } from 'src/seat/seat.module';
import { TicketModule } from 'src/ticket/ticket.module';

@Module({
  imports: [UsersModule, TripModule, SeatModule, TicketModule],
  controllers: [AdminController],
  providers: [AdminService],
})
export class AdminModule {}
