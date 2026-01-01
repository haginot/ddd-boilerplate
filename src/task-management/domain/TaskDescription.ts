import { ValueObject } from '../../shared/domain/ValueObject.js';

interface TaskDescriptionProps {
  value: string;
}

/**
 * Value Object representing a Task description.
 * Can be empty but has a maximum length limit.
 */
export class TaskDescription extends ValueObject<TaskDescriptionProps> {
  private static readonly MAX_LENGTH = 10000;

  private constructor(props: TaskDescriptionProps) {
    super(props);
  }

  static create(description: string): TaskDescription {
    const trimmed = description.trim();

    if (trimmed.length > TaskDescription.MAX_LENGTH) {
      throw new Error(`Task description cannot exceed ${TaskDescription.MAX_LENGTH} characters`);
    }

    return new TaskDescription({ value: trimmed });
  }

  static empty(): TaskDescription {
    return new TaskDescription({ value: '' });
  }

  get value(): string {
    return this.props.value;
  }

  get isEmpty(): boolean {
    return this.props.value.length === 0;
  }

  toString(): string {
    return this.props.value;
  }
}
