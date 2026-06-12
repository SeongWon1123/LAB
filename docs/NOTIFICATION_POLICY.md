# Notification Policy

## Scope

MVP uses local notifications only. No push server is allowed.

## Permission

Show an explanation before requesting permission. If the user declines, the app remains fully usable.

## Limits

- Maximum three reminders per day.
- Quiet hours: 22:00 to 08:00.
- Reminder candidate hours: 09:00, 14:00, and 19:00 local time.
- Do not use Android exact alarm permissions.
- Use `AndroidScheduleMode.inexactAllowWhileIdle` for Android reminder scheduling.

## Scheduling

When reminders are enabled, the app cancels existing local reminders and schedules the next two days of care reminders. Past candidate times for the current day are skipped. If the user turns reminders off, all local reminders are cancelled.

## Message Drafts

- Hunger: `작은 친구가 배고픈 것 같아요.`
- Clean: `방이 조금 지저분해졌어요.`
- Sleep: `이제 불을 꺼줄 시간이래요.`
- Play: `작은 친구가 심심해 보여요.`
