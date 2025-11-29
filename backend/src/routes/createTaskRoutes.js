// backend/src/routes/createTaskRoutes.js
const express = require('express');
const router = express.Router();
const { createClient } = require('@supabase/supabase-js');
const jwt = require('jsonwebtoken');

// Create a client for database operations
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
);

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

// POST /api/tasks
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
        location: req.body.locationName || null,
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