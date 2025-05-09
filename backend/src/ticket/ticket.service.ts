import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Ticket, TicketDocument } from './ticket.schema';
import { Model } from 'mongoose';
import { CreateTicketDto } from './dto/create-ticket.dto';
import { UpdateTicketDto } from './dto/update-ticket.dto';
import { Seat, SeatDocument } from 'src/seat/seat.schema';

@Injectable()
export class TicketService {
  constructor(
    @InjectModel(Ticket.name) private ticketModel: Model<TicketDocument>,
    @InjectModel(Seat.name) private seatModel: Model<SeatDocument>,
  ) { }

  // async create(dto: CreateTicketDto, userId: string): Promise<Ticket> {
  //   const ticket = new this.ticketModel({
  //     ...dto,
  //     user_id: userId,
  //   });
  //   return ticket.save();
  // }

  async create(dto: CreateTicketDto, userId: string): Promise<Ticket> {
    // Kiểm tra ghế có trống không
    const seat = await this.seatModel.findById(dto.seat_id).exec();
    if (!seat || !seat.is_available) {
      throw new NotFoundException('Ghế không tồn tại hoặc đã được đặt.');
    }

    // Tạo vé
    const ticket = new this.ticketModel({
      ...dto,
      user_id: userId,
    });

    // Cập nhật trạng thái ghế
    await this.seatModel.findByIdAndUpdate(dto.seat_id, { is_available: false }).exec();

    return ticket.save();
  }

  async findAll(): Promise<Ticket[]> {
    return this.ticketModel.find().exec();
  }

  async findOne(id: string): Promise<Ticket> {
    const ticket = await this.ticketModel.findById(id).exec();
    if (!ticket) throw new NotFoundException('Ticket not found');
    return ticket;
  }

  async update(id: string, dto: UpdateTicketDto): Promise<Ticket> {
    const updated = await this.ticketModel
      .findByIdAndUpdate(id, dto, { new: true })
      .exec();
    if (!updated) throw new NotFoundException('Ticket not found');
    return updated;
  }

  async remove(id: string): Promise<void> {
    const result = await this.ticketModel.findByIdAndDelete(id).exec();
    if (!result) throw new NotFoundException('Ticket not found');
  }
}
