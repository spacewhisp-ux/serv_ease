import { Injectable } from '@nestjs/common';

import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { RegisterDto } from './dto/register.dto';

@Injectable()
export class AuthService {
  register(dto: RegisterDto) {
    return {
      user: {
        id: 'placeholder-user-id',
        email: dto.email ?? null,
        phone: dto.phone ?? null,
        displayName: dto.displayName,
        role: 'USER',
      },
      accessToken: 'placeholder-access-token',
      refreshToken: 'placeholder-refresh-token',
    };
  }

  login(dto: LoginDto) {
    return {
      user: {
        id: 'placeholder-user-id',
        account: dto.account,
        displayName: 'Demo User',
        role: 'USER',
      },
      accessToken: 'placeholder-access-token',
      refreshToken: 'placeholder-refresh-token',
    };
  }

  refresh(_dto: RefreshTokenDto) {
    return {
      accessToken: 'placeholder-access-token',
      refreshToken: 'placeholder-refresh-token',
    };
  }

  logout(_dto: RefreshTokenDto) {
    return { loggedOut: true };
  }
}
