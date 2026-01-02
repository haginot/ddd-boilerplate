import { TaskId } from '../../../../src/task-management/domain/TaskId';
import { TaskTitle } from '../../../../src/task-management/domain/TaskTitle';
import { TaskDescription } from '../../../../src/task-management/domain/TaskDescription';
import { TaskStatus, TaskStatusValue } from '../../../../src/task-management/domain/TaskStatus';
import { Priority, PriorityLevel } from '../../../../src/task-management/domain/Priority';
import { DueDate } from '../../../../src/task-management/domain/DueDate';
import { Assignee } from '../../../../src/task-management/domain/Assignee';
import { ProjectId } from '../../../../src/task-management/domain/ProjectId';

describe('TaskId', () => {
  it('should create a valid TaskId', () => {
    const taskId = TaskId.create('task-123');
    expect(taskId.value).toBe('task-123');
  });

  it('should generate a unique TaskId', () => {
    const id1 = TaskId.generate();
    const id2 = TaskId.generate();
    expect(id1.value).not.toBe(id2.value);
  });

  it('should reject empty TaskId', () => {
    expect(() => TaskId.create('')).toThrow('TaskId cannot be empty');
  });
});

describe('TaskTitle', () => {
  it('should create a valid TaskTitle', () => {
    const title = TaskTitle.create('My Task');
    expect(title.value).toBe('My Task');
  });

  it('should trim whitespace', () => {
    const title = TaskTitle.create('  My Task  ');
    expect(title.value).toBe('My Task');
  });

  it('should reject empty title', () => {
    expect(() => TaskTitle.create('')).toThrow('Task title cannot be empty');
  });

  it('should reject title exceeding max length', () => {
    const longTitle = 'a'.repeat(256);
    expect(() => TaskTitle.create(longTitle)).toThrow('cannot exceed 255 characters');
  });
});

describe('TaskDescription', () => {
  it('should create a valid description', () => {
    const desc = TaskDescription.create('This is a description');
    expect(desc.value).toBe('This is a description');
  });

  it('should create empty description', () => {
    const desc = TaskDescription.empty();
    expect(desc.isEmpty).toBe(true);
  });

  it('should reject description exceeding max length', () => {
    const longDesc = 'a'.repeat(10001);
    expect(() => TaskDescription.create(longDesc)).toThrow('cannot exceed 10000 characters');
  });
});

describe('TaskStatus', () => {
  it('should create TODO status', () => {
    const status = TaskStatus.todo();
    expect(status.isTodo).toBe(true);
    expect(status.value).toBe(TaskStatusValue.TODO);
  });

  it('should create from string', () => {
    const status = TaskStatus.fromString('in_progress');
    expect(status.isInProgress).toBe(true);
  });

  it('should identify complete statuses', () => {
    expect(TaskStatus.done().isComplete).toBe(true);
    expect(TaskStatus.cancelled().isComplete).toBe(true);
    expect(TaskStatus.todo().isComplete).toBe(false);
  });

  it('should reject invalid status', () => {
    expect(() => TaskStatus.fromString('invalid')).toThrow('Invalid task status');
  });
});

describe('Priority', () => {
  it('should create priorities', () => {
    expect(Priority.low().isLow).toBe(true);
    expect(Priority.medium().isMedium).toBe(true);
    expect(Priority.high().isHigh).toBe(true);
    expect(Priority.urgent().isUrgent).toBe(true);
  });

  it('should have correct numeric values', () => {
    expect(Priority.low().numericValue).toBe(1);
    expect(Priority.medium().numericValue).toBe(2);
    expect(Priority.high().numericValue).toBe(3);
    expect(Priority.urgent().numericValue).toBe(4);
  });

  it('should create from string', () => {
    const priority = Priority.fromString('high');
    expect(priority.isHigh).toBe(true);
  });

  it('should reject invalid priority', () => {
    expect(() => Priority.fromString('invalid')).toThrow('Invalid priority');
  });
});

describe('DueDate', () => {
  it('should create a due date', () => {
    const date = new Date('2026-12-31');
    const dueDate = DueDate.create(date);
    expect(dueDate.hasValue).toBe(true);
  });

  it('should create no due date', () => {
    const dueDate = DueDate.none();
    expect(dueDate.hasValue).toBe(false);
  });

  it('should detect overdue', () => {
    const pastDate = new Date('2020-01-01');
    const dueDate = DueDate.create(pastDate);
    expect(dueDate.isOverdue).toBe(true);
  });

  it('should detect due today', () => {
    const today = new Date();
    const dueDate = DueDate.create(today);
    expect(dueDate.isDueToday).toBe(true);
  });

  it('should parse from string', () => {
    const dueDate = DueDate.fromString('2026-12-31');
    expect(dueDate.hasValue).toBe(true);
  });
});

describe('Assignee', () => {
  it('should create an assignee', () => {
    const assignee = Assignee.create('user-1', 'John Doe', 'john@example.com');
    expect(assignee.isAssigned).toBe(true);
    expect(assignee.userId).toBe('user-1');
    expect(assignee.name).toBe('John Doe');
    expect(assignee.email).toBe('john@example.com');
  });

  it('should create unassigned', () => {
    const assignee = Assignee.unassigned();
    expect(assignee.isAssigned).toBe(false);
    expect(assignee.userId).toBeNull();
  });

  it('should reject invalid email', () => {
    expect(() => Assignee.create('user-1', 'John', 'invalid-email'))
      .toThrow('Invalid assignee email');
  });

  it('should normalize email to lowercase', () => {
    const assignee = Assignee.create('user-1', 'John', 'JOHN@EXAMPLE.COM');
    expect(assignee.email).toBe('john@example.com');
  });
});

describe('ProjectId', () => {
  it('should create a valid ProjectId', () => {
    const projectId = ProjectId.create('project-123');
    expect(projectId.value).toBe('project-123');
  });

  it('should generate a unique ProjectId', () => {
    const id1 = ProjectId.generate();
    const id2 = ProjectId.generate();
    expect(id1.value).not.toBe(id2.value);
  });

  it('should reject empty ProjectId', () => {
    expect(() => ProjectId.create('')).toThrow('ProjectId cannot be empty');
  });
});
