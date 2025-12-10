-- Fix RLS policies to allow backend service to insert notifications
DROP POLICY IF EXISTS "System can insert notifications" ON notifications;
CREATE POLICY "System can insert notifications" ON notifications
  FOR INSERT WITH CHECK (true);

-- Also allow the backend to bypass RLS for notifications
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;

-- Re-enable with proper policies
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
