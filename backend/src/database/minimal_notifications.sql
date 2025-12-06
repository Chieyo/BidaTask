-- Minimal notifications table creation
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  type VARCHAR(50) NOT NULL DEFAULT 'info',
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Test insert with valid type
INSERT INTO notifications (user_id, title, message, type, is_read) VALUES
(
  '620372f3-a444-447d-9346-c5843442e478',
  'Test Notification',
  'This is a test notification',
  'success', -- Try 'success' instead of 'info'
  false
);

-- Verify it worked
SELECT * FROM notifications LIMIT 1;
