# Network Connection Fix for Android Emulator

## ✅ Issue Fixed

**Problem:** `SocketException: Connection refused (errno = 111)`

**Cause:** Android emulator cannot access `localhost` from the host machine. In the emulator, `localhost` refers to the emulator itself, not your computer.

**Solution:** Use `10.0.2.2` instead of `localhost` to access the host machine's services.

---

## Changes Made

### Frontend Auth Service
```dart
// BEFORE
static const String baseUrl = 'http://localhost:3000/api/auth';

// AFTER
static const String baseUrl = 'http://10.0.2.2:3000/api/auth';
```

---

## Network Address Guide

| Device Type | Backend URL | Notes |
|-------------|-------------|-------|
| **Android Emulator** | `http://10.0.2.2:3000` | Special IP to reach host machine |
| **iOS Simulator** | `http://localhost:3000` | Can use localhost directly |
| **Physical Device** | `http://192.168.x.x:3000` | Use your computer's actual IP address |
| **Web** | `http://localhost:3000` | Can use localhost directly |

---

## Testing Steps

### 1. Ensure Backend is Running
The backend is currently running on port 3000 ✅

To verify:
```bash
# In a browser or new terminal
curl http://localhost:3000/health
```

Should return:
```json
{"status":"OK","message":"BidaTask API is running","timestamp":"..."}
```

### 2. Restart Backend (IMPORTANT!)
The backend server needs to be restarted to apply the auth service changes from earlier:

```bash
# In your backend terminal
# Press Ctrl+C to stop
# Then restart:
cd backend
npm run dev
```

### 3. Hot Restart Flutter App
```bash
# In your Flutter terminal
# Press R (capital R for full restart)
R
```

### 4. Test Sign Up
1. Fill in all fields on sign up screen:
   - Full Name: Test User
   - Email: test123@example.com
   - Contact: 1234567890
   - Age: 25
   - Password: Test123
   - Confirm: Test123
   - ✅ Accept terms

2. Click "Sign Up"

3. Should now connect successfully! ✅

---

## Expected Result

### Success Response
```
✅ Green SnackBar: "User created successfully"
✅ Navigates to onboarding screen
✅ User appears in Supabase Auth dashboard
```

### Validation Errors (if any)
Backend will return specific errors like:
- "Password must contain at least one lowercase letter, one uppercase letter, and one number"
- "Email already registered"
- "Full name must be between 2 and 50 characters"

---

## Troubleshooting

### Still getting connection error?

1. **Check backend is running:**
   ```bash
   Get-NetTCPConnection -LocalPort 3000
   ```

2. **Restart backend server:**
   - Press Ctrl+C in backend terminal
   - Run `npm run dev` again

3. **Check Windows Firewall:**
   - Ensure Node.js is allowed through firewall
   - Allow port 3000 for private networks

4. **Full restart:**
   - Stop backend (Ctrl+C)
   - Stop Flutter (q in terminal)
   - Start backend: `npm run dev`
   - Start Flutter: `flutter run`

### For Physical Device Testing

If testing on a real phone connected to same WiFi:

1. Find your computer's IP:
   ```powershell
   ipconfig
   # Look for IPv4 Address under your WiFi adapter
   # Example: 192.168.1.100
   ```

2. Update auth_service.dart:
   ```dart
   static const String baseUrl = 'http://192.168.1.100:3000/api/auth';
   ```

3. Ensure backend .env FRONTEND_URL includes your IP:
   ```
   FRONTEND_URL=http://192.168.1.100:5173
   ```

---

## Summary

✅ **Frontend URL updated** to use `10.0.2.2` for Android emulator  
⚠️ **Backend restart required** to apply auth service changes  
✅ **Backend is running** on port 3000  
✅ **Next step:** Restart backend, then test sign up flow

---

Generated: 2025-11-05
