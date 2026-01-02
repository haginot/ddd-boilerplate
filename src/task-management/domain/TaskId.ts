import { ValueObject } from '../../shared/domain/ValueObject.js';
import { v4 as uuidv4 } from 'uuid';

interface TaskIdProps {
  value: string;
}

/**
 * Value Object representing a unique Task identifier.
 */
export class TaskId extends ValueObject<TaskIdProps> {
  private constructor(props: TaskIdProps) {
    super(props);
  }

  static create(id: string): TaskId {
    if (!id || id.trim().length === 0) {
      throw new Error('TaskId cannot be empty');
    }
    return new TaskId({ value: id.trim() });
  }

  static generate(): TaskId {
    return new TaskId({ value: uuidv4() });
  }

  get value(): string {
    return this.props.value;
  }

  toString(): string {
    return this.props.value;
  }
}
