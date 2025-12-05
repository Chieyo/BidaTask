-- Create proper RLS policy for task updates
-- This allows the service role to update tasks when they're not taken

-- First, ensure RLS is enabled
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Create policy to allow service role to perform any operation on tasks
-- Service role bypasses RLS entirely when using service key
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
USING (assignee_id = auth.uid() AND (task_status = 'todo' OR task_status = 'pending_completion'))
WITH CHECK (assignee_id = auth.uid() OR task_status IN ('todo', 'pending_completion', 'completed'));

-- Add pending_completion to the task_status check constraint
ALTER TABLE tasks DROP CONSTRAINT IF EXISTS tasks_task_status_check;
ALTER TABLE tasks ADD CONSTRAINT tasks_task_status_check 
  CHECK (task_status IN ('todo', 'pending_completion', 'completed', 'cancelled'));
