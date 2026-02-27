# BOQ SaaS Fix Plan

## Issues Identified:
1. AuthGate needs StreamBuilder for reactive auth state
2. Dashboard needs better loading states and error handling
3. Real-time project list using Supabase streams
4. Navigator const misuse fix
5. Proper session persistence

## Implementation Steps:

### Step 1: Update project_service.dart
- Add real-time stream support
- Add proper error handling
- Add user validation

### Step 2: Update dashboard_screen.dart
- Add StreamBuilder for real-time updates
- Add loading indicator during project creation
- Disable button during request
- Add success/error snackbars

### Step 3: Update auth_gate.dart
- Use StreamBuilder for reactive auth state
- Proper session handling

### Step 4: Update login_screen.dart
- Fix navigation after login
- Add proper session handling

