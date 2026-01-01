import type { PriorityLevel } from '../../domain/Priority.js';
import type { TaskStatusValue } from '../../domain/TaskStatus.js';

/**
 * Command to update an existing task.
 */
export class UpdateTaskCommand {
  constructor(
    readonly taskId: string,
    readonly title: string | null,
    readonly description: string | null,
    readonly status: TaskStatusValue | null,
    readonly priority: PriorityLevel | null,
    readonly dueDate: Date | null | undefined,
    readonly updatedBy: string
  ) {
    this.validate();
  }

  private validate(): void {
    if (!this.taskId || this.taskId.trim().length === 0) {
      throw new Error('Task ID is required');
    }
    if (!this.updatedBy || this.updatedBy.trim().length === 0) {
      throw new Error('UpdatedBy is required');
    }
  }
}
