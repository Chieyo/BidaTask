const supabase = require('../config/supabase');

class NotificationService {
  // Create a new notification
  static async createNotification(userId, title, message, type = 'task', taskId = null) {
    try {
      console.log('Creating notification:', { userId, title, message, type, taskId });
      
      const { data, error } = await supabase
        .from('notifications')
        .insert({
          user_id: userId,
          title: title,
          message: message,
          type: 'task', // Always use 'task' type which should be allowed
          is_read: false,
        })
        .select()
        .single();

      if (error) {
        console.error('Error creating notification:', error);
        return null;
      }

      console.log('Notification created successfully:', data);
      return data;
    } catch (error) {
      console.error('Error in createNotification:', error);
      return null;
    }
  }

  // Create notification when task is accepted
  static async createTaskAcceptedNotification(taskId, taskTitle, assigneeId, requesterId) {
    // First, get the assignee's name to include in the notification
    const { data: assignee, error: assigneeError } = await supabase
      .from('users')
      .select('full_name')
      .eq('id', assigneeId)
      .single();

    const assigneeName = assignee?.full_name || 'A helper';
    
    // Notify the task requester that their task was accepted
    await this.createNotification(
      requesterId,
      'Task Taken',
      `${assigneeName} accepted "${taskTitle}"`,
      'task',
      taskId
    );

    // Notify the assignee that they accepted the task
    await this.createNotification(
      assigneeId,
      'Task Accepted',
      `You accepted "${taskTitle}"`,
      'task',
      taskId
    );
  }

  // Create notification when task is completed
  static async createTaskCompletedNotification(taskId, taskTitle, assigneeId, requesterId) {
    // Get the assignee's name
    const { data: assignee, error: assigneeError } = await supabase
      .from('users')
      .select('full_name')
      .eq('id', assigneeId)
      .single();

    const assigneeName = assignee?.full_name || 'A helper';
    
    // Notify the task requester that their task was completed
    await this.createNotification(
      requesterId,
      'Task Completed',
      `${assigneeName} completed "${taskTitle}"`,
      'task',
      taskId
    );

    // Notify the assignee that they completed the task
    await this.createNotification(
      assigneeId,
      'Task Finished',
      `You completed "${taskTitle}"`,
      'task',
      taskId
    );
  }

  // Create notification when task is posted
  static async createTaskPostedNotification(taskId, taskTitle, requesterId) {
    await this.createNotification(
      requesterId,
      'Task Posted',
      `Your task "${taskTitle}" has been posted successfully`,
      'task',
      taskId
    );
  }

  // Create notification when task is overdue
  static async createTaskOverdueNotification(taskId, taskTitle, assigneeId) {
    await this.createNotification(
      assigneeId,
      'Task Overdue',
      `Your task "${taskTitle}" is overdue`,
      'task',
      taskId
    );
  }
}

module.exports = NotificationService;
