/**
 * Query to get a task by ID.
 */
export class GetTaskQuery {
  constructor(readonly taskId: string) {
    if (!taskId || taskId.trim().length === 0) {
      throw new Error('Task ID is required');
    }
  }
}

/**
 * Query to get tasks by project.
 */
export class GetTasksByProjectQuery {
  constructor(readonly projectId: string) {
    if (!projectId || projectId.trim().length === 0) {
      throw new Error('Project ID is required');
    }
  }
}

/**
 * Query to get tasks assigned to a user.
 */
export class GetTasksByAssigneeQuery {
  constructor(readonly userId: string) {
    if (!userId || userId.trim().length === 0) {
      throw new Error('User ID is required');
    }
  }
}

/**
 * Query to get overdue tasks.
 */
export class GetOverdueTasksQuery {
  constructor() {}
}
