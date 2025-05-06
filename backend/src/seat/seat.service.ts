import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Seat, SeatDocument } from './seat.schema';
import { Model } from 'mongoose';
import { CreateSeatDto } from './dto/create-seat.dto';
import { UpdateSeatDto } from './dto/update-seat.dto';

@Injectable()
export class SeatService {
  constructor(@InjectModel(Seat.name) private seatModel: Model<SeatDocument>) {}
  async create(createSeatDto: CreateSeatDto): Promise<Seat> {
    return this.seatModel.create(createSeatDto);
  }

  async findAll(): Promise<Seat[]> {
    return this.seatModel.find().exec();
  }

  async findOne(id: string): Promise<Seat> {
    const seat = await this.seatModel.findById(id).exec();
    if (!seat) {
      throw new NotFoundException('Seat not found');
    }
    return seat;
  }
  async update(id: string, updateSeatDto: UpdateSeatDto): Promise<Seat> {
    const updated = await this.seatModel
      .findByIdAndUpdate(id, updateSeatDto, { new: true })
      .exec();
    if (!updated) throw new NotFoundException('Seat not found');
    return updated;
  }

  async remove(id: string): Promise<void> {
    const result = await this.seatModel.findByIdAndDelete(id).exec();
    if (!result) throw new NotFoundException('Seat not found');
  }
}
