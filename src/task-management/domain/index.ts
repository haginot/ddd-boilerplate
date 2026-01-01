// Value Objects
export { TaskId } from './TaskId.js';
export { TaskTitle } from './TaskTitle.js';
export { TaskDescription } from './TaskDescription.js';
export { TaskStatus, TaskStatusValue } from './TaskStatus.js';
export { Priority, PriorityLevel } from './Priority.js';
export { DueDate } from './DueDate.js';
export { Assignee } from './Assignee.js';
export { ProjectId } from './ProjectId.js';

// Aggregate
export { Task } from './Task.js';
export type { CreateTaskParams } from './Task.js';

// Repository Interface
export type { TaskRepository } from './TaskRepository.js';

// Domain Events
export { TaskCreatedEvent } from './events/TaskCreatedEvent.js';
export { TaskCompletedEvent } from './events/TaskCompletedEvent.js';
export { TaskAssignedEvent } from './events/TaskAssignedEvent.js';
export { TaskStatusChangedEvent } from './events/TaskStatusChangedEvent.js';
