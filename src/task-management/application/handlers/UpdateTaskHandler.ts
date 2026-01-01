import type { TaskRepository } from '../../domain/TaskRepository.js';
import type { EventPublisher } from '../../../shared/domain/DomainEvent.js';
import { TaskId } from '../../domain/TaskId.js';
import type { UpdateTaskCommand } from '../commands/UpdateTaskCommand.js';

/**
 * Use Case: Update an existing task.
 */
export class UpdateTaskHandler {
  constructor(
    private readonly taskRepository: TaskRepository,
    private readonly eventPublisher: EventPublisher
  ) {}

  async execute(command: UpdateTaskCommand): Promise<void> {
    const taskId = TaskId.create(command.taskId);
    const task = await this.taskRepository.findById(taskId);

    if (!task) {
      throw new Error(`Task not found: ${command.taskId}`);
    }

    // Update fields if provided
    if (command.title !== null) {
      task.updateTitle(command.title);
    }

    if (command.description !== null) {
      task.updateDescription(command.description);
    }

    if (command.status !== null) {
      task.changeStatus(command.status, command.updatedBy);
    }

    if (command.priority !== null) {
      task.updatePriority(command.priority);
    }

    if (command.dueDate !== undefined) {
      if (command.dueDate === null) {
        task.removeDueDate();
      } else {
        task.setDueDate(command.dueDate);
      }
    }

    // Persist changes
    await this.taskRepository.save(task);

    // Publish domain events
    await this.eventPublisher.publishAll([...task.domainEvents]);
    task.clearDomainEvents();
  }
}
