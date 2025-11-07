import UserNotifications
import OSLog

enum NotificationDispatcher {
    private static let logger = Logger(subsystem: "com.rnsloan.PureClip", category: "Notification")

    static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                DispatchQueue.main.async { completion(true) }
            case .denied:
                DispatchQueue.main.async { completion(false) }
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound]) { granted, error in
                    if let error = error {
                        logger.error("Notification authorization request failed: \(error.localizedDescription)")
                    }
                    DispatchQueue.main.async { completion(granted) }
                }
            @unknown default:
                DispatchQueue.main.async { completion(false) }
            }
        }
    }

    static func postCleanSuccessNotification() {
        guard UserDefaults.standard.bool(forKey: UserDefaults.Keys.showNotification) else { return }

        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            let authorised: Bool
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                authorised = true
            default:
                authorised = false
            }

            guard authorised else {
                logger.debug("Skipping notification because authorization is not granted")
                return
            }

            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("notification.clean.title", comment: "Notification title when clipboard cleaned")
            content.body = NSLocalizedString("notification.clean.body", comment: "Notification body when clipboard cleaned")
            content.sound = .default

            let request = UNNotificationRequest(
                identifier: "com.rnsloan.PureClip.notifications.cleanSuccess",
                content: content,
                trigger: nil
            )

            center.add(request) { error in
                if let error = error {
                    logger.error("Failed to post notification: \(error.localizedDescription)")
                }
            }
        }
    }
}
