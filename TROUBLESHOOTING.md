# Troubleshooting: Database Error Saving New User

## 🔍 Diagnosing the Issue

When you see "Database error saving new user", check the backend terminal for detailed error information.

---

## 🎯 Most Common Causes

### 1. **Table Doesn't Exist Yet** ⚠️ MOST LIKELY

**Error Message:**
```
Code: 42P01
Message: relation "public.users" does not exist
```

**Solution:**
✅ **Run the SQL to create the table!**

**Steps:**
1. Go to https://app.supabase.com
2. Select your project
3. Click **"SQL Editor"** in left sidebar
4. Click **"New query"**
5. Copy ALL SQL from: `backend/database/create_users_table.sql`
6. Paste into Supabase SQL Editor
7. Click **"Run"** (or Ctrl+Enter)
8. Wait for: ✅ Success message

---

### 2. **Missing Required Field**

**Error Message:**
```
Code: 23502
Message: null value in column "contact_number" violates not-null constraint
```

**Solution:**
- All fields are now REQUIRED
- Make sure frontend sends: fullName, contactNumber, age
- Check backend validator requires all fields

---

### 3. **Age Not a Number**

**Error Message:**
```
Code: 22P02
Message: invalid input syntax for type integer
```

**Solution:**
- Age must be a valid number
- Check: `parseInt(userData.age)` works
- Frontend should validate age is numeric

---

### 4. **Row Level Security Blocking**

**Error Message:**
```
Code: 42501
Message: new row violates row-level security policy
```

**Solution:**
Check the INSERT policy exists:
```sql
CREATE POLICY "Enable insert for authenticated users"
  ON public.users
  FOR INSERT
  WITH CHECK (true);
```

This should be in the SQL file already.

---

## 🧪 Debug Steps

### Step 1: Check Backend Terminal

After clicking Sign Up, look for:

```
📥 SIGNUP REQUEST RECEIVED
====================================
Request Body: { ... }
====================================

✅ Validation Passed - Processing signup...
   Email: user@example.com
   Full Name: John Doe
   Contact: 09171234567
   Age: 25

📝 Inserting user into database table...
Insert data: {
  "user_id": "abc-123...",
  "email": "user@example.com",
  "full_name": "John Doe",
  "contact_number": "09171234567",
  "age": 25
}

❌ Database Insert Error:
   Code: 42P01
   Message: relation "public.users" does not exist
   Details: ...
   Hint: ...
```

### Step 2: Check Supabase

1. **Go to Table Editor**
   - Do you see a `users` table?
   - If NO → Run the SQL!

2. **Go to SQL Editor**
   - Test query: `SELECT * FROM public.users;`
   - If error → Table doesn't exist, run SQL

### Step 3: Verify SQL Ran Successfully

After running SQL, check:

1. **Table Editor** → Should see `users` table
2. **Test query:**
   ```sql
   SELECT table_name 
   FROM information_schema.tables 
   WHERE table_schema = 'public' 
   AND table_name = 'users';
   ```
   Should return: `users`

---

## ✅ Solution Checklist

### Before Testing Signup:

- [ ] **SQL executed in Supabase** ✅
- [ ] **Table visible in Table Editor** ✅
- [ ] **Backend running** (`npm run dev`) ✅
- [ ] **Frontend hot restarted** (press `R`) ✅
- [ ] **All form fields filled** ✅
- [ ] **Password includes special character** ✅

### Test Signup:

1. Fill form:
   - Full Name: Your Name
   - Email: test@example.com
   - Contact: 09171234567
   - Age: 25
   - Password: Test@123
   - Confirm: Test@123
   - ✅ Accept terms

2. Click Sign Up

3. Watch backend terminal for detailed logs

---

## 📋 Expected Success Flow

```
📥 SIGNUP REQUEST RECEIVED
✅ Validation Passed - Processing signup...
📝 Inserting user into database table...
Insert data: { ... }
✅ User data inserted into database table
✅ USER CREATED SUCCESSFULLY
   User ID: abc123...
   Email: user@example.com
```

Then in Supabase:
- **Authentication → Users** → New user appears
- **Table Editor → users** → New profile record appears

---

## 🆘 Still Having Issues?

### Check Each Component:

1. **Supabase Credentials**
   - Backend `.env` has correct URL and keys
   - Frontend `.env` matches backend

2. **Network Connection**
   - Backend can reach Supabase
   - No firewall blocking

3. **Field Validation**
   - All required fields provided
   - Contact number matches format
   - Age is valid number

4. **Backend Logs**
   - Shows exact error code
   - Indicates which step failed

---

## 🎯 Quick Fix for Most Cases

**99% of the time, this error means:**

### ❌ You haven't run the SQL to create the table yet!

**Solution:**
1. Open Supabase Dashboard
2. Go to SQL Editor
3. Copy SQL from `create_users_table.sql`
4. Run it
5. Try signup again

✅ **Should work!**

---

Generated: 2025-11-05
