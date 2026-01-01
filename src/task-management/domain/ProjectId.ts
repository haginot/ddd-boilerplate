import { ValueObject } from '../../shared/domain/ValueObject.js';
import { v4 as uuidv4 } from 'uuid';

interface ProjectIdProps {
  value: string;
}

/**
 * Value Object representing a unique Project identifier.
 */
export class ProjectId extends ValueObject<ProjectIdProps> {
  private constructor(props: ProjectIdProps) {
    super(props);
  }

  static create(id: string): ProjectId {
    if (!id || id.trim().length === 0) {
      throw new Error('ProjectId cannot be empty');
    }
    return new ProjectId({ value: id.trim() });
  }

  static generate(): ProjectId {
    return new ProjectId({ value: uuidv4() });
  }

  get value(): string {
    return this.props.value;
  }

  toString(): string {
    return this.props.value;
  }
}
