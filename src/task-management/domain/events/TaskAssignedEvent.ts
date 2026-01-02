import { BaseDomainEvent } from '../../../shared/domain/DomainEvent.js';
import type { TaskId } from '../TaskId.js';
import type { Assignee } from '../Assignee.js';

/**
 * Domain Event raised when a Task is assigned to someone.
 */
export class TaskAssignedEvent extends BaseDomainEvent {
  readonly eventType = 'TaskAssigned';

  constructor(
    readonly taskId: TaskId,
    readonly assignee: Assignee,
    readonly assignedBy: string
  ) {
    super();
  }
}
