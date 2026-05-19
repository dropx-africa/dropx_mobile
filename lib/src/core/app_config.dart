class AppConfig {
  // ENV
  static const env = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  // Backend
  static const backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'https://api-production-dcbb.up.railway.app',
  );

  // Google Maps
  static const googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyBW0zgD8_dIPtv9u2UWYM8vWgaIeIMM-Jk',
  );

  // Cloudinary
  static const cloudinaryCloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: 'dxcyytvmm',
  );

  static const cloudinaryUploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: 'flutter_unsigned_upload',
  );

  // Optional configs
  static const enableCrashReporting = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
    defaultValue: false,
  );

  static const connectTimeout = int.fromEnvironment(
    'CONNECT_TIMEOUT',
    defaultValue: 30000,
  );
}