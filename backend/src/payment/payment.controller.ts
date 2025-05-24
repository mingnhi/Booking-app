import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Req,
  SetMetadata,
  UseGuards,
} from '@nestjs/common';
import { PaymentService } from './payment.service';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { RolesGuard } from 'src/auth/roles.guard';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { Payment } from './payment.shema';
// import { UpdatePayMentDto } from './dto/update-payment.dto';

@Controller('payment')
export class PaymentController {
  constructor(private readonly paymentService: PaymentService) { }
  @UseGuards(JwtAuthGuard, RolesGuard)
  @SetMetadata('roles', ['user'])
  @Post()
  create(@Body() createPaymentDto: CreatePaymentDto, @Req() req: any) {
    const userId = req.user.userId;
    return this.paymentService.create(userId, createPaymentDto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @SetMetadata('roles', ['user'])
  @Get()
  async findAll(): Promise<Payment[]> {
    return this.paymentService.findAll();
  }

  // @UseGuards(JwtAuthGuard, RolesGuard)
  // @SetMetadata('roles', ['user'])
  // @Get('ticket/:ticketId')
  // findByTicket(@Param('ticketId') ticketId: string) {
  //   return this.paymentService.findbyTicketId(ticketId);
  // }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @SetMetadata('roles', ['user'])
  @Get('user/:userId')
  async findByUserId(@Param('userId') userId: string) {
    return this.paymentService.findByUserId(userId);
  }

  @Get('success')
  success() {
    return { message: 'Payment completed successfully' };
  }

  @Get('cancel')
  cancel() {
    return { message: 'Payment was cancelled' };
  }
}
