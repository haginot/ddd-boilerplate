import type { TaskRepository } from '../../domain/TaskRepository.js';
import type { EventPublisher } from '../../../shared/domain/DomainEvent.js';
import { TaskId } from '../../domain/TaskId.js';
import type { AssignTaskCommand } from '../commands/AssignTaskCommand.js';

/**
 * Use Case: Assign a task to a user.
 */
export class AssignTaskHandler {
  constructor(
    private readonly taskRepository: TaskRepository,
    private readonly eventPublisher: EventPublisher
  ) {}

  async execute(command: AssignTaskCommand): Promise<void> {
    const taskId = TaskId.create(command.taskId);
    const task = await this.taskRepository.findById(taskId);

    if (!task) {
      throw new Error(`Task not found: ${command.taskId}`);
    }

    // Assign the task
    task.assign(
      command.assigneeUserId,
      command.assigneeName,
      command.assigneeEmail,
      command.assignedBy
    );

    // Persist changes
    await this.taskRepository.save(task);

    // Publish domain events
    await this.eventPublisher.publishAll([...task.domainEvents]);
    task.clearDomainEvents();
  }
}
