import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';

@Injectable()
export class LocationService {
    constructor(
        @InjectModel(Location.name)
    )
}
