// backend/src/routes/createTaskRoutes.js
const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const supabase = require('../config/supabase');

// Middleware to verify JWT
const verifyToken = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  
  if (!token) {
    return res.status(401).json({ 
      status: 'error',
      message: 'Authentication required' 
    });
  }

  try {
    // Verify the JWT token using the secret from environment variables
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    console.log('Decoded token:', decoded); // Debug log
    req.user = decoded;
    next();
  } catch (error) {
    console.error('Token verification error:', error);
    return res.status(401).json({ 
      status: 'error',
      message: 'Invalid or expired token' 
    });
  }
};

const formatTaskResponse = (task, requesterLookup = {}) => {
  const rewardValue = typeof task.reward === 'number' ? task.reward : parseFloat(task.reward || 0);
  const requesterProfile = requesterLookup[task.requester_id] || {};

  return {
    id: task.id,
    title: task.task_title,
    description: task.task_description,
    reward: Number.isNaN(rewardValue) ? 0 : rewardValue,
    category: task.task_category,
    priority: task.task_priority,
    dueDate: task.due_date,
    location: task.location,
    status: task.task_status,
    createdAt: task.created_at,
    requesterId: task.requester_id,
    requesterName: requesterProfile.full_name || 'Task Owner',
    requesterAvatar: requesterProfile.avatar_url || null,
    assigneeId: task.assignee_id, // Add assignee_id to response
  };
};

const buildRequesterLookup = async (tasks = []) => {
  const requesterIds = [...new Set(tasks.map((task) => task.requester_id).filter(Boolean))];

  if (!requesterIds.length) {
    return {};
  }

  const { data: profiles, error } = await supabase.auth.admin.listUsers();
  
  if (error) {
    console.error('Error fetching profiles:', error);
    return {};
  }

  const filteredUsers = (profiles.users || []).filter(user => requesterIds.includes(user.id));
  
  return filteredUsers.reduce((acc, user) => {
    acc[user.id] = {
      full_name: user.user_metadata?.full_name || user.email?.split('@')[0] || 'Unknown User',
      avatar_url: user.user_metadata?.avatar_url || null,
    };
    return acc;
  }, {});
};

const buildAssigneeLookup = async (tasks = []) => {
  const assigneeIds = [...new Set(tasks.map((task) => task.assignee_id).filter(Boolean))];

  if (!assigneeIds.length) {
    return {};
  }

  const { data: profiles, error } = await supabase.auth.admin.listUsers();
  
  if (error) {
    console.error('Error fetching assignee profiles:', error);
    return {};
  }

  const filteredUsers = (profiles.users || []).filter(user => assigneeIds.includes(user.id));
  
  return filteredUsers.reduce((acc, user) => {
    acc[user.id] = {
      full_name: user.user_metadata?.full_name || user.email?.split('@')[0] || 'Unknown User',
      avatar_url: user.user_metadata?.avatar_url || null,
    };
    return acc;
  }, {});
};

// GET /api/tasks
router.get('/', async (req, res) => {
  try {
    const { category } = req.query;

    let query = supabase
      .from('tasks')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(50);

    if (category) {
      query = query.eq('task_category', category);
    }

    const { data, error } = await query;

    if (error) {
      throw error;
    }

    const requesterLookup = await buildRequesterLookup(data || []);
    const formatted = (data || []).map((task) => {
      const formattedTask = formatTaskResponse(task, requesterLookup);
      console.log(`Task ${task.id}: assignee_id = ${task.assignee_id}, assigneeId = ${formattedTask.assigneeId}`);
      return formattedTask;
    });

    res.status(200).json({
      status: 'success',
      data: formatted,
    });
  } catch (error) {
    console.error('Error fetching tasks:', error.message);
    res.status(500).json({
      status: 'error',
      message: error.message || 'Internal server error',
    });
  }
});

// GET /api/tasks/mine
router.get('/mine', verifyToken, async (req, res) => {
  try {
    // Get tasks accepted by the user (active tasks they need to work on)
    const { data: acceptedTasks, error: acceptedError } = await supabase
      .from('tasks')
      .select('*')
      .eq('assignee_id', req.user.userId)
      .not('assignee_id', 'is', null);

    if (acceptedError) {
      throw acceptedError;
    }

    // For now, return only accepted tasks as "active tasks"
    // Posted tasks should be fetched separately for the "Posted Tasks" tab
    const allTasks = acceptedTasks || [];
    
    const requesterLookup = await buildRequesterLookup(allTasks);
    const formatted = allTasks.map((task) => ({
      ...formatTaskResponse(task, requesterLookup),
      isMine: task.requester_id === req.user.userId,
    }));

    res.status(200).json({
      status: 'success',
      data: formatted,
    });
  } catch (error) {
    console.error('Error fetching user tasks:', error.message);
    res.status(500).json({
      status: 'error',
      message: error.message || 'Internal server error',
    });
  }
});

