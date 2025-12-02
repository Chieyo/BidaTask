CREATE TABLE IF NOT EXISTS public.tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  requester_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  task_title TEXT NOT NULL,
  task_description TEXT,
  reward DECIMAL(10, 2) NOT NULL,
  task_category TEXT NOT NULL,
  task_priority TEXT NOT NULL,

  due_date TIMESTAMP WITH TIME ZONE NOT NULL,
  location GEOGRAPHY(Point, 4326),
  location_name TEXT,
  task_status TEXT DEFAULT 'todo',

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Enable Row Level Security
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

-- Create policies for task access
CREATE POLICY "Users can view their own tasks"
  ON public.tasks FOR SELECT
  USING (auth.uid() = requester_id);

CREATE POLICY "Users can insert their own tasks"
  ON public.tasks FOR INSERT
  WITH CHECK (auth.uid() = requester_id);