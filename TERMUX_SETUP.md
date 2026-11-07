# Termux Setup - Same Device Testing

## Termux Backend Testing

### 1. Termux Install karo
- F-Droid se Termux download karo (Play Store wala outdated hai)
- https://f-droid.org/en/packages/com.termux/

### 2. Termux Setup

```bash
# Update packages
pkg update && pkg upgrade

# Install required packages
pkg install python git

```

### 3. Repository Clone karo

```bash
cd ~
git clone https://github.com/Mrsultan7890/Noor.git
cd Noor
```

### 4. Backend Start karo (Termux mein)

```bash
cd backend
pip install -r requirements.txt
cp .env.example .env
# .env mein apna TURSO_DATABASE_URL, TURSO_AUTH_TOKEN aur SECRET_KEY set karo
python main.py
```

Backend `http://127.0.0.1:8000` pe run hoga

### 5. Flutter App Run karo (Dusre terminal ya Android Studio se)

The Android app only accepts HTTPS API endpoints so login credentials and
account traffic are not sent over cleartext HTTP. Use the deployed HTTPS API
for app testing, or put a local backend behind a trusted HTTPS development
tunnel and pass its URL with `--dart-define=API_BASE_URL=https://...`.

### 6. Test karo

- Backend: `http://127.0.0.1:8000/docs`
- App se Register/Login karo
- Profile aur Leaderboard check karo

## Configuration

### Backend (main.py)
```python
host="127.0.0.1"  # Localhost only
```

### Frontend (API endpoint)
```dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://noor-api-cse6.onrender.com',
);
```

## Troubleshooting

### Backend nahi chal raha?
```bash
# Port check karo
netstat -tuln | grep 8000

# Backend logs dekho
cd backend
python main.py
```

### App connect nahi ho raha?
1. Backend running hai check karo
2. Verify the HTTPS endpoint is reachable from the phone.
3. Run with `flutter run --dart-define=API_BASE_URL=https://your-https-api.example`

### Termux mein Flutter install karne ke liye
```bash
pkg install wget
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
tar xf flutter_linux_3.16.0-stable.tar.xz
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor
```

## Production Deployment

Production ke liye:

**Backend**: Render pe deploy karo
**Frontend**: Set an HTTPS API endpoint using `--dart-define=API_BASE_URL=...`

```dart
flutter run --dart-define=API_BASE_URL=https://noor-api-cse6.onrender.com
```

## Notes

- ✅ Backend can be tested locally from the phone browser
- ✅ App login testing uses HTTPS to protect account traffic
- - ✅ Account and activity data are persisted in Turso.
- ✅ Production ke liye Turso + Render use karo
