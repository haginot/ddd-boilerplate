import type { PriorityLevel } from '../../domain/Priority.js';

/**
 * Command to create a new task.
 */
export class CreateTaskCommand {
  constructor(
    readonly title: string,
    readonly description: string,
    readonly projectId: string | null,
    readonly priority: PriorityLevel,
    readonly dueDate: Date | null,
    readonly assignee: { userId: string; name: string; email: string } | null,
    readonly createdBy: string
  ) {
    this.validate();
  }

  private validate(): void {
    if (!this.title || this.title.trim().length === 0) {
      throw new Error('Task title is required');
    }
    if (!this.createdBy || this.createdBy.trim().length === 0) {
      throw new Error('CreatedBy is required');
    }
  }
}
