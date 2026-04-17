import { IsInt, IsString, Max, Min } from 'class-validator';

export class CreateTicketAttachmentDto {
  @IsString()
  fileName!: string;

  @IsString()
  mimeType!: string;

  @IsInt()
  @Min(1)
  @Max(10 * 1024 * 1024)
  fileSize!: number;
}
