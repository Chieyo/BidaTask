-- Add assignee_id column to tasks table
ALTER TABLE public.tasks 
ADD COLUMN IF NOT EXISTS assignee_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;

-- Add index for better performance
CREATE INDEX IF NOT EXISTS idx_tasks_assignee_id ON public.tasks(assignee_id);

-- Update RLS policies to allow access to assigned tasks
CREATE POLICY IF NOT EXISTS "Users can view assigned tasks"
  ON public.tasks FOR SELECT
  USING (auth.uid() = assignee_id);

CREATE POLICY IF NOT EXISTS "Users can update assigned tasks"
  ON public.tasks FOR UPDATE
  USING (auth.uid() = assignee_id);
