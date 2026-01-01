import { AggregateRoot } from '../../shared/domain/AggregateRoot.js';
import { TaskId } from './TaskId.js';
import { TaskTitle } from './TaskTitle.js';
import { TaskDescription } from './TaskDescription.js';
import { TaskStatus, TaskStatusValue } from './TaskStatus.js';
import { Priority, PriorityLevel } from './Priority.js';
import { DueDate } from './DueDate.js';
import { Assignee } from './Assignee.js';
import { ProjectId } from './ProjectId.js';
import { TaskCreatedEvent } from './events/TaskCreatedEvent.js';
import { TaskCompletedEvent } from './events/TaskCompletedEvent.js';
import { TaskAssignedEvent } from './events/TaskAssignedEvent.js';
import { TaskStatusChangedEvent } from './events/TaskStatusChangedEvent.js';

export interface CreateTaskParams {
  title: string;
  description?: string;
  projectId?: ProjectId;
  priority?: PriorityLevel;
  dueDate?: Date;
  assignee?: { userId: string; name: string; email: string };
  createdBy: string;
}

/**
 * Task Aggregate Root - represents a task in the task management system.
 * Inspired by Asana's task model.
 */
export class Task extends AggregateRoot<TaskId> {
  private _title: TaskTitle;
  private _description: TaskDescription;
  private _status: TaskStatus;
  private _priority: Priority;
  private _dueDate: DueDate;
  private _assignee: Assignee;
  private _projectId: ProjectId | null;
  private _createdAt: Date;
  private _updatedAt: Date;
  private _completedAt: Date | null;
  private _tags: string[];
  private _subtasks: TaskId[];

  private constructor(
    id: TaskId,
    title: TaskTitle,
    description: TaskDescription,
    status: TaskStatus,
    priority: Priority,
    dueDate: DueDate,
    assignee: Assignee,
    projectId: ProjectId | null,
    createdAt: Date,
    updatedAt: Date,
    completedAt: Date | null,
    tags: string[],
    subtasks: TaskId[],
    version: number
  ) {
    super(id, version);
    this._title = title;
    this._description = description;
    this._status = status;
    this._priority = priority;
    this._dueDate = dueDate;
    this._assignee = assignee;
    this._projectId = projectId;
    this._createdAt = createdAt;
    this._updatedAt = updatedAt;
    this._completedAt = completedAt;
    this._tags = tags;
    this._subtasks = subtasks;
  }

  /**
   * Factory method to create a new Task.
   */
  static create(params: CreateTaskParams): Task {
    const id = TaskId.generate();
    const title = TaskTitle.create(params.title);
    const description = params.description
      ? TaskDescription.create(params.description)
      : TaskDescription.empty();
    const status = TaskStatus.todo();
    const priority = params.priority
      ? Priority.create(params.priority)
      : Priority.medium();
    const dueDate = params.dueDate
      ? DueDate.create(params.dueDate)
      : DueDate.none();
    const assignee = params.assignee
      ? Assignee.create(params.assignee.userId, params.assignee.name, params.assignee.email)
      : Assignee.unassigned();
    const projectId = params.projectId ?? null;
    const now = new Date();

    const task = new Task(
      id,
      title,
      description,
      status,
      priority,
      dueDate,
      assignee,
      projectId,
      now,
      now,
      null,
      [],
      [],
      0
    );

    task.addDomainEvent(new TaskCreatedEvent(id, title.value, projectId, params.createdBy));

    return task;
  }

  /**
   * Reconstitutes a Task from persistence.
   */
  static reconstitute(
    id: TaskId,
    title: TaskTitle,
    description: TaskDescription,
    status: TaskStatus,
    priority: Priority,
    dueDate: DueDate,
    assignee: Assignee,
    projectId: ProjectId | null,
    createdAt: Date,
    updatedAt: Date,
    completedAt: Date | null,
    tags: string[],
    subtasks: TaskId[],
    version: number
  ): Task {
    return new Task(
      id,
      title,
      description,
      status,
      priority,
      dueDate,
      assignee,
      projectId,
      createdAt,
      updatedAt,
      completedAt,
      tags,
      subtasks,
      version
    );
  }

  // Getters
  get title(): TaskTitle {
    return this._title;
  }

  get description(): TaskDescription {
    return this._description;
  }

  get status(): TaskStatus {
    return this._status;
  }

  get priority(): Priority {
    return this._priority;
  }

  get dueDate(): DueDate {
    return this._dueDate;
  }

  get assignee(): Assignee {
    return this._assignee;
  }

  get projectId(): ProjectId | null {
    return this._projectId;
  }

  get createdAt(): Date {
    return new Date(this._createdAt);
  }

  get updatedAt(): Date {
    return new Date(this._updatedAt);
  }

  get completedAt(): Date | null {
    return this._completedAt ? new Date(this._completedAt) : null;
  }

  get tags(): readonly string[] {
    return [...this._tags];
  }

  get subtasks(): readonly TaskId[] {
    return [...this._subtasks];
  }

  get isOverdue(): boolean {
    return this._dueDate.isOverdue && !this._status.isComplete;
  }

  // Business Logic Methods

