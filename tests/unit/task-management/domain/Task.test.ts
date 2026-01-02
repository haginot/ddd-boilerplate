import { Task } from '../../../../src/task-management/domain/Task';
import { TaskStatusValue } from '../../../../src/task-management/domain/TaskStatus';
import { PriorityLevel } from '../../../../src/task-management/domain/Priority';
import { ProjectId } from '../../../../src/task-management/domain/ProjectId';

describe('Task Aggregate', () => {
  describe('create', () => {
    it('should create a task with required fields', () => {
      const task = Task.create({
        title: 'Test Task',
        createdBy: 'user-1'
      });

      expect(task.id).toBeDefined();
      expect(task.title.value).toBe('Test Task');
      expect(task.description.isEmpty).toBe(true);
      expect(task.status.isTodo).toBe(true);
      expect(task.priority.isMedium).toBe(true);
      expect(task.assignee.isAssigned).toBe(false);
      expect(task.projectId).toBeNull();
    });

    it('should create a task with all fields', () => {
      const dueDate = new Date('2026-12-31');
      const projectId = ProjectId.generate();

      const task = Task.create({
        title: 'Complete Task',
        description: 'This is a complete task',
        projectId,
        priority: PriorityLevel.HIGH,
        dueDate,
        assignee: {
          userId: 'user-1',
          name: 'John Doe',
          email: 'john@example.com'
        },
        createdBy: 'user-2'
      });

      expect(task.title.value).toBe('Complete Task');
      expect(task.description.value).toBe('This is a complete task');
      expect(task.priority.isHigh).toBe(true);
      expect(task.dueDate.hasValue).toBe(true);
      expect(task.assignee.isAssigned).toBe(true);
      expect(task.assignee.name).toBe('John Doe');
      expect(task.projectId?.equals(projectId)).toBe(true);
    });

    it('should publish TaskCreatedEvent', () => {
      const task = Task.create({
        title: 'Test Task',
        createdBy: 'user-1'
      });

      expect(task.domainEvents).toHaveLength(1);
      expect(task.domainEvents[0].eventType).toBe('TaskCreated');
    });

    it('should reject empty title', () => {
      expect(() => Task.create({
        title: '',
        createdBy: 'user-1'
      })).toThrow('Task title cannot be empty');
    });
  });

  describe('status transitions', () => {
    it('should start a TODO task', () => {
      const task = Task.create({
        title: 'Test Task',
        createdBy: 'user-1'
      });
      task.clearDomainEvents();

      task.start('user-1');

      expect(task.status.isInProgress).toBe(true);
      expect(task.domainEvents).toHaveLength(1);
      expect(task.domainEvents[0].eventType).toBe('TaskStatusChanged');
    });

    it('should submit for review an IN_PROGRESS task', () => {
      const task = Task.create({
        title: 'Test Task',
        createdBy: 'user-1'
      });
      task.start('user-1');
      task.clearDomainEvents();

      task.submitForReview('user-1');

      expect(task.status.isInReview).toBe(true);
    });

    it('should complete a task', () => {
      const task = Task.create({
        title: 'Test Task',
        createdBy: 'user-1'
      });
      task.start('user-1');
      task.clearDomainEvents();

      task.complete('user-1');

      expect(task.status.isDone).toBe(true);
      expect(task.completedAt).not.toBeNull();
      expect(task.domainEvents.some(e => e.eventType === 'TaskCompleted')).toBe(true);
    });

    it('should not allow starting a completed task', () => {
      const task = Task.create({
        title: 'Test Task',
        createdBy: 'user-1'
      });
      task.complete('user-1');

      expect(() => task.start('user-1')).toThrow('Cannot modify a completed task');
    });

    it('should reopen a completed task', () => {
      const task = Task.create({
        title: 'Test Task',
        createdBy: 'user-1'
      });
      task.complete('user-1');
      task.clearDomainEvents();

      task.reopen('user-1');

      expect(task.status.isTodo).toBe(true);
      expect(task.completedAt).toBeNull();
    });
  });

  describe('assignment', () => {
    it('should assign a task to a user', () => {
      const task = Task.create({
        title: 'Test Task',
        createdBy: 'user-1'
      });
      task.clearDomainEvents();

      task.assign('user-2', 'Jane Doe', 'jane@example.com', 'user-1');

      expect(task.assignee.isAssigned).toBe(true);
      expect(task.assignee.userId).toBe('user-2');
      expect(task.assignee.name).toBe('Jane Doe');
      expect(task.domainEvents.some(e => e.eventType === 'TaskAssigned')).toBe(true);
    });

    it('should unassign a task', () => {
      const task = Task.create({
        title: 'Test Task',
        assignee: {
          userId: 'user-1',
          name: 'John Doe',
          email: 'john@example.com'
        },
        createdBy: 'user-1'
      });

      task.unassign();

      expect(task.assignee.isAssigned).toBe(false);
    });
  });

  describe('priority', () => {
    it('should update priority', () => {
      const task = Task.create({
        title: 'Test Task',
        createdBy: 'user-1'
      });

      task.updatePriority(PriorityLevel.URGENT);

      expect(task.priority.isUrgent).toBe(true);
    });
  });

  describe('due date', () => {
    it('should set due date', () => {
      const task = Task.create({
        title: 'Test Task',
        createdBy: 'user-1'
      });
      const dueDate = new Date('2026-12-31');

      task.setDueDate(dueDate);

      expect(task.dueDate.hasValue).toBe(true);
    });

    it('should remove due date', () => {
      const task = Task.create({
        title: 'Test Task',
        dueDate: new Date('2026-12-31'),
        createdBy: 'user-1'
      });

      task.removeDueDate();

      expect(task.dueDate.hasValue).toBe(false);
    });

    it('should detect overdue tasks', () => {
      const task = Task.create({
        title: 'Test Task',
        dueDate: new Date('2020-01-01'), // Past date
        createdBy: 'user-1'
      });

      expect(task.isOverdue).toBe(true);
    });
  });

  describe('tags', () => {
    it('should add tags', () => {
      const task = Task.create({
        title: 'Test Task',
        createdBy: 'user-1'
      });

      task.addTag('feature');
      task.addTag('urgent');

      expect(task.tags).toContain('feature');
      expect(task.tags).toContain('urgent');
    });

    it('should normalize tags to lowercase', () => {
      const task = Task.create({
        title: 'Test Task',
        createdBy: 'user-1'
      });

      task.addTag('FEATURE');

      expect(task.tags).toContain('feature');
    });

    it('should not add duplicate tags', () => {
      const task = Task.create({
        title: 'Test Task',
        createdBy: 'user-1'
      });

      task.addTag('feature');
      task.addTag('feature');

      expect(task.tags.filter(t => t === 'feature')).toHaveLength(1);
    });

    it('should remove tags', () => {
      const task = Task.create({
        title: 'Test Task',
        createdBy: 'user-1'
      });
      task.addTag('feature');

      task.removeTag('feature');

      expect(task.tags).not.toContain('feature');
    });
  });

  describe('title and description updates', () => {
    it('should update title', () => {
      const task = Task.create({
        title: 'Original Title',
        createdBy: 'user-1'
      });

      task.updateTitle('Updated Title');

      expect(task.title.value).toBe('Updated Title');
    });

    it('should update description', () => {
      const task = Task.create({
        title: 'Test Task',
        createdBy: 'user-1'
      });

      task.updateDescription('New description');

      expect(task.description.value).toBe('New description');
    });
  });
});
