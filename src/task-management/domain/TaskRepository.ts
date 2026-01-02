import type { Task } from './Task.js';
import type { TaskId } from './TaskId.js';
import type { ProjectId } from './ProjectId.js';
import type { TaskStatusValue } from './TaskStatus.js';

/**
 * Repository interface for Task aggregate.
 * Defined in Domain layer, implemented in Infrastructure layer.
 */
export interface TaskRepository {
  /**
   * Saves a task (create or update).
   */
  save(task: Task): Promise<void>;

  /**
   * Finds a task by its ID.
   */
  findById(id: TaskId): Promise<Task | null>;

  /**
   * Finds all tasks in a project.
   */
  findByProjectId(projectId: ProjectId): Promise<Task[]>;

  /**
   * Finds all tasks assigned to a user.
   */
  findByAssigneeId(userId: string): Promise<Task[]>;

  /**
   * Finds all tasks with a specific status.
   */
  findByStatus(status: TaskStatusValue): Promise<Task[]>;

  /**
   * Finds all overdue tasks.
   */
  findOverdue(): Promise<Task[]>;

  /**
   * Finds tasks due today.
   */
  findDueToday(): Promise<Task[]>;

  /**
   * Finds tasks by tag.
   */
  findByTag(tag: string): Promise<Task[]>;

  /**
   * Deletes a task.
   */
  delete(id: TaskId): Promise<void>;

  /**
   * Checks if a task exists.
   */
  exists(id: TaskId): Promise<boolean>;
}
