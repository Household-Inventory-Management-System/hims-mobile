# 🔒 Настройка Firebase конфигурации

## ⚠️ ВАЖНО: Настройка секретных файлов

Этот проект использует Firebase и требует настройки конфигурационных файлов с секретными данными.

### 📋 Инструкции по настройке:

#### 1. Firebase Options
1. Скопируйте `lib/firebase_options.template.dart` в `lib/firebase_options.dart`
2. Замените все плейсхолдеры `YOUR_*` на реальные данные из Firebase Console
3. Запустите `flutterfire configure` для автоматической генерации

#### 2. Google Services (Android)
1. Скопируйте `google-services.template.json` в:
   - `google-services.json` (корень проекта)
   - `android/app/google-services.json`
2. Замените плейсхолдеры на данные из Firebase Console
3. Или скачайте файл напрямую из Firebase Console

#### 3. Получение Firebase конфигурации
1. Перейдите в [Firebase Console](https://console.firebase.google.com/)
2. Выберите или создайте проект
3. Добавьте приложения для нужных платформ:
   - Android: `com.example.hims`
   - iOS: `com.example.hims`
   - Web: любой домен
4. Скачайте конфигурационные файлы
5. Замените шаблонные файлы реальными данными

#### 4. Google Sign-In настройка
1. В Firebase Console включите Authentication → Sign-in method → Google
2. Добавьте SHA1 fingerprint для Android:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey
   ```
3. Скачайте обновленный `google-services.json`

### 🚫 НЕ КОММИТЬТЕ эти файлы:
- `lib/firebase_options.dart`
- `google-services.json`
- `android/app/google-services.json` 
- `android/local.properties`

Они уже добавлены в `.gitignore` для безопасности.

### 🔧 Команды для настройки:
```bash
# Установить FlutterFire CLI
dart pub global activate flutterfire_cli

# Настроить Firebase автоматически
flutterfire configure

# Генерировать роуты
dart run build_runner build
```

### 📱 Запуск приложения:
```bash
flutter pub get
flutter run
```