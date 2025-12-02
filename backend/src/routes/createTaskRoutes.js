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
    locationName: task.location_name,
    status: task.task_status,
    createdAt: task.created_at,
    requesterId: task.requester_id,
    requesterName: requesterProfile.full_name || 'Task Owner',
    requesterAvatar: requesterProfile.avatar_url || null,
  };
};

const buildRequesterLookup = async (tasks = []) => {
  const requesterIds = [...new Set(tasks.map((task) => task.requester_id).filter(Boolean))];

  if (!requesterIds.length) {
    return {};
  }

  const { data, error } = await supabase
    .from('users')
    .select('id, full_name, avatar_url')
    .in('id', requesterIds);

  if (error) {
    console.error('Error fetching requester profiles:', error.message);
    return {};
  }

  return data.reduce((acc, profile) => {
    acc[profile.id] = profile;
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
    const formatted = (data || []).map((task) => formatTaskResponse(task, requesterLookup));

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
    const { data, error } = await supabase
      .from('tasks')
      .select('*')
      .eq('requester_id', req.user.userId)
      .order('created_at', { ascending: false });

    if (error) {
      throw error;
    }

    const requesterLookup = await buildRequesterLookup(data || []);
    const formatted = (data || []).map((task) => ({
      ...formatTaskResponse(task, requesterLookup),
      isMine: true,
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
        location_name: req.body.locationName || null,
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

module.exports = router;