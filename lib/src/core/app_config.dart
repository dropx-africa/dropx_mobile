class AppConfig {
  static const env = String.fromEnvironment('APP_ENV');
  static const backendBaseUrl = String.fromEnvironment('BACKEND_BASE_URL');
  static const googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  static const cloudinaryCloudName = String.fromEnvironment('CLOUDINARY_CLOUD_NAME');
  static const cloudinaryUploadPreset = String.fromEnvironment('CLOUDINARY_UPLOAD_PRESET');
  static const enableCrashReporting = bool.fromEnvironment('ENABLE_CRASH_REPORTING');
  static const connectTimeout = int.fromEnvironment('CONNECT_TIMEOUT');
}
