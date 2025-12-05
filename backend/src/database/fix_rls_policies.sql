-- Create proper RLS policy for task updates
-- This allows the service role to update tasks when they're not taken

-- First, ensure RLS is enabled
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Create policy to allow service role to perform any operation on tasks
CREATE POLICY "Allow service role full access to tasks" 
ON tasks 
FOR ALL 
USING (auth.jwt() ->> 'role' = 'service_role' OR auth.jwt() ->> 'role' IS NULL) 
WITH CHECK (auth.jwt() ->> 'role' = 'service_role' OR auth.jwt() ->> 'role' IS NULL);

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
