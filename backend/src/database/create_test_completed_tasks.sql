-- Create some test completed tasks for testing
-- This will help verify that the completed tasks functionality works

-- First, let's see what users and tasks exist
-- Then we'll update some tasks to be completed

-- Update a few existing tasks to be completed for testing
UPDATE tasks 
SET task_status = 'completed' 
WHERE assignee_id IS NOT NULL 
AND task_status = 'todo'
LIMIT 3;

-- Show the updated tasks
SELECT id, title, assignee_id, task_status, created_at 
FROM tasks 
WHERE task_status = 'completed'
ORDER BY created_at DESC;
