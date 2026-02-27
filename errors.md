# Project Errors

## Status: ALL ISSUES RESOLVED ✅

The following 3 issues were found when running `flutter analyze`:

## Previously Found Issues (All Fixed)

### Error 1 - FIXED ✅
- **Type**: Error (was error)
- **Message**: The method 'signOut' isn't defined for the type 'Session'
- **File**: lib/features/auth/presentation/dashboard_screen.dart:118:38
- **Fix Applied**: Changed `_service.currentSession?.signOut()` to `Supabase.instance.client.auth.signOut()` and added the required import

### Error 2 - FIXED ✅
- **Type**: Error (was error)
- **Message**: The named parameter 'onSubmitted' isn't defined
- **File**: lib/features/auth/presentation/login_screen.dart:175:21
- **Fix Applied**: Removed invalid `onSubmitted` parameter from TextField

### Error 3 - FIXED ✅
- **Type**: info (was info/warning)
- **Message**: Don't use 'BuildContext's across async gaps
- **File**: lib/features/boq/presentation/boq_screen.dart (3 instances)
- **Fix Applied**: Added `mounted` checks before using BuildContext after async operations

---

## Current Status
✅ No issues found - flutter analyze passes successfully!

