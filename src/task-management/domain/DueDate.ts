import { ValueObject } from '../../shared/domain/ValueObject.js';

interface DueDateProps {
  value: Date | null;
}

/**
 * Value Object representing a Task's due date.
 * Can be null if no due date is set.
 */
export class DueDate extends ValueObject<DueDateProps> {
  private constructor(props: DueDateProps) {
    super(props);
  }

  static create(date: Date): DueDate {
    return new DueDate({ value: new Date(date) });
  }

  static none(): DueDate {
    return new DueDate({ value: null });
  }

  static fromString(dateString: string): DueDate {
    if (!dateString) {
      return DueDate.none();
    }
    const date = new Date(dateString);
    if (isNaN(date.getTime())) {
      throw new Error(`Invalid date format: ${dateString}`);
    }
    return new DueDate({ value: date });
  }

  get value(): Date | null {
    return this.props.value ? new Date(this.props.value) : null;
  }

  get hasValue(): boolean {
    return this.props.value !== null;
  }

  get isOverdue(): boolean {
    if (!this.props.value) {
      return false;
    }
    const now = new Date();
    now.setHours(0, 0, 0, 0);
    const dueDate = new Date(this.props.value);
    dueDate.setHours(0, 0, 0, 0);
    return dueDate < now;
  }

  get isDueToday(): boolean {
    if (!this.props.value) {
      return false;
    }
    const now = new Date();
    const dueDate = new Date(this.props.value);
    return (
      dueDate.getFullYear() === now.getFullYear() &&
      dueDate.getMonth() === now.getMonth() &&
      dueDate.getDate() === now.getDate()
    );
  }

  get isDueSoon(): boolean {
    if (!this.props.value) {
      return false;
    }
    const now = new Date();
    const threeDaysFromNow = new Date(now);
    threeDaysFromNow.setDate(threeDaysFromNow.getDate() + 3);

    const dueDate = new Date(this.props.value);
    return dueDate >= now && dueDate <= threeDaysFromNow;
  }

  toString(): string {
    return this.props.value ? this.props.value.toISOString() : '';
  }
}
