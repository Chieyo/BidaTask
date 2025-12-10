const supabase = require('../config/supabase');

class NotificationService {
  // Create a new notification
  // Create notification when task is accepted
  static async createTask try {
      const { data, error } = await supabase
        .from('notifications')
        .insert({
          user_id: userId,
          title: title,
          message: message,
          type: 'task', // Use 'task' type which should be allowed
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
    // Notify the task requester that their task was accepted
    await this.createNotification(
      requesterId,
      'Task Accepted',
      `Your task "${taskTitle}" has been accepted by a helper`,
      'info', // Use 'info' instead of 'success'
      taskId
    );

    // Notify the assignee that they accepted the task
    await this.createNotification(
      assigneeId,
      'Task Accepted',
      `You have accepted the task: "${taskTitle}"`,
      'info', // Use 'info' instead of 'success'
      taskId
    );
  }

  // Create notification when task is completed
  static async createTaskCompletedNotification(taskId, taskTitle, assigneeId, requesterId) {
    // Notify the task requester that their task was completed
    await this.createNotification(
      requesterId,
      'Task Completed',
      `Your task "${taskTitle}" has been marked as completed`,
      'info', // Use 'info' instead of 'success'
      taskId
    );

    // Notify the assignee that they completed the task
    await this.createNotification(
      assigneeId,
      'Task Completed',
      `You have completed the task: "${taskTitle}"`,
      'info', // Use 'info' instead of 'success'
      taskId
    );
  }

  // Create notification when task is posted
  static async createTaskPostedNotification(taskId, taskTitle, requesterId) {
    await this.createNotification(
      requesterId,
      'Task Posted',
      `Your task "${taskTitle}" has been posted successfully`,
      'success',
      taskId
    );
  }

  // Create notification when task is overdue
  static async createTaskOverdueNotification(taskId, taskTitle, assigneeId) {
    await this.createNotification(
      assigneeId,
      'Task Overdue',
      `Your task "${taskTitle}" is overdue`,
      'warning',
      taskId
    );
  }
}

module.exports = NotificationService;
