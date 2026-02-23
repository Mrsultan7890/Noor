# Termux Setup - Same Device Testing

## Phone pe Backend aur Frontend dono chalao

### 1. Termux Install karo
- F-Droid se Termux download karo (Play Store wala outdated hai)
- https://f-droid.org/en/packages/com.termux/

### 2. Termux Setup

```bash
# Update packages
pkg update && pkg upgrade

# Install required packages
pkg install python git

# Install pip packages
pip install fastapi uvicorn python-dotenv pydantic python-jose passlib httpx
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
python main.py
```

Backend `http://127.0.0.1:8000` pe run hoga

### 5. Flutter App Run karo (Dusre terminal ya Android Studio se)

```bash
# Agar Termux mein Flutter hai
cd ~/Noor
flutter run

# Ya Android Studio se run karo
```

### 6. Test karo

- Backend: `http://127.0.0.1:8000/docs`
- App se Register/Login karo
- Profile aur Leaderboard check karo

## Configuration

### Backend (main.py)
```python
host="127.0.0.1"  # Localhost only
```

### Frontend (api_service.dart)
```dart
static const String baseUrl = 'http://127.0.0.1:8000';
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
2. Browser mein `http://127.0.0.1:8000/docs` kholo
3. App rebuild karo: `flutter clean && flutter run`

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
**Frontend**: `api_service.dart` mein production URL uncomment karo

```dart
static const String baseUrl = 'https://noor-api.onrender.com';
```

## Notes

- ✅ Same device pe testing fast hai
- ✅ Network issues nahi honge
- ✅ Backend restart pe data clear hoga (mock storage)
- ✅ Production ke liye PocketBase + Render use karo
