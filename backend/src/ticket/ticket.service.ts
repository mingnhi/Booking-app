import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
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

  //
  async create(dto: CreateTicketDto, userId: string): Promise<Ticket> {
    const seat = await this.seatModel.findById(dto.seat_id);
    if (!seat) {
      throw new NotFoundException('Không tìm thấy ghế');
    }

    if (!seat.is_available) {
      throw new BadRequestException(' Ghế đã được đặt');
    }

    await this.seatModel.findByIdAndUpdate(dto.seat_id, {
      is_available: false,
    });
    const ticket = new this.ticketModel({
      ...dto,
      user_id: userId,
    });
    await ticket.save();

    const populatedTicket = await this.ticketModel.findById(ticket._id)
      .populate('user_id', 'full_name phone_number')
      .populate('trip_id', 'departure_location arrival_location price')
      .populate('seat_id', 'seat_number')
      .exec();

    if (!populatedTicket) {
      throw new NotFoundException('Không tìm thấy vé sau khi tạo');
    }

    return populatedTicket;
  }

  async findAll(): Promise<Ticket[]> {
    return this.ticketModel
      .find()
      .populate('user_id', 'full_name phone_number')
      .populate('trip_id', 'departure_location arrival_location price')
      .populate('seat_id', 'seat_number')
      .exec();
  }

  async findOne(id: string): Promise<Ticket> {
    const ticket = await this.ticketModel
      .findById(id)
      .populate('user_id', 'full_name phone_number')
      .populate('trip_id', 'departure_location arrival_location price')
      .populate('seat_id', 'seat_number')
      .exec();
    if (!ticket) throw new NotFoundException('Ticket not found');
    return ticket;
  }

  async update(id: string, updateDto: UpdateTicketDto): Promise<Ticket> {
    const ticket = await this.ticketModel.findById(id);
    if (!ticket) throw new NotFoundException('Không tìm thấy vé');

    // Nếu hủy vé => cập nhật ghế thành trống
    if (updateDto.ticket_status === 'CANCELLED') {
      await this.seatModel.findByIdAndUpdate(ticket.seat_id, {
        is_available: true,
      });
    }

    ticket.ticket_status = updateDto.ticket_status ?? ticket.ticket_status;
    await ticket.save();

    const updatedTicket = await this.ticketModel
      .findById(ticket._id)
      .populate('user_id', 'full_name phone_number')
      .populate('trip_id', 'departure_location arrival_location price')
      .populate('seat_id', 'seat_number')
      .exec();
    if (!updatedTicket) {
      throw new NotFoundException('Không tìm thấy vé sau khi cập nhật');
    }
    return updatedTicket;
  }

  async remove(id: string): Promise<void> {
    const result = await this.ticketModel.findByIdAndDelete(id).exec();
    if (result) {
      await this.seatModel.findByIdAndUpdate(result.seat_id, {
        is_available: true,
      });
      if (!result) throw new NotFoundException('Không tìm thấy vé để xoá');
    }
  }
}