import { CreateTaskHandler } from '../../../../src/task-management/application/handlers/CreateTaskHandler';
import { CreateTaskCommand } from '../../../../src/task-management/application/commands/CreateTaskCommand';
import { InMemoryTaskRepository } from '../../../../src/task-management/infrastructure/InMemoryTaskRepository';
import { PriorityLevel } from '../../../../src/task-management/domain/Priority';
import type { EventPublisher, DomainEvent } from '../../../../src/shared/domain/DomainEvent';

// Mock Event Publisher
class MockEventPublisher implements EventPublisher {
  public publishedEvents: DomainEvent[] = [];

  async publish(event: DomainEvent): Promise<void> {
    this.publishedEvents.push(event);
  }

  async publishAll(events: DomainEvent[]): Promise<void> {
    this.publishedEvents.push(...events);
  }
}

describe('CreateTaskHandler', () => {
  let handler: CreateTaskHandler;
  let taskRepository: InMemoryTaskRepository;
  let eventPublisher: MockEventPublisher;

  beforeEach(() => {
    taskRepository = new InMemoryTaskRepository();
    eventPublisher = new MockEventPublisher();
    handler = new CreateTaskHandler(taskRepository, eventPublisher);
  });

  it('should create a task with minimal data', async () => {
    const command = new CreateTaskCommand(
      'Test Task',
      '',
      null,
      PriorityLevel.MEDIUM,
      null,
      null,
      'user-1'
    );

    const result = await handler.execute(command);

    expect(result.taskId).toBeDefined();
    expect(taskRepository.count()).toBe(1);

    const task = (await taskRepository.getAll())[0];
    expect(task.title.value).toBe('Test Task');
    expect(task.status.isTodo).toBe(true);
  });

  it('should create a task with all data', async () => {
    const dueDate = new Date('2026-12-31');
    const command = new CreateTaskCommand(
      'Complete Task',
      'This is a description',
      'project-123',
      PriorityLevel.HIGH,
      dueDate,
      { userId: 'user-2', name: 'John Doe', email: 'john@example.com' },
      'user-1'
    );

    const result = await handler.execute(command);

    const task = (await taskRepository.getAll())[0];
    expect(task.title.value).toBe('Complete Task');
    expect(task.description.value).toBe('This is a description');
    expect(task.priority.isHigh).toBe(true);
    expect(task.assignee.isAssigned).toBe(true);
    expect(task.projectId?.value).toBe('project-123');
  });

  it('should publish TaskCreatedEvent', async () => {
    const command = new CreateTaskCommand(
      'Test Task',
      '',
      null,
      PriorityLevel.MEDIUM,
      null,
      null,
      'user-1'
    );

    await handler.execute(command);

    expect(eventPublisher.publishedEvents).toHaveLength(1);
    expect(eventPublisher.publishedEvents[0].eventType).toBe('TaskCreated');
  });

  it('should reject invalid command', () => {
    expect(() => new CreateTaskCommand(
      '',
      '',
      null,
      PriorityLevel.MEDIUM,
      null,
      null,
      'user-1'
    )).toThrow('Task title is required');
  });
});
