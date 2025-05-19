import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Payment, PaymentDocument } from './payment.shema';
import { Model } from 'mongoose';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { UpdatePayMentDto } from './dto/update-payment.dto';

@Injectable()
export class PaymentService {
  constructor(
    @InjectModel(Payment.name) private paymentModel: Model<PaymentDocument>,
  ) {}

  async create(createPaymentDto: CreatePaymentDto): Promise<PaymentDocument> {
    const payment = new this.paymentModel({
      ...createPaymentDto,
      payment_date: createPaymentDto.payment_date || new Date(),
    });
    return payment.save();
  }

  async findAll(): Promise<Payment[]> {
    return this.paymentModel.find().exec();
  }

  async findbyTicketId(ticketId: string): Promise<Payment> {
    const payment = await this.paymentModel
      .findById({ ticket_id: ticketId })
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
