import { ValueObject } from '../../shared/domain/ValueObject.js';

interface TaskTitleProps {
  value: string;
}

/**
 * Value Object representing a Task title.
 * Validates that the title is not empty and within length limits.
 */
export class TaskTitle extends ValueObject<TaskTitleProps> {
  private static readonly MIN_LENGTH = 1;
  private static readonly MAX_LENGTH = 255;

  private constructor(props: TaskTitleProps) {
    super(props);
  }

  static create(title: string): TaskTitle {
    const trimmed = title.trim();

    if (trimmed.length < TaskTitle.MIN_LENGTH) {
      throw new Error('Task title cannot be empty');
    }

    if (trimmed.length > TaskTitle.MAX_LENGTH) {
      throw new Error(`Task title cannot exceed ${TaskTitle.MAX_LENGTH} characters`);
    }

    return new TaskTitle({ value: trimmed });
  }

  get value(): string {
    return this.props.value;
  }

  toString(): string {
    return this.props.value;
  }
}
