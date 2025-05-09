import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Trip, TripDocument } from './trip.schema';
import { Model } from 'mongoose';
import { CreateTripDto } from './dto/create-trip.dto';
import { UpdateTripDto } from './dto/update-trip.dto';
import { Seat, SeatDocument } from 'src/seat/seat.schema';

@Injectable()
export class TripService {
  constructor(
    @InjectModel(Trip.name) private tripModel: Model<TripDocument>,
    @InjectModel(Seat.name) private seatModel: Model<SeatDocument>,
  ) {}

  async create(createTripDto: CreateTripDto): Promise<Trip> {
    const newTrip = await this.tripModel.create(createTripDto);

    const seats: Partial<SeatDocument>[] = [];
    for (let i = 1; i <= createTripDto.total_seats; i++) {
      seats.push({
        trip_id: newTrip._id,
        seat_number: i,
        is_available: true,
      });
    }
    await this.seatModel.insertMany(seats);
    return newTrip;
  }

  async findAll(): Promise<Trip[]> {
    return this.tripModel.find().populate('location_id').exec();
  }

  async findOne(id: string): Promise<Trip> {
    const trip = await this.tripModel
      .findById(id)
      .populate('location_id')
      .exec();
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
