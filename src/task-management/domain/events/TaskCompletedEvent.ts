import { BaseDomainEvent } from '../../../shared/domain/DomainEvent.js';
import type { TaskId } from '../TaskId.js';

/**
 * Domain Event raised when a Task is completed.
 */
export class TaskCompletedEvent extends BaseDomainEvent {
  readonly eventType = 'TaskCompleted';

  constructor(
    readonly taskId: TaskId,
    readonly completedBy: string
  ) {
    super();
  }
}
