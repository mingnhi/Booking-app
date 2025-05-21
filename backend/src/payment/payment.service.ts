import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Payment, PaymentDocument } from './payment.shema';
import { Model } from 'mongoose';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { Ticket, TicketDocument } from 'src/ticket/ticket.schema';
import { Seat, SeatDocument } from 'src/seat/seat.schema';
import path from 'path';

@Injectable()
export class PaymentService {
  constructor(
    @InjectModel(Payment.name) private paymentModel: Model<PaymentDocument>,
    @InjectModel(Ticket.name) private ticketModel: Model<TicketDocument>,
    @InjectModel(Seat.name) private seatModel: Model<SeatDocument>,
  ) {}

  async create(
    userId: string,
    createPaymentDto: CreatePaymentDto,
  ): Promise<{ message: string; ticketStatus: string }> {
    const {
      ticket_id,
      amount,
      payment_method,
      payment_status,
      paypal_payment_id,
    } = createPaymentDto;
    const ticket = await this.ticketModel.findById(ticket_id);
    if (!ticket) throw new NotFoundException('Ticket not found');

    if (ticket.user_id.toString() !== userId) throw new ForbiddenException();

    if (payment_method === 'paypal' && !paypal_payment_id) {
      throw new Error('Thiếu mã thanh toán PayPal');
    }

    if (payment_method === 'cash' && paypal_payment_id) {
      throw new Error('Thanh toán tiền mặt không cần mã PayPal');
    }
    ticket.ticket_status = createPaymentDto.payment_status === 'COMPLETED' ? 'COMPLETED' : 'BOOKED';
    await ticket.save();

    if (payment_status === 'COMPLETED') {
      await this.seatModel.findByIdAndUpdate(ticket.seat_id, {
        is_available: false,
      });
    }

    const payment = new this.paymentModel({
      user_id: userId,
      ticket_id,
      amount,
      payment_method,
      payment_status,
      paypal_payment_id,
      payment_date: new Date(),
    });

    return {
      message: 'Thanh toán đã được ghi nhận',
      ticketStatus: ticket.ticket_status,
    };
  }

  async findAll(): Promise<Payment[]> {
    return this.paymentModel
      .find()
      .populate('user_id', 'full_name')
      .populate({
        path: 'ticket_id',
        populate: [
          {
            path: 'trip_id',
            select: 'departure_location arrival_location price',
          },
          { path: 'seat_id', select: 'seat_number' },
        ],
      })
      .exec();
  }

  async findbyTicketId(ticketId: string): Promise<Payment> {
    const payment = await this.paymentModel
      .findOne({ ticket_id: ticketId })
      .populate('user_id', 'full_name')
      .exec();
    if (!payment) {
      throw new NotFoundException('Payment with id ${ticketId} not found');
    }
    return payment;
  }

  async update(id: string, status: string): Promise<Payment> {
    const payment = await this.paymentModel.findByIdAndUpdate(id);
    if (!payment) {
      throw new NotFoundException('Payment with not found');
    }
    payment.payment_status = status;
    payment.payment_date = new Date();
    return payment.save();
  }
}
