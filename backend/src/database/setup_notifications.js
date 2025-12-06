const supabase = require('../config/supabase');

async function setupNotificationsTable() {
  try {
    console.log('Creating notifications table...');

    // Create the notifications table
    const { error: tableError } = await supabase.rpc('exec_sql', {
      sql: `
        CREATE TABLE IF NOT EXISTS notifications (
          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
          task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
          title VARCHAR(255) NOT NULL,
          message TEXT NOT NULL,
          type VARCHAR(50) NOT NULL DEFAULT 'info',
          is_read BOOLEAN DEFAULT FALSE,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );

        -- Create indexes
        CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
        CREATE INDEX IF NOT EXISTS idx_notifications_user_id_created_at ON notifications(user_id, created_at DESC);
        CREATE INDEX IF NOT EXISTS idx_notifications_task_id ON notifications(task_id);

        -- Enable RLS
        ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

        -- Create RLS policies
        CREATE POLICY IF NOT EXISTS "Users can view own notifications" ON notifications
          FOR SELECT USING (auth.uid() = user_id);

        CREATE POLICY IF NOT EXISTS "Users can update own notifications" ON notifications
          FOR UPDATE USING (auth.uid() = user_id);

        CREATE POLICY IF NOT EXISTS "Users can delete own notifications" ON notifications
          FOR DELETE USING (auth.uid() = user_id);

        CREATE POLICY IF NOT EXISTS "System can insert notifications" ON notifications
          FOR INSERT WITH CHECK (true);

        -- Create trigger for updated_at
        CREATE OR REPLACE FUNCTION update_notifications_updated_at()
        RETURNS TRIGGER AS $$
        BEGIN
          NEW.updated_at = NOW();
          RETURN NEW;
        END;
        $$ LANGUAGE plpgsql;

        CREATE TRIGGER IF NOT EXISTS notifications_updated_at_trigger
          BEFORE UPDATE ON notifications
          FOR EACH ROW
          EXECUTE FUNCTION update_notifications_updated_at();
      `
    });

    if (tableError) {
      console.error('Error creating table:', tableError);
      return;
    }

    console.log('Notifications table created successfully!');

    // Test by inserting a sample notification
    console.log('Testing with sample notification...');
    const { data: testNotification, error: insertError } = await supabase
      .from('notifications')
      .insert({
        user_id: '620372f3-a444-447d-9346-c5843442e478', // Replace with actual user ID
        title: 'Test Notification',
        message: 'This is a test notification to verify the table works',
        type: 'info',
        is_read: false
      })
      .select()
      .single();

    if (insertError) {
      console.error('Error inserting test notification:', insertError);
    } else {
      console.log('Test notification created:', testNotification);
    }

  } catch (error) {
    console.error('Setup error:', error);
  }
}

// Run the setup
setupNotificationsTable()
  .then(() => {
    console.log('Setup completed!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('Setup failed:', error);
    process.exit(1);
  });
