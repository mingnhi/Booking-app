import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Put,
  UseGuards,
  SetMetadata,
  Req,
} from '@nestjs/common';
import { TicketService } from './ticket.service';
import { CreateTicketDto } from './dto/create-ticket.dto';
import { UpdateTicketDto } from './dto/update-ticket.dto';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { RolesGuard } from 'src/auth/roles.guard';

@Controller('tickets')
@UseGuards(JwtAuthGuard, RolesGuard)
export class TicketController {
  constructor(private readonly ticketService: TicketService) {}

  @SetMetadata('roles', ['user'])
  @Post()
  createTicket(@Body() dto: CreateTicketDto, @Req() req: any) {
    const userId = req.user?.userId;
    return this.ticketService.create(dto, userId);
  }

  // @SetMetadata('roles', ['admin'])
  // @Get()
  // getAll() {
  //   return this.ticketService.findAll();
  // }

  @SetMetadata('roles', ['user', 'admin'])
  @Get(':id')
  getOne(@Param('id') id: string) {
    return this.ticketService.findOne(id);
  }

  @SetMetadata('roles', ['user', 'admin'])
  @Put(':id')
  updateTicker(@Param('id') id: string, @Body() dto: UpdateTicketDto) {
    return this.ticketService.update(id, dto);
  }

  // @SetMetadata('roles', ['admin'])
  // @Delete(':id')
  // delete(@Param('id') id: string) {
  //   return this.ticketService.remove(id);
  // }
}
