import { IsOptional, IsString } from 'class-validator';

export class CompleteUploadDto {
  @IsOptional()
  @IsString()
  checksum?: string;
}
