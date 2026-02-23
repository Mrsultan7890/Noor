# 🏆 Points System - Complete Guide

## Points Earning Activities

### 1. Quran Reading - 10 Points
**Activity Type**: `quran_read`
**How to earn**: Complete reading a Surah
**Progress**: +0.88% Quran progress per Surah (114 Surahs = 100%)

### 2. Prayer Logged - 5 Points
**Activity Type**: `prayer_logged`
**How to earn**: Log a prayer in Prayer Times screen
**Progress**: Increments prayers_logged counter

### 3. Lesson Completed - 20 Points
**Activity Type**: `lesson_completed`
**How to earn**: Complete a learning module
**Progress**: Increments lessons_completed counter

### 4. Dua Memorized - 15 Points
**Activity Type**: `dua_memorized`
**How to earn**: Mark a Dua as memorized
**Progress**: Custom tracking

## Current Implementation Status

### ✅ Backend Ready
- `/users/activity` endpoint working
- Points calculation automatic
- Leaderboard updates real-time
- User stats tracking

### ❌ Frontend Integration Needed

#### 1. Quran Reader Integration
**File**: `lib/screens/quran/enhanced_quran_reader_screen.dart`

Add after completing Surah:
```dart
// After reading last ayah
if (currentAyah == totalAyahs) {
  await _logActivity('quran_read', 10, {
    'surah_number': widget.surah.number,
    'surah_name': widget.surah.englishName,
  });
}
```

#### 2. Prayer Times Integration
**File**: `lib/screens/prayer/prayer_times_screen.dart`

Already has `_logPrayer()` method, add API call:
```dart
Future<void> _logPrayer(String prayer) async {
  // Existing local logging...
  
  // Add backend logging
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  if (userProvider.isAuthenticated) {
    await userProvider.logActivity(
      activityType: 'prayer_logged',
      points: 5,
      metadata: {'prayer': prayer},
    );
  }
}
```

#### 3. Learning Modules Integration
**File**: `lib/screens/learning/arabic_alphabet_screen.dart`

Add after quiz completion:
```dart
// After quiz finished
if (score >= passingScore) {
  await _logActivity('lesson_completed', 20, {
    'lesson': 'Arabic Alphabet Quiz',
    'score': score,
  });
}
```

#### 4. Dua Screen Integration
**File**: `lib/screens/dua/dua_screen.dart`

Add memorize button:
```dart
IconButton(
  icon: Icon(isMemorized ? Icons.check_circle : Icons.circle_outlined),
  onPressed: () async {
    await _logActivity('dua_memorized', 15, {
      'dua_title': dua.title,
    });
  },
)
```

## Helper Method for All Screens

Add this to UserProvider:
```dart
Future<void> logActivity({
  required String activityType,
  required int points,
  Map<String, dynamic>? metadata,
}) async {
  if (!isAuthenticated || currentUser == null) return;
  
  try {
    await _apiService.logActivity(
      userId: currentUser!.id,
      activityType: activityType,
      points: points,
      metadata: metadata,
    );
    
    // Refresh profile to update points
    await loadProfile();
  } catch (e) {
    print('Failed to log activity: $e');
  }
}
```

## Testing Points System

### 1. Register/Login
```
Username: test_user
Email: test@temp.com
Password: 123456
```

### 2. Earn Points
- Read a Surah: +10 points
- Log a prayer: +5 points
- Complete quiz: +20 points
- Memorize dua: +15 points

### 3. Check Leaderboard
- Go to More → Leaderboard
- See your rank and points
- Compare with other users

### 4. View Profile
- Go to More → Profile
- See total points
- See activity stats
- See global rank

## Points Calculation Examples

**Daily Active User:**
- 5 prayers logged: 5 × 5 = 25 points
- 1 Surah read: 1 × 10 = 10 points
- 1 lesson completed: 1 × 20 = 20 points
- **Total**: 55 points/day

**Weekly Progress:**
- 55 points/day × 7 days = 385 points/week

**Monthly Progress:**
- 385 points/week × 4 weeks = 1,540 points/month

## Leaderboard Rankings

**Top Users:**
1. 🥇 Gold: Rank 1
2. 🥈 Silver: Rank 2
3. 🥉 Bronze: Rank 3
4. Regular: Rank 4+

## Future Enhancements

- [ ] Streak bonus (consecutive days)
- [ ] Achievement badges
- [ ] Weekly challenges
- [ ] Referral points
- [ ] Social sharing rewards
- [ ] Premium features unlock

## Backend API Endpoints

### Log Activity
```
POST /users/activity
Authorization: Bearer {token}

{
  "user_id": "uuid",
  "activity_type": "quran_read",
  "points": 10,
  "metadata": {"surah": 1}
}
```

### Get Profile
```
GET /users/me
Authorization: Bearer {token}

Response: {
  "points": 150,
  "quran_progress": 8.8,
  "prayers_logged": 25,
  "lessons_completed": 3
}
```

### Get Leaderboard
```
GET /leaderboard/global?limit=100

Response: [
  {
    "rank": 1,
    "username": "Abdullah",
    "country": "Pakistan",
    "points": 500
  }
]
```

## Notes

- Points are stored in backend (mock storage)
- Backend restart = data lost (use PocketBase for persistence)
- Frontend needs integration in 4 screens
- Real-time leaderboard updates
- Profile auto-refreshes after activity
