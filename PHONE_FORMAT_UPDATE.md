# Philippines Phone Number Format Update

## ✅ Changes Applied

Updated both backend and frontend to **only accept Philippines mobile phone format**.

---

## 📱 Accepted Formats

### Valid Formats:
- ✅ `09171234567` (11 digits, starts with 09)
- ✅ `+639171234567` (13 characters, starts with +639)

### Examples by Network:
- **Globe**: `09171234567` or `+639171234567`
- **Smart**: `09181234567` or `+639181234567`  
- **Sun**: `09321234567` or `+639321234567`
- **TM**: `09511234567` or `+639511234567`
- **TNT**: `09061234567` or `+639061234567`

### Invalid Formats:
- ❌ `9171234567` (missing leading 0 or +63)
- ❌ `0917-123-4567` (contains dashes)
- ❌ `0917 123 4567` (contains spaces)
- ❌ `(0917) 123-4567` (contains formatting)
- ❌ `08171234567` (doesn't start with 9)
- ❌ `09171234` (too short)

---

## 🎨 Visual Improvements

### Contact Number Field Now Shows:

**Label:**
```
Contact Number
```

**Format Hint (above field):**
```
Format: 09XXXXXXXXX or +639XXXXXXXXX
```

**Placeholder Text (inside field):**
```
e.g., 09171234567
```

**Helper Text (below field):**
```
Philippines mobile number
```

**Error Message (if invalid):**
```
Invalid format. Use 09XXXXXXXXX or +639XXXXXXXXX
```

---

## 🔧 Technical Details

### Backend Validation (Express Validator)
```javascript
body('contactNumber')
  .optional()
  .isString()
  .trim()
  .matches(/^(\+63|0)9\d{9}$/)
  .withMessage('Please provide a valid Philippines phone number (e.g., 09171234567 or +639171234567)')
```

### Frontend Validation (Dart/Flutter)
```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your contact number';
  }
  // Philippines phone format: 09XXXXXXXXX or +639XXXXXXXXX
  if (!RegExp(r'^(\+63|0)9\d{9}$').hasMatch(value)) {
    return 'Invalid format. Use 09XXXXXXXXX or +639XXXXXXXXX';
  }
  return null;
}
```

### Regex Pattern Breakdown:
```
^(\+63|0)9\d{9}$

^           - Start of string
(\+63|0)    - Either "+63" or "0"
9           - Must have "9" after prefix
\d{9}       - Exactly 9 more digits
$           - End of string

Total: 11 digits (09XXXXXXXXX) or 13 chars (+639XXXXXXXXX)
```

---

## 🚀 How to Apply Changes

### 1. Restart Backend Server
```bash
# Stop current server (Ctrl+C)
cd backend
npm start
```

### 2. Hot Restart Flutter App
Press `R` in the Flutter terminal

---

## 🧪 Testing

### Test Cases:

1. **Valid Numbers:**
   - Input: `09171234567` → ✅ Pass
   - Input: `+639171234567` → ✅ Pass
   - Input: `09181234567` → ✅ Pass

2. **Invalid Numbers:**
   - Input: `9171234567` → ❌ Error: "Invalid format. Use 09XXXXXXXXX or +639XXXXXXXXX"
   - Input: `0917-123-4567` → ❌ Error shown
   - Input: `08171234567` → ❌ Error shown (doesn't start with 9)
   - Input: `09171234` → ❌ Error shown (too short)

3. **Edge Cases:**
   - Empty field → ❌ "Please enter your contact number"
   - Letters → ❌ "Invalid format..."
   - Special characters → ❌ "Invalid format..."

---

## 📋 Affected Files

### Backend:
- `backend/src/validators/authValidator.js`
  - Updated `signUpValidation` - contactNumber field
  - Updated `signUpValidation` - phone field
  - Updated `updateProfileValidation` - phone field

### Frontend:
- `frontend/lib/presentation/screens/signup_screen.dart`
  - Added format hint text above field
  - Updated placeholder text
  - Added helper text below field
  - Updated validator regex

---

## ✨ User Experience

### Before:
- Generic hint: "Enter your contact number"
- No format guidance
- Unclear what format is expected
- Could enter any format, get confusing errors

### After:
- Clear format shown: "Format: 09XXXXXXXXX or +639XXXXXXXXX"
- Example in placeholder: "e.g., 09171234567"
- Helper text: "Philippines mobile number"
- Specific error messages
- Consistent validation frontend ↔️ backend

---

## 🎯 Summary

✅ Only accepts Philippines mobile format  
✅ Clear visual hints for users  
✅ Consistent validation (frontend & backend)  
✅ Helpful error messages  
✅ Works for all major PH networks  

Users now have clear guidance on exactly what format to use! 🇵🇭

---

Generated: 2025-11-05
