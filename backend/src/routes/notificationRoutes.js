const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const supabase = require('../config/supabase');
const NotificationService = require('../services/notificationService');

// Middleware to verify JWT
const verifyToken = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({
      status: 'error',
      message: 'Access token required',
    });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({
      status: 'error',
      message: 'Invalid or expired token',
    });
  }
};

// Test endpoint without authentication
router.post('/test-task-acceptance', async (req, res) => {
  try {
    // Use different user IDs for requester and assignee (simulating real scenario)
    const requesterId = '620372f3-a444-447d-9346-c5843442e478'; // Task owner
    const assigneeId = '46179b8b-a88d-438c-a347-29a869eff7b7'; // Task taker
    const taskId = 'test-task-id-123';
    const taskTitle = 'Test Task: Clean the garage';
    
    console.log('Testing task acceptance notification...');
    console.log('Task owner ID:', requesterId);
    console.log('Task taker ID:', assigneeId);
    
    const notification = await NotificationService.createTaskAcceptedNotification(
      taskId,
      taskTitle,
      assigneeId,
      requesterId
    );
    
    res.status(200).json({
      status: 'success',
      message: 'Task acceptance notification created for both users',
      requesterId: requesterId,
      assigneeId: assigneeId,
      data: notification
    });
  } catch (error) {
    console.error('Error in test task acceptance endpoint:', error);
    res.status(500).json({
      status: 'error',
      message: 'Internal server error'
    });
  }
});

// Test endpoint without authentication
router.post('/test-no-auth', async (req, res) => {
  try {
    // Use a hardcoded user ID for testing
    const userId = '46179b8b-a88d-438c-a347-29a869eff7b7';
    console.log('Creating test notification without auth for user:', userId);
    
    const notification = await NotificationService.createTaskAcceptedNotification(
      'test-task-id',
      'Test Task',
      userId,
      userId // Use same user ID for both requester and assignee
    );
    
    res.status(200).json({
      status: 'success',
      message: 'Task acceptance notification created',
      data: notification
    });
  } catch (error) {
    console.error('Error in test notification endpoint:', error);
    res.status(500).json({
      status: 'error',
      message: 'Internal server error'
    });
  }
});

// Test endpoint to create a notification
router.post('/test', verifyToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    console.log('Creating test notification for user:', userId);
    
    const notification = await NotificationService.createNotification(
      userId,
      'Test Notification',
      'This is a test notification to verify the system works',
      'task' // Try 'task' instead of 'info'
    );
    
    if (notification) {
      res.status(200).json({
        status: 'success',
        message: 'Test notification created',
        data: notification
      });
    } else {
      res.status(500).json({
        status: 'error',
        message: 'Failed to create test notification'
      });
    }
  } catch (error) {
    console.error('Error in test notification endpoint:', error);
    res.status(500).json({
      status: 'error',
      message: 'Internal server error'
    });
  }
});

// GET /api/notifications - Get all notifications for the authenticated user
router.get('/', verifyToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    
    // Fetch notifications for the user, ordered by most recent first
    const { data: notifications, error } = await supabase
      .from('notifications')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
      .limit(50);

    if (error) {
      console.error('Error fetching notifications:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to fetch notifications',
      });
    }

    res.status(200).json({
      status: 'success',
      data: notifications || [],
    });
  } catch (error) {
    console.error('Error in notifications endpoint:', error);
    res.status(500).json({
      status: 'error',
      message: 'Internal server error',
    });
  }
});

// GET /api/notifications/unread - Get unread notifications count
router.get('/unread', verifyToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    
    // Count unread notifications
    const { data: notifications, error } = await supabase
      .from('notifications')
      .select('id')
      .eq('user_id', userId)
      .eq('is_read', false);

    if (error) {
      console.error('Error fetching unread count:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to fetch unread count',
      });
    }

    res.status(200).json({
      status: 'success',
      data: {
        unreadCount: notifications?.length || 0,
      },
    });
  } catch (error) {
    console.error('Error in unread notifications endpoint:', error);
    res.status(500).json({
      status: 'error',
      message: 'Internal server error',
    });
  }
});

// PUT /api/notifications/:id/read - Mark a notification as read
router.put('/:id/read', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;
    console.log(`Marking notification ${id} as read for user: ${userId}`);

    // Update notification as read
    const { data: notification, error } = await supabase
      .from('notifications')
      .update({ is_read: true })
      .eq('id', id)
      .eq('user_id', userId)
      .select('id, user_id, title, message, type, is_read, created_at')
      .single();

    if (error) {
      console.error('Error marking notification as read:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to mark notification as read',
      });
    }

    if (!notification) {
      console.log('Notification not found');
      return res.status(404).json({
        status: 'error',
        message: 'Notification not found',
      });
    }

    console.log('Notification marked as read successfully');
    res.status(200).json({
      status: 'success',
      message: 'Notification marked as read',
      data: notification,
    });
  } catch (error) {
    console.error('Error in mark as read endpoint:', error);
    res.status(500).json({
      status: 'error',
      message: 'Internal server error',
    });
  }
});

// PUT /api/notifications/read-all - Mark all notifications as read
router.put('/read-all', verifyToken, async (req, res) => {
  try {
    const userId = req.user.userId;
    console.log(`Marking all notifications as read for user: ${userId}`);

    // Update all notifications as read for the user
    const { data: notifications, error } = await supabase
      .from('notifications')
      .update({ is_read: true })
      .eq('user_id', userId)
      .select('id');

    if (error) {
      console.error('Error marking all notifications as read:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to mark all notifications as read',
      });
    }

    console.log(`Marked ${notifications?.length || 0} notifications as read`);
    res.status(200).json({
      status: 'success',
      message: 'All notifications marked as read',
      data: notifications,
    });
  } catch (error) {
    console.error('Error in read-all endpoint:', error);
    res.status(500).json({
      status: 'error',
      message: 'Internal server error',
    });
  }
});

module.exports = router;

// DELETE /api/notifications/:id - Delete a notification
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    // Delete notification
    const { error } = await supabase
      .from('notifications')
      .delete()
      .eq('id', id)
      .eq('user_id', userId);

    if (error) {
      console.error('Error deleting notification:', error);
      return res.status(500).json({
        status: 'error',
        message: 'Failed to delete notification',
      });
    }

    res.status(200).json({
      status: 'success',
      message: 'Notification deleted successfully',
    });
  } catch (error) {
    console.error('Error in delete notification endpoint:', error);
    res.status(500).json({
      status: 'error',
      message: 'Internal server error',
    });
  }
});

module.exports = router;