  /**
   * Updates the task title.
   */
  updateTitle(newTitle: string): void {
    this.ensureNotCompleted();
    this._title = TaskTitle.create(newTitle);
    this.touch();
  }

  /**
   * Updates the task description.
   */
  updateDescription(newDescription: string): void {
    this.ensureNotCompleted();
    this._description = TaskDescription.create(newDescription);
    this.touch();
  }

  /**
   * Changes the task status.
   */
  changeStatus(newStatus: TaskStatusValue, changedBy: string): void {
    const previousStatus = this._status;
    const newStatusObj = TaskStatus.create(newStatus);

    if (previousStatus.equals(newStatusObj)) {
      return; // No change
    }

    this._status = newStatusObj;

    if (newStatusObj.isDone) {
      this._completedAt = new Date();
      this.addDomainEvent(new TaskCompletedEvent(this.id, changedBy));
    } else if (previousStatus.isDone) {
      this._completedAt = null; // Reopening task
    }

    this.addDomainEvent(
      new TaskStatusChangedEvent(this.id, previousStatus, newStatusObj, changedBy)
    );

    this.touch();
  }

  /**
   * Starts working on the task.
   */
  start(startedBy: string): void {
    this.ensureNotCompleted();
    if (!this._status.isTodo) {
      throw new Error('Can only start a task that is in TODO status');
    }
    this.changeStatus(TaskStatusValue.IN_PROGRESS, startedBy);
  }

  /**
   * Moves task to review.
   */
  submitForReview(submittedBy: string): void {
    this.ensureNotCompleted();
    if (!this._status.isInProgress) {
      throw new Error('Can only submit for review a task that is IN_PROGRESS');
    }
    this.changeStatus(TaskStatusValue.IN_REVIEW, submittedBy);
  }

  /**
   * Completes the task.
   */
  complete(completedBy: string): void {
    this.ensureNotCompleted();
    this.changeStatus(TaskStatusValue.DONE, completedBy);
  }

  /**
   * Cancels the task.
   */
  cancel(cancelledBy: string): void {
    this.ensureNotCompleted();
    this.changeStatus(TaskStatusValue.CANCELLED, cancelledBy);
  }

  /**
   * Reopens a completed task.
   */
  reopen(reopenedBy: string): void {
    if (!this._status.isComplete) {
      throw new Error('Can only reopen a completed task');
    }
    this.changeStatus(TaskStatusValue.TODO, reopenedBy);
  }

  /**
   * Assigns the task to someone.
   */
  assign(userId: string, name: string, email: string, assignedBy: string): void {
    this.ensureNotCompleted();
    this._assignee = Assignee.create(userId, name, email);
    this.addDomainEvent(new TaskAssignedEvent(this.id, this._assignee, assignedBy));
    this.touch();
  }

  /**
   * Unassigns the task.
   */
  unassign(): void {
    this.ensureNotCompleted();
    this._assignee = Assignee.unassigned();
    this.touch();
  }

  /**
   * Updates the priority.
   */
  updatePriority(priority: PriorityLevel): void {
    this.ensureNotCompleted();
    this._priority = Priority.create(priority);
    this.touch();
  }

  /**
   * Sets the due date.
   */
  setDueDate(dueDate: Date): void {
    this.ensureNotCompleted();
    this._dueDate = DueDate.create(dueDate);
    this.touch();
  }

  /**
   * Removes the due date.
   */
  removeDueDate(): void {
    this.ensureNotCompleted();
    this._dueDate = DueDate.none();
    this.touch();
  }

  /**
   * Adds a tag to the task.
   */
  addTag(tag: string): void {
    this.ensureNotCompleted();
    const normalizedTag = tag.trim().toLowerCase();
    if (normalizedTag.length === 0) {
      throw new Error('Tag cannot be empty');
    }
    if (!this._tags.includes(normalizedTag)) {
      this._tags.push(normalizedTag);
      this.touch();
    }
  }

  /**
   * Removes a tag from the task.
   */
  removeTag(tag: string): void {
    this.ensureNotCompleted();
    const normalizedTag = tag.trim().toLowerCase();
    const index = this._tags.indexOf(normalizedTag);
    if (index !== -1) {
      this._tags.splice(index, 1);
      this.touch();
    }
  }

  /**
   * Adds a subtask reference.
   */
  addSubtask(subtaskId: TaskId): void {
    this.ensureNotCompleted();
    if (!this._subtasks.some(id => id.equals(subtaskId))) {
      this._subtasks.push(subtaskId);
      this.touch();
    }
  }

  /**
   * Removes a subtask reference.
   */
  removeSubtask(subtaskId: TaskId): void {
    this.ensureNotCompleted();
    const index = this._subtasks.findIndex(id => id.equals(subtaskId));
    if (index !== -1) {
      this._subtasks.splice(index, 1);
      this.touch();
    }
  }

  /**
   * Moves the task to a different project.
   */
  moveToProject(projectId: ProjectId | null): void {
    this.ensureNotCompleted();
    this._projectId = projectId;
    this.touch();
  }

  // Private helpers

  private ensureNotCompleted(): void {
    if (this._status.isComplete) {
      throw new Error('Cannot modify a completed task');
    }
  }

  private touch(): void {
    this._updatedAt = new Date();
  }
}
