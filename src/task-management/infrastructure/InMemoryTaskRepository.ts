import type { TaskRepository } from '../domain/TaskRepository.js';
import type { Task } from '../domain/Task.js';
import type { TaskId } from '../domain/TaskId.js';
import type { ProjectId } from '../domain/ProjectId.js';
import type { TaskStatusValue } from '../domain/TaskStatus.js';

/**
 * In-memory implementation of TaskRepository.
 * Useful for testing and development.
 */
export class InMemoryTaskRepository implements TaskRepository {
  private tasks: Map<string, Task> = new Map();

  async save(task: Task): Promise<void> {
    this.tasks.set(task.id.value, task);
  }

  async findById(id: TaskId): Promise<Task | null> {
    return this.tasks.get(id.value) ?? null;
  }

  async findByProjectId(projectId: ProjectId): Promise<Task[]> {
    return Array.from(this.tasks.values()).filter(
      task => task.projectId?.equals(projectId)
    );
  }

  async findByAssigneeId(userId: string): Promise<Task[]> {
    return Array.from(this.tasks.values()).filter(
      task => task.assignee.userId === userId
    );
  }

  async findByStatus(status: TaskStatusValue): Promise<Task[]> {
    return Array.from(this.tasks.values()).filter(
      task => task.status.value === status
    );
  }

  async findOverdue(): Promise<Task[]> {
    return Array.from(this.tasks.values()).filter(task => task.isOverdue);
  }

  async findDueToday(): Promise<Task[]> {
    return Array.from(this.tasks.values()).filter(
      task => task.dueDate.isDueToday && !task.status.isComplete
    );
  }

  async findByTag(tag: string): Promise<Task[]> {
    const normalizedTag = tag.trim().toLowerCase();
    return Array.from(this.tasks.values()).filter(task =>
      task.tags.includes(normalizedTag)
    );
  }

  async delete(id: TaskId): Promise<void> {
    this.tasks.delete(id.value);
  }

  async exists(id: TaskId): Promise<boolean> {
    return this.tasks.has(id.value);
  }

  // Test helper methods
  clear(): void {
    this.tasks.clear();
  }

  count(): number {
    return this.tasks.size;
  }

  getAll(): Task[] {
    return Array.from(this.tasks.values());
  }
}
