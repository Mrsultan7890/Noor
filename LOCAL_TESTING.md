# Local Testing Setup

## Phone se App Test Karne ke liye

### 1. Backend Start karo (Laptop pe)

```bash
cd backend
pip install -r requirements.txt
python main.py
```

Backend `http://0.0.0.0:8000` pe run hoga (all network interfaces)

### 2. Laptop ka IP Address check karo

```bash
# Linux/Mac
hostname -I | awk '{print $1}'

# Windows
ipconfig
```

**Current IP**: `192.168.91.129`

### 3. Flutter App mein IP update karo

File: `lib/services/api_service.dart`

```dart
static const String baseUrl = 'http://192.168.91.129:8000'; // Local testing
```

### 4. Phone aur Laptop same WiFi pe hone chahiye

- Dono devices same network pe connect hone chahiye
- Firewall backend port 8000 allow kare

### 5. App build aur run karo

```bash
flutter run
```

### 6. Test karo

- Register/Login try karo
- Profile check karo
- Leaderboard dekho

## Production Deployment

Production ke liye:

```dart
static const String baseUrl = 'https://noor-api.onrender.com'; // Production
```

## Troubleshooting

### Connection refused error?

1. Backend running hai check karo: `http://192.168.91.129:8000/docs`
2. Firewall port 8000 allow karo
3. Same WiFi pe hai confirm karo
4. IP address sahi hai check karo

### Backend logs dekho

```bash
cd backend
python main.py
```

Logs mein requests dikhni chahiye jab app API call kare.

## API Endpoints

- Health: `http://192.168.91.129:8000/health`
- Docs: `http://192.168.91.129:8000/docs`
- Register: `POST /auth/register`
- Login: `POST /auth/login`
- Profile: `GET /users/me`
- Leaderboard: `GET /leaderboard/global`
