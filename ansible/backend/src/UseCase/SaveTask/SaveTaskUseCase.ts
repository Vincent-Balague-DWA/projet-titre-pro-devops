import { Injectable, BadRequestException } from '@nestjs/common';
import { Task } from '@prisma/client';
import { UseCase } from '../../index';
import SaveTaskDto from './SaveTaskDto';
import TaskRepository from 'src/Repositories/TaskRepository';
import { validate } from 'class-validator';
import { plainToInstance } from 'class-transformer';

@Injectable()
export default class SaveTaskUseCase implements UseCase<Promise<Task>, [dto: SaveTaskDto]> {
  constructor(private readonly taskRepository: TaskRepository) {}

  async validateDto(dto: SaveTaskDto): Promise<string[]> {
    const instance = plainToInstance(SaveTaskDto, dto);
    const errors = await validate(instance);
    return errors.map(error => Object.values(error.constraints).join(', '));
  }

  async handle(dto: SaveTaskDto) {
    /*
    * @todo IMPLEMENT HERE : VALIDATION DTO, DATA SAVING, ERROR CATCHING
     */

    // Validation du DTO
    const validationErrors = await this.validateDto(dto);
    if (validationErrors.length > 0) {
      throw new BadRequestException(validationErrors);
    }

    const { id, ...data } = dto;

    if(!id) {
      try {
        return await this.taskRepository.save(data)     
      } catch (error) {
        throw new BadRequestException(error.message);
      }
    }
    try {
      return this.taskRepository.save({
        ...data,
        id,
      });
    } catch (error) {
      
    }

    return null;
  }
}
