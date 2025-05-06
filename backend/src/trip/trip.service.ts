import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Trip, TripDocument } from './trip.schema';
import { Model } from 'mongoose';
import { CreateTripDto } from './dto/create-trip.dto';
import { UpdateTripDto } from './dto/update-trip.dto';

@Injectable()
export class TripService {
  constructor(@InjectModel(Trip.name) private tripModel: Model<TripDocument>) {}

  async create(createTripDto: CreateTripDto): Promise<Trip> {
    const trip = new this.tripModel(createTripDto);
    return trip.save();
  }

  async findAll(): Promise<Trip[]> {
    return this.tripModel.find().exec();
  }

  async searchTrips(departureId: string, arrivalId: string): Promise<Trip[]> {
    return this.tripModel
      .find({
        departure_location: departureId,
        arrival_location: arrivalId,
      })
      .exec();
  }

  async findOne(id: string): Promise<Trip> {
    const trip = await this.tripModel.findById(id).exec();
    if (!trip) {
      throw new NotFoundException('Trip with id ${id} not found');
    }
    return trip;
  }

  async update(id: string, updateTripDto: UpdateTripDto): Promise<Trip> {
    const updated = await this.tripModel
      .findByIdAndUpdate(id, updateTripDto, { new: true })
      .exec();
    if (!updated) {
      throw new NotFoundException('Trip with id ${id} not found');
    }
    return updated;
  }

  async remove(id: string): Promise<Trip> {
    const deleted = await this.tripModel.findByIdAndDelete(id).exec();
    if (!deleted) {
      throw new NotFoundException('Trip with ID ${id} not found');
    }
    return deleted;
  }
}
