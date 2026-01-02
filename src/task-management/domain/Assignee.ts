import { ValueObject } from '../../shared/domain/ValueObject.js';

interface AssigneeProps {
  userId: string | null;
  name: string | null;
  email: string | null;
}

/**
 * Value Object representing a Task assignee.
 * Can be unassigned (null values).
 */
export class Assignee extends ValueObject<AssigneeProps> {
  private constructor(props: AssigneeProps) {
    super(props);
  }

  static create(userId: string, name: string, email: string): Assignee {
    if (!userId || userId.trim().length === 0) {
      throw new Error('Assignee userId cannot be empty');
    }
    if (!name || name.trim().length === 0) {
      throw new Error('Assignee name cannot be empty');
    }
    if (!email || !Assignee.isValidEmail(email)) {
      throw new Error('Invalid assignee email');
    }
    return new Assignee({
      userId: userId.trim(),
      name: name.trim(),
      email: email.trim().toLowerCase()
    });
  }

  static unassigned(): Assignee {
    return new Assignee({ userId: null, name: null, email: null });
  }

  private static isValidEmail(email: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }

  get userId(): string | null {
    return this.props.userId;
  }

  get name(): string | null {
    return this.props.name;
  }

  get email(): string | null {
    return this.props.email;
  }

  get isAssigned(): boolean {
    return this.props.userId !== null;
  }

  toString(): string {
    return this.props.name ?? 'Unassigned';
  }
}
