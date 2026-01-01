import { ValueObject } from '../../shared/domain/ValueObject.js';

export enum TaskStatusValue {
  TODO = 'TODO',
  IN_PROGRESS = 'IN_PROGRESS',
  IN_REVIEW = 'IN_REVIEW',
  DONE = 'DONE',
  CANCELLED = 'CANCELLED'
}

interface TaskStatusProps {
  value: TaskStatusValue;
}

/**
 * Value Object representing the status of a Task.
 * Follows Asana-like workflow: TODO -> IN_PROGRESS -> IN_REVIEW -> DONE
 */
export class TaskStatus extends ValueObject<TaskStatusProps> {
  private constructor(props: TaskStatusProps) {
    super(props);
  }

  static create(status: TaskStatusValue): TaskStatus {
    return new TaskStatus({ value: status });
  }

  static todo(): TaskStatus {
    return new TaskStatus({ value: TaskStatusValue.TODO });
  }

  static inProgress(): TaskStatus {
    return new TaskStatus({ value: TaskStatusValue.IN_PROGRESS });
  }

  static inReview(): TaskStatus {
    return new TaskStatus({ value: TaskStatusValue.IN_REVIEW });
  }

  static done(): TaskStatus {
    return new TaskStatus({ value: TaskStatusValue.DONE });
  }

  static cancelled(): TaskStatus {
    return new TaskStatus({ value: TaskStatusValue.CANCELLED });
  }

  static fromString(status: string): TaskStatus {
    const upperStatus = status.toUpperCase();
    if (!Object.values(TaskStatusValue).includes(upperStatus as TaskStatusValue)) {
      throw new Error(`Invalid task status: ${status}`);
    }
    return new TaskStatus({ value: upperStatus as TaskStatusValue });
  }

  get value(): TaskStatusValue {
    return this.props.value;
  }

  get isTodo(): boolean {
    return this.props.value === TaskStatusValue.TODO;
  }

  get isInProgress(): boolean {
    return this.props.value === TaskStatusValue.IN_PROGRESS;
  }

  get isInReview(): boolean {
    return this.props.value === TaskStatusValue.IN_REVIEW;
  }

  get isDone(): boolean {
    return this.props.value === TaskStatusValue.DONE;
  }

  get isCancelled(): boolean {
    return this.props.value === TaskStatusValue.CANCELLED;
  }

  get isComplete(): boolean {
    return this.isDone || this.isCancelled;
  }

  toString(): string {
    return this.props.value;
  }
}
