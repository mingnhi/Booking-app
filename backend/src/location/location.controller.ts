import {
  // Body,
  Controller,
  Get,
  // Delete,
  // Get,
  // Param,
  // Post,
  // Put,
  SetMetadata,
  UseGuards,
} from '@nestjs/common';
import { LocationService } from './location.service';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { RolesGuard } from 'src/auth/roles.guard';

@Controller('location')
@UseGuards(JwtAuthGuard, RolesGuard)
@SetMetadata('roles', ['user'])
export class LocationController {
  constructor(private readonly locationService: LocationService) {}

  // @Post()
  // createLocation(@Body() dto: CreateLocationDto) {
  //   return this.locationService.create(dto);
  // }

  @Get()
  findAll() {
    return this.locationService.findAll();
  }

  // @Get(':id')
  // findOne(@Param('id') id: string) {
  //   return this.locationService.findOne(id);
  // }

  // @Put(':id')
  // updateLocation(@Param('id') id: string, @Body() dto: UpdateLocationDto) {
  //   return this.locationService.update(id, dto);
  // }

  // @Delete(':id')
  // delete(@Param('id') id: string) {
  //   return this.locationService.remove(id);
  // }
}
