/**
 * Command to complete a task.
 */
export class CompleteTaskCommand {
  constructor(
    readonly taskId: string,
    readonly completedBy: string
  ) {
    this.validate();
  }

  private validate(): void {
    if (!this.taskId || this.taskId.trim().length === 0) {
      throw new Error('Task ID is required');
    }
    if (!this.completedBy || this.completedBy.trim().length === 0) {
      throw new Error('CompletedBy is required');
    }
  }
}
