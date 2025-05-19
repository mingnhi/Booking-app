import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Put,
  SetMetadata,
  UseGuards,
} from '@nestjs/common';
import { PaymentService } from './payment.service';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { RolesGuard } from 'src/auth/roles.guard';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { UpdatePayMentDto } from './dto/update-payment.dto';

@Controller('payment')
@UseGuards(JwtAuthGuard, RolesGuard)
@SetMetadata('roles', ['user'])
export class PaymentController {
  constructor(private readonly paymentService: PaymentService) {}

  @Post()
  create(@Body() createPaymentDto: CreatePaymentDto) {
    return this.paymentService.create(createPaymentDto);
  }

  @Get()
  findAll() {
    return this.paymentService.findAll();
  }

  @Get('ticket/:ticketId')
  findByTicket(@Param('ticketId') ticketId: string) {
    return this.paymentService.findbyTicketId(ticketId);
  }

  @Put(':id')
  async updateStatus(
    @Param('id') id: string,
    @Body('payment_status') status: 'PENDING' | 'COMPLETED' | 'FAILED',
  ) {
    return this.paymentService.update(id, status);
  }
}
