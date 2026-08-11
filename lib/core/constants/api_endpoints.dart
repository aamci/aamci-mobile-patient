class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String resendVerification = '/auth/resend-verification';
  static const String deleteAccount = '/auth/account';

  // Search
  static const String searchDoctors = '/search/doctors';

  // Slots
  static String availableSlots(String doctorId) => '/slots/available/$doctorId';

  // Appointment Kinds
  static String appointmentKinds(String doctorId) => '/appointment-kinds/doctor/$doctorId';

  // Appointments
  static const String appointments = '/appointments';
  static String appointmentById(String id) => '/appointments/$id';
  static String appointmentStatus(String id) => '/appointments/$id/status';

  // Favorites
  static const String favorites = '/favorites';
  static String toggleFavorite(String doctorId) => '/favorites/$doctorId/toggle';
  static String checkFavorite(String doctorId) => '/favorites/check/$doctorId';

  // Notifications
  static const String notifications = '/notifications';
  static const String unreadCount = '/notifications/unread-count';
  static String markRead(String id) => '/notifications/$id/read';
  static const String markAllRead = '/notifications/mark-all-read';

  // Messages
  static const String conversations = '/messages/conversations';
  static String conversationMessages(String id) => '/messages/conversations/$id';
  static String markConversationRead(String id) => '/messages/conversations/$id/read';
  static const String sendMessage = '/messages/send';
  static const String unreadMessageCount = '/messages/unread-count';

  // User profile
  static const String profile = '/me';
  static const String changePassword = '/me/password';

  // Health Records
  static const String healthRecords = '/health-records/me';
  static const String vitals = '/health-records/me/vitals';
  static const String vaccinations = '/health-records/me/vaccinations';
  static const String labResults = '/health-records/me/lab-results';

  // Medical Documents
  static const String medicalDocuments = '/medical-documents';

  // Facilities
  static const String facilities = '/facilities';
  static String facilityById(String id) => '/facilities/$id';
  static String facilityDoctors(String id) => '/facilities/$id/doctors';

  // Reviews
  static String doctorReviews(String doctorId) => '/reviews/doctor/$doctorId';
  static const String reviews = '/reviews';

  // Insurance
  static const String insurance = '/me/insurance';

  // Emergency contacts
  static String emergencyContacts(String userId) => '/patient-record/$userId/emergency-contacts';
  static String emergencyContactById(String id) => '/patient-record/emergency-contacts/$id';

  // Invoices
  static const String invoices = '/invoices';

  // Consents
  static String patientConsents(String userId) => '/patient-record/$userId/consents';

  // Teleconsultation
  static String startVideo(String appointmentId) => '/appointments/$appointmentId/start-video';
  static String endVideo(String appointmentId) => '/appointments/$appointmentId/end-video';
}
