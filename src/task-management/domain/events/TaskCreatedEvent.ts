import { BaseDomainEvent } from '../../../shared/domain/DomainEvent.js';
import type { TaskId } from '../TaskId.js';
import type { ProjectId } from '../ProjectId.js';

/**
 * Domain Event raised when a new Task is created.
 */
export class TaskCreatedEvent extends BaseDomainEvent {
  readonly eventType = 'TaskCreated';

  constructor(
    readonly taskId: TaskId,
    readonly title: string,
    readonly projectId: ProjectId | null,
    readonly createdBy: string
  ) {
    super();
  }
}
