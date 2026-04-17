import { Body, Controller, Delete, Get, Patch } from '@nestjs/common';

import { UsersService } from './users.service';
import { DeleteAccountDto } from './dto/delete-account.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';

@Controller()
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('users/me')
  getMe() {
    return this.usersService.getMe();
  }

  @Patch('users/me')
  updateMe(@Body() dto: UpdateProfileDto) {
    return this.usersService.updateMe(dto);
  }

  @Delete('account')
  deleteAccount(@Body() dto: DeleteAccountDto) {
    return this.usersService.deleteAccount(dto);
  }
}
