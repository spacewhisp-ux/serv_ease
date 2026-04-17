import {
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { UserRole } from '@prisma/client';
import * as bcrypt from 'bcryptjs';
import { randomUUID } from 'crypto';
import { type StringValue } from 'ms';

import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { RegisterDto } from './dto/register.dto';
import { JwtPayload } from './jwt-payload.interface';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async register(dto: RegisterDto) {
    await this.ensureUniqueIdentity(dto.email, dto.phone);

    const passwordHash = await bcrypt.hash(dto.password, 10);
    const user = await this.prisma.user.create({
      data: {
        email: dto.email,
        phone: dto.phone,
        passwordHash,
        displayName: dto.displayName,
        role: UserRole.USER,
      },
      select: {
        id: true,
        email: true,
        phone: true,
        displayName: true,
        role: true,
      },
    });

    const tokens = await this.issueTokens(user.id, user.role);
    await this.createSession(user.id, tokens.refreshToken, dto.deviceId, dto.deviceName);

    return {
      user,
      ...tokens,
    };
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findFirst({
      where: {
        OR: [{ email: dto.account }, { phone: dto.account }],
        status: 'ACTIVE',
      },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const passwordMatches = await bcrypt.compare(dto.password, user.passwordHash);
    if (!passwordMatches) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const tokens = await this.issueTokens(user.id, user.role);
    await Promise.all([
      this.createSession(user.id, tokens.refreshToken, dto.deviceId, dto.deviceName),
      this.prisma.user.update({
        where: { id: user.id },
        data: { lastLoginAt: new Date() },
      }),
    ]);

    return {
      user: {
        id: user.id,
        email: user.email,
        phone: user.phone,
        displayName: user.displayName,
        role: user.role,
      },
      ...tokens,
    };
  }

  async refresh(dto: RefreshTokenDto) {
    const payload = await this.verifyRefreshToken(dto.refreshToken);
    const session = await this.findActiveSession(payload.sub, dto.refreshToken);

    if (!session || session.user.status !== 'ACTIVE') {
      throw new UnauthorizedException('Invalid refresh token');
    }

    const tokens = await this.issueTokens(session.user.id, session.user.role);
    await this.prisma.userSession.update({
      where: { id: session.id },
      data: {
        refreshTokenHash: await bcrypt.hash(tokens.refreshToken, 10),
        expiresAt: this.getRefreshTokenExpiry(),
      },
    });

    return tokens;
  }

  async logout(dto: RefreshTokenDto) {
    const payload = await this.verifyRefreshToken(dto.refreshToken);
    const session = await this.findActiveSession(payload.sub, dto.refreshToken);

    if (session) {
      await this.prisma.userSession.update({
        where: { id: session.id },
        data: { revokedAt: new Date() },
      });
    }

    return { loggedOut: true };
  }

  private async ensureUniqueIdentity(email?: string, phone?: string) {
    if (!email && !phone) {
      throw new ConflictException('Email or phone is required');
    }

    const existingUser = await this.prisma.user.findFirst({
      where: {
        OR: [email ? { email } : undefined, phone ? { phone } : undefined].filter(
          Boolean,
        ) as Array<{ email?: string; phone?: string }>,
      },
      select: { id: true },
    });

    if (existingUser) {
      throw new ConflictException('User already exists');
    }
  }

  private async issueTokens(userId: string, role: UserRole) {
    const payload: JwtPayload = { sub: userId, role };
    const refreshSecret = this.configService.getOrThrow<string>('app.jwt.refreshSecret');
    const refreshExpiresIn = this.configService.get<string>(
      'app.jwt.refreshExpiresIn',
      '30d',
    ) as StringValue;

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload),
      this.jwtService.signAsync(payload, {
        secret: refreshSecret,
        expiresIn: refreshExpiresIn,
        jwtid: randomUUID(),
      }),
    ]);

    return { accessToken, refreshToken };
  }

  private async createSession(
    userId: string,
    refreshToken: string,
    deviceId?: string,
    deviceName?: string,
  ) {
    await this.prisma.userSession.create({
      data: {
        userId,
        refreshTokenHash: await bcrypt.hash(refreshToken, 10),
        deviceId,
        deviceName,
        platform: 'ios',
        expiresAt: this.getRefreshTokenExpiry(),
      },
    });
  }

  private async verifyRefreshToken(refreshToken: string) {
    try {
      return await this.jwtService.verifyAsync<JwtPayload>(refreshToken, {
        secret: this.configService.getOrThrow<string>('app.jwt.refreshSecret'),
      });
    } catch {
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  private async findActiveSession(userId: string, refreshToken: string) {
    const sessions = await this.prisma.userSession.findMany({
      where: {
        userId,
        revokedAt: null,
        expiresAt: { gt: new Date() },
      },
      include: {
        user: {
          select: {
            id: true,
            role: true,
            status: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    for (const session of sessions) {
      const matches = await bcrypt.compare(refreshToken, session.refreshTokenHash);
      if (matches) {
        return session;
      }
    }

    return null;
  }

  private getRefreshTokenExpiry() {
    return new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
  }
}
