-- Create stored procedure for accepting tasks
CREATE OR REPLACE FUNCTION accept_task(task_id UUID, user_id UUID)
RETURNS TABLE (
  id UUID,
  task_title TEXT,
  assignee_id UUID,
  requester_id UUID,
  task_status TEXT
) AS $$
BEGIN
    -- Update the task only if it's not already taken
    UPDATE tasks 
    SET assignee_id = user_id, updated_at = NOW()
    WHERE id = task_id AND assignee_id IS NULL
    RETURNING id, task_title, assignee_id, requester_id, task_status;
END;
$$ LANGUAGE plpgsql;
