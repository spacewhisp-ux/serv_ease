import { Injectable } from '@nestjs/common';

import { DeleteAccountDto } from './dto/delete-account.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';

@Injectable()
export class UsersService {
  getMe() {
    return {
      id: 'placeholder-user-id',
      email: 'user@example.com',
      displayName: 'Demo User',
      role: 'USER',
    };
  }

  updateMe(dto: UpdateProfileDto) {
    return {
      id: 'placeholder-user-id',
      displayName: dto.displayName ?? 'Demo User',
      avatarUrl: dto.avatarUrl ?? null,
    };
  }

  deleteAccount(dto: DeleteAccountDto) {
    return {
      requested: true,
      reason: dto.reason ?? null,
    };
  }
}
