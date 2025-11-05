# Supabase Database Setup Guide

## 📊 Overview

Your user data is now stored in **TWO places** in Supabase:

1. **Auth User Metadata** - Basic auth info (automatically handled)
2. **Users Table** - Full profile data in database (queryable)

---

## 🔧 Setup Steps

### Step 1: Create Users Table in Supabase

1. **Go to Supabase Dashboard**
   - Visit: https://app.supabase.com
   - Select your project: `yngnfuqpoheigijocjxk`

2. **Open SQL Editor**
   - Click on **"SQL Editor"** in left sidebar
   - Click **"New query"**

3. **Copy and Paste the SQL**
   - Open file: `backend/database/create_users_table.sql`
   - Copy ALL the SQL code
   - Paste into Supabase SQL Editor

4. **Run the Query**
   - Click **"Run"** button (or press Ctrl+Enter)
   - Wait for success message: ✅ Success. No rows returned

---

## 📋 What Gets Created

### 1. **Users Table Structure:**
```sql
public.users
├── id (UUID) - Links to auth.users
├── email (TEXT) - User's email
├── full_name (TEXT) - Full name
├── contact_number (TEXT) - Philippines phone number
├── age (INTEGER) - User's age
├── created_at (TIMESTAMP) - When record created
└── updated_at (TIMESTAMP) - Last update time
```

### 2. **Security Policies (RLS):**
- ✅ Users can **view** their own profile
- ✅ Users can **update** their own profile
- ✅ System can **insert** during signup

### 3. **Automatic Features:**
- ✅ `updated_at` automatically updates on changes
- ✅ Cascading delete (if auth user deleted, profile deleted)
- ✅ Indexes for better query performance

---

## 💾 How Data is Stored

### When a User Signs Up:

**Step 1: Auth User Created**
```
auth.users
├── id: abc123...
├── email: user@example.com
├── user_metadata:
    ├── full_name: "John Doe"
    ├── contact_number: "09171234567"
    └── age: "25"
```

**Step 2: Profile Record Created**
```
public.users
├── id: abc123... (same as auth.users)
├── email: user@example.com
├── full_name: John Doe
├── contact_number: 09171234567
├── age: 25
├── created_at: 2025-11-05 13:10:00
└── updated_at: 2025-11-05 13:10:00
```

---

## 🔍 Verify Data Storage

### Check Auth Users:
1. Go to **Authentication** → **Users** in Supabase
2. You'll see users with their email and metadata

### Check Database Table:
1. Go to **Table Editor** in Supabase
2. Select **users** table
3. You'll see all user profiles

### Test Query:
```sql
-- View all users with their data
SELECT 
  id,
  email,
  full_name,
  contact_number,
  age,
  created_at
FROM public.users
ORDER BY created_at DESC;
```

---

## 🧪 Test the Setup

### 1. Run the SQL Setup
- Execute the SQL in Supabase SQL Editor

### 2. Restart Backend (auto-restart with nodemon)
Backend should already be running and will pick up changes automatically.

### 3. Test Sign Up
In your Flutter app:
1. Fill in sign up form
2. Click Sign Up
3. Watch backend terminal:
   ```
   📥 SIGNUP REQUEST RECEIVED
   ✅ Validation Passed - Processing signup...
   ✅ USER CREATED SUCCESSFULLY
   ```

### 4. Verify in Supabase
**Check Auth:**
- Go to Authentication → Users
- New user should appear

**Check Database:**
- Go to Table Editor → users
- New profile record should appear with all data

---

## 📊 Query Examples

### Get User Profile by Email:
```sql
SELECT * FROM users WHERE email = 'user@example.com';
```

### Count Total Users:
```sql
SELECT COUNT(*) FROM users;
```

### Get Recent Signups:
```sql
SELECT 
  full_name,
  email,
  contact_number,
  created_at
FROM users
ORDER BY created_at DESC
LIMIT 10;
```

### Search by Contact Number:
```sql
SELECT * FROM users WHERE contact_number = '09171234567';
```

---

## 🔐 Security Features

### Row Level Security (RLS) Enabled
- Users can ONLY see/edit their own profile
- API requests require valid JWT token
- Database enforces security at row level

### Example Protected Access:
```javascript
// User can only query their own data
const { data } = await supabase
  .from('users')
  .select('*')
  .eq('id', user.id);  // Must match authenticated user
```

---

## 🎯 Benefits

### 1. **Dual Storage:**
- ✅ Auth metadata for quick access
- ✅ Database table for complex queries

### 2. **Easy Queries:**
- ✅ Search users by any field
- ✅ Get user statistics
- ✅ Filter and sort users

### 3. **Data Integrity:**
- ✅ Foreign key to auth.users
- ✅ Automatic cascade delete
- ✅ Timestamps tracked

### 4. **Scalable:**
- ✅ Indexed for performance
- ✅ Can add more fields easily
- ✅ RLS for security

---

## ✅ Summary

After running the SQL setup:

✅ **Users Table Created** in Supabase  
✅ **Security Policies Set** (RLS enabled)  
✅ **Backend Updated** to store in both places  
✅ **All signup data stored** in database  
✅ **Automatic timestamps** tracked  

**Next Step:** Run the SQL in Supabase SQL Editor to create the table! 🚀

---

Generated: 2025-11-05
