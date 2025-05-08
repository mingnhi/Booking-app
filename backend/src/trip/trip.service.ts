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

  // async searchTrips(departureId: string, arrivalId: string): Promise<Trip[]> {
  //   return this.tripModel
  //     .find({
  //       departure_location: departureId,
  //       arrival_location: arrivalId,
  //     })
  //     .exec();
  // }

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

  async searchTrips(
    departure_location?: string,
    arrival_location?: string,
    departure_time?: Date,
  ): Promise<Trip[]> {
    const query: any = {};

    if (departure_location && typeof departure_location === 'string') {
      query.departure_location = {
        $regex: departure_location,
        $options: 'i',
      };
    }

    if (arrival_location && typeof arrival_location === 'string') {
      query.arrival_location = {
        $regex: arrival_location,
        $options: 'i',
      };
    }

    if (departure_time) {
      const start = new Date(departure_time);
      start.setHours(0, 0, 0, 0);
      const end = new Date(departure_time);
      end.setHours(23, 59, 59, 999);
      query.departure_time = { $gte: start, $lte: end };
    }

    return this.tripModel.find(query).exec();
  }
}
