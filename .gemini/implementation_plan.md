# Full Project Cleanup & Optimization Plan

## Dead Files to Remove:
1. `lib/data/course_notes_data.dart` - Not imported anywhere
2. `lib/models/review.dart` - Not imported anywhere  
3. `lib/services/theme_provider.dart` - Empty file (real one is in core/)
4. `lib/seeding/` - Entire directory (13 files) - No longer imported

## Files to Fix:
1. `main.dart` - Already fixed with timeout loading
2. `auth_service.dart` - Already improved with error handling
3. `teacher_dashboard_screen.dart` - Fix dark mode issues, hardcoded colors
4. `profile_screen.dart` - Fix hardcoded colors, improve UI
5. `verification_pending_screen.dart` - Fix hardcoded white background
6. `home_screen.dart` - Add comments throughout
7. All screens - Add proper error handling with return-to-login

## Status: EXECUTING
