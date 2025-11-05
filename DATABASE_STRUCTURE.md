# Database Structure - Why Password is NOT in Users Table

## 🔐 Important: Password Storage

**Passwords are stored SECURELY in `auth.users` by Supabase, NOT in your custom `users` table.**

---

## 📊 Two Tables Explained

### 1. `auth.users` (Managed by Supabase)
**Purpose:** Authentication & Security

```sql
auth.users
├── id (UUID) - User ID
├── email - Email address
├── encrypted_password - HASHED password (secure)
├── email_confirmed_at - Email verification
├── created_at - Account creation
├── user_metadata - Custom data (JSON)
└── ... (other auth fields)
```

**Key Points:**
- ✅ Password is **encrypted/hashed** - NEVER stored in plain text
- ✅ Supabase manages security automatically
- ✅ Includes built-in password reset, email verification
- ❌ You should NEVER try to store passwords elsewhere

---

### 2. `public.users` (Your Custom Table)
**Purpose:** User Profile Data (queryable)

```sql
public.users
├── user_id (UUID) - Links to auth.users(id)
├── email (TEXT, NOT NULL) - User email
├── full_name (TEXT, NOT NULL) - Full name
├── contact_number (TEXT, NOT NULL) - Phone
├── age (INTEGER, NOT NULL) - Age
├── created_at (TIMESTAMP, NOT NULL) - When created
└── updated_at (TIMESTAMP, NOT NULL) - Last update
```

**Key Points:**
- ✅ All fields are REQUIRED (NOT NULL)
- ✅ Easy to query and search
- ✅ Can add more fields anytime
- ❌ Does NOT store password (for security)

---

## 🔄 How They Work Together

### Sign Up Flow:

```
1. User submits signup form
   ↓
2. Frontend sends to Backend:
   - email
   - password (secure transmission)
   - fullName
   - contactNumber
   - age
   ↓
3. Backend → Supabase Auth:
   Creates auth.users record
   ├── Stores email
   ├── HASHES password (secure)
   └── Stores metadata
   ↓
4. Backend → Database:
   Creates public.users record
   ├── user_id (from auth.users)
   ├── email
   ├── full_name
   ├── contact_number
   └── age
   ↓
5. ✅ User created successfully!
```

### Sign In Flow:

```
1. User enters email + password
   ↓
2. Backend → Supabase Auth:
   Checks auth.users
   ├── Verifies email exists
   ├── Compares hashed password
   └── Returns JWT token if valid
   ↓
3. Backend → Database:
   Fetches profile from public.users
   ├── Gets full_name
   ├── Gets contact_number
   └── Gets age
   ↓
4. ✅ Returns user data + token
```

---

## 🔒 Security Best Practices

### ✅ DO:
- Store passwords ONLY in `auth.users` (Supabase handles this)
- Use HTTPS for all API calls
- Hash/encrypt passwords before storing
- Use JWT tokens for authentication
- Enable Row Level Security (RLS)

### ❌ DON'T:
- Store plain text passwords ANYWHERE
- Store passwords in custom tables
- Log passwords to console
- Send passwords in URLs
- Store passwords in localStorage/cookies

---

## 🎯 Why This Structure?

### Separation of Concerns:
1. **`auth.users`** = Security & Authentication
   - Managed by Supabase
   - Industry-standard encryption
   - Built-in security features

2. **`public.users`** = Profile & Data
   - Managed by you
   - Easy queries and searches
   - Customizable fields

### Benefits:
- ✅ **Security:** Passwords handled by experts (Supabase)
- ✅ **Flexibility:** Easy to add profile fields
- ✅ **Performance:** Query profile data without touching auth
- ✅ **Compliance:** Meets security standards

---

## 📋 Updated Database Schema

### All Fields Now REQUIRED:

```sql
CREATE TABLE public.users (
  user_id UUID PRIMARY KEY,           -- ✅ REQUIRED
  email TEXT NOT NULL,                -- ✅ REQUIRED
  full_name TEXT NOT NULL,            -- ✅ REQUIRED
  contact_number TEXT NOT NULL,       -- ✅ REQUIRED
  age INTEGER NOT NULL,               -- ✅ REQUIRED
  created_at TIMESTAMP NOT NULL,      -- ✅ REQUIRED (auto)
  updated_at TIMESTAMP NOT NULL       -- ✅ REQUIRED (auto)
);
```

**Changes Made:**
- ✅ Renamed `id` → `user_id` for clarity
- ✅ Made all fields `NOT NULL` (required)
- ✅ Updated RLS policies to use `user_id`
- ✅ Backend validator requires all fields
- ✅ Frontend enforces required fields

---

## 🧪 Test Data Example

### When User Signs Up:

**Input:**
```json
{
  "email": "forchieanne@gmail.com",
  "password": "Chie@25",
  "fullName": "Forchieanne Valencia",
  "contactNumber": "09171308988",
  "age": "20"
}
```

**Result in `auth.users`:**
```sql
id: "abc-123-def-456"
email: "forchieanne@gmail.com"
encrypted_password: "$2a$10$..." -- HASHED!
user_metadata: {
  "full_name": "Forchieanne Valencia",
  "contact_number": "09171308988",
  "age": "20"
}
```

**Result in `public.users`:**
```sql
user_id: "abc-123-def-456"
email: "forchieanne@gmail.com"
full_name: "Forchieanne Valencia"
contact_number: "09171308988"
age: 20
created_at: "2025-11-05 13:20:00"
updated_at: "2025-11-05 13:20:00"
```

**Notice:** Password is ONLY in `auth.users` and HASHED! 🔒

---

## ✅ Summary

✅ **Password stored securely** in `auth.users` (hashed)  
✅ **Profile data stored** in `public.users` (queryable)  
✅ **All fields required** (NOT NULL)  
✅ **RLS policies protect** user data  
✅ **Backend validates** all required fields  

**Next Step:** Run the updated SQL in Supabase SQL Editor! 🚀

---

Generated: 2025-11-05
