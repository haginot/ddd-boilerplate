import type { TaskRepository } from '../../domain/TaskRepository.js';
import type { EventPublisher } from '../../../shared/domain/DomainEvent.js';
import { Task } from '../../domain/Task.js';
import { ProjectId } from '../../domain/ProjectId.js';
import type { CreateTaskCommand } from '../commands/CreateTaskCommand.js';

export interface CreateTaskResponse {
  taskId: string;
}

/**
 * Use Case: Create a new task.
 */
export class CreateTaskHandler {
  constructor(
    private readonly taskRepository: TaskRepository,
    private readonly eventPublisher: EventPublisher
  ) {}

  async execute(command: CreateTaskCommand): Promise<CreateTaskResponse> {
    // Create domain object
    const task = Task.create({
      title: command.title,
      description: command.description,
      projectId: command.projectId ? ProjectId.create(command.projectId) : undefined,
      priority: command.priority,
      dueDate: command.dueDate ?? undefined,
      assignee: command.assignee ?? undefined,
      createdBy: command.createdBy
    });

    // Persist through repository
    await this.taskRepository.save(task);

    // Publish domain events
    await this.eventPublisher.publishAll([...task.domainEvents]);
    task.clearDomainEvents();

    return { taskId: task.id.value };
  }
}
