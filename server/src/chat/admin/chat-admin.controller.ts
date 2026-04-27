import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';

import { AuthenticatedUser } from '../../auth/authenticated-user.interface';
import { CurrentUser } from '../../common/current-user.decorator';
import { JwtAuthGuard } from '../../common/jwt-auth.guard';
import { ChatAdminService } from './chat-admin.service';
import { CreateChatQuestionDto } from './dto/create-chat-question.dto';
import { UpdateChatQuestionDto } from './dto/update-chat-question.dto';
import { CreateChatKeywordDto } from './dto/create-chat-keyword.dto';
import { UpdateChatKeywordDto } from './dto/update-chat-keyword.dto';
import { ListChatQuestionsDto, ListChatKeywordsDto } from './dto/list-chat.dto';

@Controller('admin/chat')
@UseGuards(JwtAuthGuard)
export class ChatAdminController {
  constructor(private readonly chatAdminService: ChatAdminService) {}

  // --- Questions ---

  @Get('questions')
  listQuestions(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: ListChatQuestionsDto,
  ) {
    return this.chatAdminService.listQuestions(user, query);
  }

  @Get('questions/:id')
  getQuestion(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
  ) {
    return this.chatAdminService.getQuestion(user, id);
  }

  @Post('questions')
  createQuestion(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateChatQuestionDto,
  ) {
    return this.chatAdminService.createQuestion(user, dto);
  }

  @Patch('questions/:id')
  updateQuestion(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: UpdateChatQuestionDto,
  ) {
    return this.chatAdminService.updateQuestion(user, id, dto);
  }

  @Delete('questions/:id')
  deactivateQuestion(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
  ) {
    return this.chatAdminService.deactivateQuestion(user, id);
  }

  // --- Keywords ---

  @Get('keywords')
  listKeywords(
    @CurrentUser() user: AuthenticatedUser,
    @Query() query: ListChatKeywordsDto,
  ) {
    return this.chatAdminService.listKeywords(user, query);
  }

  @Post('keywords')
  createKeyword(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateChatKeywordDto,
  ) {
    return this.chatAdminService.createKeyword(user, dto);
  }

  @Patch('keywords/:id')
  updateKeyword(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: UpdateChatKeywordDto,
  ) {
    return this.chatAdminService.updateKeyword(user, id, dto);
  }

  @Delete('keywords/:id')
  deactivateKeyword(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
  ) {
    return this.chatAdminService.deactivateKeyword(user, id);
  }
}
