# Google Play Data Safety Draft

## Current MVP Position

Pocket Memory Pet is local-first. It does not require an account and does not send pet data to a server.

## Data Collection

- Data collected: No.
- Data shared with third parties: No.
- Data encrypted in transit: Not applicable because the MVP does not transmit user data.
- Users can request data deletion: Not applicable to server data; local reset is available in Settings.

## On-Device Data

The following data is created and stored locally on the device:

- Pet name.
- Pet status values.
- Care event history.
- Diary entries.
- Sound and notification preferences.

This data is not uploaded by the MVP.

## Permissions

- Notifications: Optional local reminders on Android 13+ and iOS.

Not used:

- Location.
- Camera.
- Microphone.
- Contacts.
- Photos or videos.
- Advertising ID.
- Calendar.
- Files outside app storage.
- Exact alarm permission.

## Security Practices

- No account credentials.
- No backend service.
- No ads SDK.
- No analytics SDK.
- Local reminders are scheduled on-device.

## Store Form Notes

If future versions add cloud backup, analytics, crash reporting, ads, purchases, or account sync, this draft must be updated before release.
