-- Complete RLS fix - drop and recreate everything

-- Ensure RLS is enabled
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Allow service role full access to tasks" ON tasks;
DROP POLICY IF EXISTS "Allow users to update their own tasks" ON tasks;
DROP POLICY IF EXISTS "Allow users to delete their own untaken tasks" ON tasks;
DROP POLICY IF EXISTS "Allow assignees to mark tasks as completed" ON tasks;

-- Update existing null task_status values to 'todo'
UPDATE tasks SET task_status = 'todo' WHERE task_status IS NULL;

-- Reset all completed tasks back to 'todo' for testing
UPDATE tasks SET task_status = 'todo' WHERE task_status = 'completed';

-- Drop and recreate the task_status constraint
ALTER TABLE tasks DROP CONSTRAINT IF EXISTS tasks_task_status_check;
ALTER TABLE tasks ADD CONSTRAINT tasks_task_status_check 
  CHECK (task_status IN ('todo', 'pending_completion', 'completed', 'cancelled'));

-- Create policy to allow service role to perform any operation on tasks
CREATE POLICY "Allow service role full access to tasks" 
ON tasks 
FOR ALL 
USING (true) 
WITH CHECK (true);

-- Create policy to allow users to update tasks they own or are assigned to
CREATE POLICY "Allow users to update their own tasks" 
ON tasks 
FOR UPDATE 
USING (requester_id = auth.uid() OR assignee_id = auth.uid())
WITH CHECK (requester_id = auth.uid() OR assignee_id = auth.uid());

-- Create policy to allow users to delete their own tasks (only if not taken)
CREATE POLICY "Allow users to delete their own untaken tasks" 
ON tasks 
FOR DELETE 
USING (requester_id = auth.uid() AND assignee_id IS NULL);

-- Create policy to allow assignees to mark tasks as completed
CREATE POLICY "Allow assignees to mark tasks as completed" 
ON tasks 
FOR UPDATE 
USING (assignee_id = auth.uid() AND task_status = 'todo')
WITH CHECK (assignee_id = auth.uid() AND task_status IN ('todo', 'pending_completion', 'completed', 'cancelled'));
