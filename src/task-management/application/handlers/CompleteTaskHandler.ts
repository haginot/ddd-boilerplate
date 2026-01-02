import type { TaskRepository } from '../../domain/TaskRepository.js';
import type { EventPublisher } from '../../../shared/domain/DomainEvent.js';
import { TaskId } from '../../domain/TaskId.js';
import type { CompleteTaskCommand } from '../commands/CompleteTaskCommand.js';

/**
 * Use Case: Complete a task.
 */
export class CompleteTaskHandler {
  constructor(
    private readonly taskRepository: TaskRepository,
    private readonly eventPublisher: EventPublisher
  ) {}

  async execute(command: CompleteTaskCommand): Promise<void> {
    const taskId = TaskId.create(command.taskId);
    const task = await this.taskRepository.findById(taskId);

    if (!task) {
      throw new Error(`Task not found: ${command.taskId}`);
    }

    // Complete the task
    task.complete(command.completedBy);

    // Persist changes
    await this.taskRepository.save(task);

    // Publish domain events
    await this.eventPublisher.publishAll([...task.domainEvents]);
    task.clearDomainEvents();
  }
}
