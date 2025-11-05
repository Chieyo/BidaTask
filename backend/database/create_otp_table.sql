-- Create OTP storage table in Supabase
-- Run this SQL in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS public.otp_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  contact_number TEXT NOT NULL,
  otp_code TEXT NOT NULL,
  is_verified BOOLEAN DEFAULT FALSE,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS otp_codes_user_id_idx ON public.otp_codes(user_id);
CREATE INDEX IF NOT EXISTS otp_codes_expires_at_idx ON public.otp_codes(expires_at);

-- Enable RLS
ALTER TABLE public.otp_codes ENABLE ROW LEVEL SECURITY;

-- RLS Policies
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'otp_codes' AND policyname = 'Users can view own OTP codes'
  ) THEN
    CREATE POLICY "Users can view own OTP codes"
      ON public.otp_codes
      FOR SELECT
      USING ((SELECT auth.uid()) = user_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'otp_codes' AND policyname = 'Users can insert own OTP codes'
  ) THEN
    CREATE POLICY "Users can insert own OTP codes"
      ON public.otp_codes
      FOR INSERT
      WITH CHECK ((SELECT auth.uid()) = user_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'otp_codes' AND policyname = 'Users can update own OTP codes'
  ) THEN
    CREATE POLICY "Users can update own OTP codes"
      ON public.otp_codes
      FOR UPDATE
      USING ((SELECT auth.uid()) = user_id);
  END IF;
END $$;

COMMENT ON TABLE public.otp_codes IS 'Stores OTP codes for phone number verification';
