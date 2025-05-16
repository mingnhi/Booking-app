import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Ticket, TicketDocument } from './ticket.schema';
import { Model } from 'mongoose';
import { CreateTicketDto } from './dto/create-ticket.dto';
import { UpdateTicketDto } from './dto/update-ticket.dto';

@Injectable()
export class TicketService {
  constructor(
    @InjectModel(Ticket.name) private ticketModel: Model<TicketDocument>,
  ) {}

  async create(dto: CreateTicketDto): Promise<Ticket> {
    const ticket = new this.ticketModel(dto);
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
  async findTicketByUserId(userId: string): Promise<Ticket[]>{
    return this.ticketModel
      .find({ user_id: userId })
      .populate('user_id', 'full_name phone_number')
      .populate('trip_id', 'departure_location arrival_location price')
      .populate('seat_id', 'seat_number')
      .exec();
  }
}
