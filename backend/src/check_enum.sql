-- Check what values are allowed by the notification_type enum
SELECT unnest(enum_range(NULL::notification_type));
