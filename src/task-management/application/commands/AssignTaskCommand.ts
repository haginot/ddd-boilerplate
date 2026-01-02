/**
 * Command to assign a task to a user.
 */
export class AssignTaskCommand {
  constructor(
    readonly taskId: string,
    readonly assigneeUserId: string,
    readonly assigneeName: string,
    readonly assigneeEmail: string,
    readonly assignedBy: string
  ) {
    this.validate();
  }

  private validate(): void {
    if (!this.taskId || this.taskId.trim().length === 0) {
      throw new Error('Task ID is required');
    }
    if (!this.assigneeUserId || this.assigneeUserId.trim().length === 0) {
      throw new Error('Assignee user ID is required');
    }
    if (!this.assigneeName || this.assigneeName.trim().length === 0) {
      throw new Error('Assignee name is required');
    }
    if (!this.assigneeEmail || this.assigneeEmail.trim().length === 0) {
      throw new Error('Assignee email is required');
    }
    if (!this.assignedBy || this.assignedBy.trim().length === 0) {
      throw new Error('AssignedBy is required');
    }
  }
}
