import { IsOptional, IsInt, IsString, IsNotEmpty } from 'class-validator';

export default class SaveTaskDto {
  @IsOptional() 
  @IsInt({ message: 'id must be an integer' }) 
  id: null | number;

  @IsOptional() 
  @IsString({ message: 'name must be a string' }) 
  @IsNotEmpty({ message: 'name should not be empty' }) 
  name?: string;
}

