import { BaseDomainEvent } from '../../../shared/domain/DomainEvent.js';
import type { TaskId } from '../TaskId.js';
import type { TaskStatus } from '../TaskStatus.js';

/**
 * Domain Event raised when a Task's status changes.
 */
export class TaskStatusChangedEvent extends BaseDomainEvent {
  readonly eventType = 'TaskStatusChanged';

  constructor(
    readonly taskId: TaskId,
    readonly previousStatus: TaskStatus,
    readonly newStatus: TaskStatus,
    readonly changedBy: string
  ) {
    super();
  }
}
