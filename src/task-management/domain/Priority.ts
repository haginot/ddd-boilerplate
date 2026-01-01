import { ValueObject } from '../../shared/domain/ValueObject.js';

export enum PriorityLevel {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH',
  URGENT = 'URGENT'
}

interface PriorityProps {
  value: PriorityLevel;
}

/**
 * Value Object representing the priority of a Task.
 */
export class Priority extends ValueObject<PriorityProps> {
  private constructor(props: PriorityProps) {
    super(props);
  }

  static create(priority: PriorityLevel): Priority {
    return new Priority({ value: priority });
  }

  static low(): Priority {
    return new Priority({ value: PriorityLevel.LOW });
  }

  static medium(): Priority {
    return new Priority({ value: PriorityLevel.MEDIUM });
  }

  static high(): Priority {
    return new Priority({ value: PriorityLevel.HIGH });
  }

  static urgent(): Priority {
    return new Priority({ value: PriorityLevel.URGENT });
  }

  static fromString(priority: string): Priority {
    const upperPriority = priority.toUpperCase();
    if (!Object.values(PriorityLevel).includes(upperPriority as PriorityLevel)) {
      throw new Error(`Invalid priority: ${priority}`);
    }
    return new Priority({ value: upperPriority as PriorityLevel });
  }

  get value(): PriorityLevel {
    return this.props.value;
  }

  get isLow(): boolean {
    return this.props.value === PriorityLevel.LOW;
  }

  get isMedium(): boolean {
    return this.props.value === PriorityLevel.MEDIUM;
  }

  get isHigh(): boolean {
    return this.props.value === PriorityLevel.HIGH;
  }

  get isUrgent(): boolean {
    return this.props.value === PriorityLevel.URGENT;
  }

  /**
   * Returns numeric priority for sorting (higher = more urgent)
   */
  get numericValue(): number {
    switch (this.props.value) {
      case PriorityLevel.LOW: return 1;
      case PriorityLevel.MEDIUM: return 2;
      case PriorityLevel.HIGH: return 3;
      case PriorityLevel.URGENT: return 4;
    }
  }

  toString(): string {
    return this.props.value;
  }
}