// GET /api/tasks/posted
router.get('/posted', verifyToken, async (req, res) => {
  try {
    // Get tasks posted by the user
    const { data: postedTasks, error: postedError } = await supabase
      .from('tasks')
      .select('*')
      .eq('requester_id', req.user.userId);

    if (postedError) {
      throw postedError;
    }
    
    const [requesterLookup, assigneeLookup] = await Promise.all([
      buildRequesterLookup(postedTasks || []),
      buildAssigneeLookup(postedTasks || [])
    ]);
    
    const formatted = (postedTasks || []).map((task) => {
      const assigneeProfile = assigneeLookup[task.assignee_id];
      return {
        ...formatTaskResponse(task, requesterLookup),
        isMine: true, // All tasks here are posted by the user
        assigneeName: assigneeProfile?.full_name || null,
        assigneeAvatar: assigneeProfile?.avatar_url || null,
      };
    });

    res.status(200).json({
      status: 'success',
      data: formatted,
    });
  } catch (error) {
    console.error('Error fetching posted tasks:', error);
    res.status(500).json({
      status: 'error',
      message: error.message || 'Internal server error',
    });
  }
});

// POST /api/tasks
router.post('/', verifyToken, async (req, res) => {
  try {
    console.log('Request body:', req.body);
    
    const taskData = {
        requester_id: req.user.userId,
        task_title: req.body.title,
        task_description: req.body.description,
        reward: parseFloat(req.body.reward),
        task_category: req.body.category,
        task_priority: req.body.priority,
        due_date: req.body.dueDate ? new Date(req.body.dueDate).toISOString() : null,
        location: req.body.location || null,
        task_status: 'todo'
    };

    // Only add location if coordinates are provided
    if (req.body.location?.coordinates) {
      taskData.location = `POINT(${req.body.location.coordinates[0]} ${req.body.location.coordinates[1]})`;
    }

    console.log('Prepared task data:', taskData);

    const { data: task, error } = await supabase
      .from('tasks')
      .insert(taskData)
      .select()
      .single();

    if (error) {
      console.error('Database error:', error);
      throw error;
    }

    res.status(201).json({
      status: 'success',
      data: task
    });

  } catch (error) {
    console.error('Error creating task:', error);
    res.status(500).json({
      status: 'error',
      message: error.message || 'Internal server error'
    });
  }
});

// POST /api/tasks/:id/accept
router.post('/:id/accept', verifyToken, async (req, res) => {
  try {
    const taskId = req.params.id;
    const userId = req.user.userId;

    console.log(`User ${userId} attempting to accept task ${taskId}`);

    // Check if task exists and is available
    const { data: task, error: taskError } = await supabase
      .from('tasks')
      .select('*')
      .eq('id', taskId)
      .maybeSingle();

    if (taskError || !task) {
      return res.status(404).json({
        status: 'error',
        message: 'Task not found',
      });
    }

    // Check if task is already accepted
    if (task.task_status !== 'todo') {
      return res.status(400).json({
        status: 'error',
        message: 'Task is no longer available',
      });
    }

    // Check if user is trying to accept their own task
    if (task.requester_id === userId) {
      return res.status(400).json({
        status: 'error',
        message: 'You cannot accept your own task',
      });
    }

    // Update task - assign to user
    const { data: updatedTask, error: updateError } = await supabase
      .from('tasks')
      .update({
        assignee_id: userId,
        updated_at: new Date().toISOString()
      })
      .eq('id', taskId)
      .is('assignee_id', null) // Only update if not already taken
      .select();

    if (updateError) {
      console.error('Error updating task:', updateError);
      throw updateError;
    }

    if (!updatedTask || updatedTask.length === 0) {
      return res.status(400).json({
        status: 'error',
        message: 'Task is no longer available',
      });
    }

    console.log(`Task ${taskId} successfully accepted by user ${userId}`);

    res.status(200).json({
      status: 'success',
      message: 'Task accepted successfully',
      data: updatedTask
    });

  } catch (error) {
    console.error('Error accepting task:', error);
    res.status(500).json({
      status: 'error',
      message: error.message || 'Internal server error',
    });
  }
});

module.exports = router;