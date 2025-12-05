-- Simple direct update function
CREATE OR REPLACE FUNCTION direct_update_task(task_id_param UUID, user_id_param UUID)
RETURNS BOOLEAN AS $$
BEGIN
    -- Update the task and return success status
    UPDATE tasks 
    SET assignee_id = user_id_param, updated_at = NOW()
    WHERE id = task_id_param AND assignee_id IS NULL;
    
    -- Return true if any row was updated
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;
