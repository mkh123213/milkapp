# MilkApp Enhancement Phases

> Comprehensive enhancement plan for the Milk Collection Management App (دفتر الحليب)
> Generated: 2026-06-04

---

## Phase 1 — Critical Bug Fixes & Data Integrity

### 1.1 Fix Weekly Report Missing Records Calculation Bug

**File:** `lib/features/reports/data/data_source/reports_remote_data_source.dart`

**Problem:** The `missingCount` calculation is wrong. The code counts total raw entries as `recordedDays` but compares against `activeSupplierCount * 7`. If supplier S1 submitted 3 entries and S2 submitted 4 entries, `recordedDays = 7` but the expected is `2 * 7 = 14`. The missing count is then `14 - 7 = 7`, but it should account for unique `(supplierId, date)` pairs, not raw entry count.

**Fix:** Track `Set<(supplierId, dateKey)>` instead of counting documents. This ensures each supplier-day is counted once even if multiple entries exist.

**Impact:** HIGH — All weekly reports currently show incorrect missing-records statistics.

---

### 1.2 Fix Month Arithmetic Overflow in Supplier Details

**File:** `lib/features/suppliers/presentation/cubit/supplier_details_cubit.dart`

**Problem:** `DateTime(m.year, m.month - 3)` breaks for January/February/March. For example, January (`month = 1`) minus 3 = `-2`, which produces unexpected behavior in Dart's DateTime constructor.

**Fix:** Replace with `DateTime.now().subtract(Duration(days: 90))` or use proper month roll-back logic that handles year boundaries.

**Impact:** MEDIUM — Crashes or wrong data for suppliers viewed in Q1.

---

### 1.3 Prevent Duplicate Entries Per Supplier Per Day

**File:** `lib/features/today/presentation/cubit/weight_entry_cubit.dart`

**Problem:** No check prevents submitting two entries for the same supplier on the same day. The current code creates a new document each time without checking if one already exists for that `(supplierId, dateKey)` combination.

**Fix:**
- Query Firestore for existing entry with matching `supplierId` and `dateKey` before writing.
- If found, show error message to user asking them to edit the existing entry instead.
- Add a composite unique index on `(supplierId, dateKey)` in Firestore rules to enforce at backend level.

**Impact:** MEDIUM — Prevents duplicate data that corrupts reports and dashboard stats.

---

### 1.4 Enforce Weight Decimal Precision

**Files:** `lib/features/today/presentation/cubit/weight_entry_cubit.dart`, `lib/features/today/presentation/widgets/weight_entry_sheet.dart`

**Problem:** `maxWeightDecimals = 1` is defined in constants but never enforced. Users can submit weights like `123.456789` kg.

**Fix:**
- Add `inputFormatters` with `FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}'))` on the weight text field.
- Round submitted values to 1 decimal in the cubit before saving.

**Impact:** LOW — Data consistency for reporting.

---

### 1.5 Use Server Timestamps Instead of Device Time

**Files:** `lib/features/today/data/data_source/today_remote_data_source.dart`

**Problem:** `DateTime.now()` is used everywhere for entry timestamps. If the user's device clock is wrong, all entries get incorrect timestamps. This is especially problematic for determining which day an entry belongs to.

**Fix:**
- Use `FieldValue.serverTimestamp()` for `createdAt` and `updatedAt` fields in all Firestore writes.
- Keep `dateKey` derived from server date or validate device date against server time.

**Impact:** MEDIUM — Ensures data correctness regardless of device clock settings.

---

## Phase 2 — Authentication & Security Hardening

### 2.1 Implement Email Verification After Signup

**Files:** `lib/features/auth/data/data_source/auth_remote_data_source.dart`, new screen `lib/features/auth/presentation/screens/email_verification_screen.dart`

**Problem:** Users can sign up with any email (real or fake) without verification.

**Implementation:**
- After successful `createUserWithEmailAndPassword()`, call `currentUser?.sendEmailVerification()`.
- Add a new `EmailVerificationScreen` that shows a "check your inbox" message with a "Resend" button.
- In the router redirect, check `currentUser?.emailVerified` — if false, redirect to verification screen.
- Add a "Verify" button that calls `currentUser?.reload()` and checks the flag.

**Impact:** MEDIUM — Ensures valid contact emails for all users.

---

### 2.2 Strengthen Password Requirements

**File:** `lib/features/auth/presentation/cubit/signup_cubit.dart`

**Problem:** Only `password.length < 8` is validated. No complexity requirements.

**Implementation:**
- Add regex validation for at least: 1 uppercase, 1 lowercase, 1 digit, 1 special character.
- Show per-requirement checkmarks in the signup form (e.g., a small list of requirements with green/red indicators).
- Apply same validation on any future "change password" feature.

**Impact:** MEDIUM — Improves account security.

---

### 2.3 Remove or Implement Google Sign-In Button

**File:** `lib/features/auth/presentation/refactor/login_body.dart`

**Problem:** A Google Sign-In button exists with `onPressed: () {}` — it does nothing. Users see a non-functional button.

**Implementation (Option A — Implement):**
- Add `google_sign_in` and `firebase_auth` Google provider to the project.
- Implement `signInWithGoogle()` in `AuthRemoteDataSource`.
- Wire it through `AuthRepo` → `LoginCubit` → UI.

**Implementation (Option B — Remove):**
- Delete the Google Sign-In button from `login_body.dart` until ready to implement.
- Remove associated translation keys.

**Impact:** LOW — UX consistency. Non-functional buttons erode trust.

---

### 2.4 Add Session Timeout / Auto-Logout

**Problem:** Once logged in, users stay logged in indefinitely. No inactivity timeout exists.

**Implementation:**
- Create a `SessionManager` service that tracks last interaction time.
- After 30 minutes of inactivity, show a dialog warning the user.
- After 35 minutes, auto sign out and redirect to login.
- Reset timer on any user interaction (tap, scroll, text input).
- Store last activity time in SharedPreferences to survive app restarts.

**Impact:** MEDIUM — Important for shared devices.

---

### 2.5 Audit and Harden Firestore Security Rules

**Problem:** Firebase Security Rules are not visible in the codebase. Cannot verify that users can only access their own data.

**Implementation:**
- Export current Firestore rules from Firebase Console.
- Add `firestore.rules` file to the project root for version control.
- Ensure rules enforce:
  - Users can only read/write their own `users/{userId}` documents.
  - Suppliers, entries, and reports are scoped to the authenticated user's UID.
  - Validate data types and required fields at the rule level.
  - Prevent `editCount` from being decremented (server-side enforcement of one-edit limit).
- Add Firebase emulator tests for the rules.

**Impact:** CRITICAL — Without proper rules, any authenticated user could read/write any data.

---

### 2.6 Add Rate Limiting for Entry Submissions

**Problem:** Users can submit weight entries in rapid succession. No debouncing or throttling.

**Implementation:**
- Add debounce (2 seconds) on the submit button in `WeightEntrySheet`.
- In the cubit, ignore submissions if one is already in progress (`state.isSubmitting` guard).
- Optionally add Firestore rules that reject writes if the last write was < 1 second ago.

**Impact:** LOW — Prevents accidental double-submissions and potential abuse.

---

## Phase 3 — Offline Support & Data Sync

### 3.1 Implement Local Persistence Layer

**Problem:** The app has connectivity detection (banner) but no actual offline capability. When offline, Firestore writes silently fail or queue in Firestore SDK's internal cache without user feedback.

**Implementation:**
- Add `sqflite` or `hive` dependency for local storage.
- Create local data sources mirroring remote ones:
  ```
  lib/features/today/data/data_source/today_local_data_source.dart
  lib/features/suppliers/data/data_source/suppliers_local_data_source.dart
  ```
- Store all supplier data locally for offline access.
- Save weight entries to local DB first, then sync to Firestore.

**Impact:** HIGH — Core feature gap for field workers in areas with poor connectivity.

---

### 3.2 Build Sync Queue Manager

**Problem:** No mechanism to queue operations while offline and sync when connectivity returns.

**Implementation:**
- Create `lib/core/services/sync_queue_service.dart`:
  - Maintains a FIFO queue of pending operations (create entry, edit entry, mark no-milk).
  - Each operation has: `id`, `type`, `payload`, `status` (pending/syncing/failed/synced), `createdAt`, `retryCount`.
- On connectivity change (from `ConnectivityCubit`):
  - If online: process queue sequentially.
  - On success: mark synced, remove from queue.
  - On failure: increment retry count, backoff.
  - After 5 failures: mark as failed, notify user.
- Show sync status indicator in the app bar (e.g., cloud icon with pending count).

**Impact:** HIGH — Ensures no data loss in the field.

---

### 3.3 Add Conflict Resolution Strategy

**Problem:** If two users (or the same user on two devices) enter weights for the same supplier on the same day concurrently, last-write-wins with no warning.

**Implementation:**
- Before writing an entry, check if one already exists for that `(supplierId, dateKey)`.
- If found, compare timestamps:
  - If the existing entry is newer, show a conflict dialog with both values.
  - Let the user choose which to keep or merge (sum/average).
- Use Firestore transactions for atomic read-check-write.

**Impact:** MEDIUM — Prevents silent data overwrite in multi-device scenarios.

---

### 3.4 Optimize Firestore Cache Settings

**Problem:** Default Firestore cache size may not be sufficient for large supplier lists.

**Implementation:**
- Configure Firestore persistence settings in `main.dart`:
  - Set cache size to 100MB (default is 40MB).
  - Enable `persistenceEnabled: true` explicitly.
- Add cache cleanup routine that removes entries older than 90 days from local cache.

**Impact:** LOW — Performance improvement for heavy users.

---

## Phase 4 — Dashboard & Analytics Enhancements

### 4.1 Fix Absence Streak Detection on Dashboard

**File:** `lib/features/dashboard/presentation/cubit/dashboard_cubit.dart`

**Problem:** The dashboard marks suppliers as "absent" if they have no entry TODAY. But `absenceAlertDays = 3` is defined in constants, suggesting alerts should only fire after 3 consecutive days of absence. The existing `MilkDateUtils.calcAbsenceStreak()` method exists but isn't used.

**Fix:**
- Replace the simple "no entry today" check with `calcAbsenceStreak()`.
- Only show in the absence alert section if streak >= `absenceAlertDays` (3).
- Show the streak count on each alert card (e.g., "Absent 5 days").

**Impact:** MEDIUM — Reduces noise from single-day absences, highlights real concerns.

---

### 4.2 Add Supplier Performance Trends Chart

**Problem:** Dashboard only shows today's stats. No visibility into trends over time.

**Implementation:**
- Add a new section to the dashboard: "This Week's Trend" using `fl_chart`.
- Line chart showing total daily collection weight over the last 7 days.
- Tap on a day to see breakdown by supplier.
- Add a "Top Suppliers" card showing the 5 highest-producing suppliers this week.

**Impact:** MEDIUM — Adds analytical value for business decisions.

---

### 4.3 Add Quality Anomaly Alerts

**Problem:** No system to flag unusual entries that may indicate errors or fraud.

**Implementation:**
- Calculate each supplier's rolling 7-day average weight.
- If a new entry deviates by more than 50% from the average, show a warning:
  - On the weight entry sheet: "This is significantly different from [supplier]'s average (X kg). Continue?"
  - On the dashboard: "Anomaly Alerts" section with flagged entries.
- Store average in local cache (updated daily) to avoid extra Firestore reads.

**Impact:** MEDIUM — Catches data entry errors and unusual patterns early.

---

### 4.4 Dashboard Performance Optimization

**Problem:** Dashboard subscribes to ALL suppliers and ALL entries simultaneously. With 1000+ suppliers, this causes slow loads and excessive Firestore reads.

**Implementation:**
- Filter queries to only active suppliers (`isActive == true`).
- Use Firestore pagination (limit to 50 per page for supplier lists).
- Cache dashboard stats for 60 seconds — don't recompute on every navigation.
- Use `StreamSubscription` with `.distinct()` to avoid rebuilding on duplicate data.

**Impact:** MEDIUM — Noticeable performance improvement for large datasets.

---

## Phase 5 — Today Receiving Feature Enhancements

### 5.1 Add Undo Button for Recent Weight Entries

**Problem:** Once a weight entry is submitted, there's no undo. Users must go through the edit flow (which is limited to 1 edit). Accidental submissions with wrong data are costly.

**Implementation:**
- After successful submission, show a SnackBar with "Undo" action for 10 seconds.
- If tapped, delete the entry and re-open the weight entry sheet with the previous values.
- After timeout, the entry is permanent.
- Don't count undone entries toward the edit limit.

**Impact:** MEDIUM — Significant UX improvement for field workers entering data quickly.

---

### 5.2 Add "No Milk" Reason Field

**File:** `lib/features/today/presentation/widgets/no_milk_dialog.dart`

**Problem:** When marking a supplier as "No Milk", no reason is recorded. Admins have no visibility into WHY a supplier had no milk (sick animal, travel, seasonal, etc.).

**Implementation:**
- Add a dropdown or chip selection to the NoMilkDialog:
  - Options: "Sick animal", "Travel", "Seasonal break", "Refused", "Other" (with text field).
- Store the reason in the Firestore entry document: `noMilkReason: String`.
- Display the reason in the entry details screen and weekly reports.

**Impact:** LOW — Adds context for business analysis.

---

### 5.3 Add Batch Entry Mode

**Problem:** For collectors visiting 30+ suppliers daily, entering weights one by one is slow. Each entry requires: tap supplier → enter weight → submit → go back → find next supplier.

**Implementation:**
- Add a "Batch Mode" toggle button on the Today Receiving screen.
- In batch mode:
  - Show a scrollable list of all pending suppliers with inline weight input fields.
  - User types weight and presses Tab/Next to move to the next field.
  - "Submit All" button at the bottom saves all entries at once.
- Use a Firestore batch write for atomicity.
- Show progress bar during batch submission.

**Impact:** HIGH — Major productivity improvement for field workers.

---

### 5.4 Add Voice Input for Weight Entry

**Problem:** Field workers often have dirty/wet hands and struggle with touchscreen keyboards.

**Implementation:**
- Add `speech_to_text` package.
- Add a microphone icon button next to the weight input field.
- On tap: listen for a number (e.g., "twenty three point five").
- Parse the spoken number and populate the weight field.
- Confirm with the user before submitting.
- Support Arabic number speech recognition.

**Impact:** MEDIUM — Accessibility improvement for field conditions.

---

### 5.5 Show Last Entry Info on Supplier Card

**Problem:** When entering today's weight, the collector can't see what this supplier typically provides or what they provided yesterday.

**Implementation:**
- On the pending card or weight entry sheet, show:
  - Yesterday's weight (or "No entry yesterday").
  - 7-day average.
  - Last 3 entries as small chips (e.g., "23.5 | 24.0 | 22.8").
- Helps collectors spot errors before submission.

**Impact:** LOW — Context-aware data entry reduces errors.

---

## Phase 6 — Reports Feature Enhancements

### 6.1 Implement PDF Report Generation & Sharing

**Problem:** The app has `pdf` and `printing` packages in pubspec.yaml but no actual PDF generation is implemented. WhatsApp sharing keys exist in translations but aren't wired up.

**Implementation:**
- Create `lib/features/reports/data/services/pdf_report_service.dart`:
  - Generate a formatted PDF with:
    - Report header (date range, collector name).
    - Summary stats (total weight, supplier count, missing days).
    - Table with per-supplier daily weights for the week.
    - Footer with generation timestamp.
  - Support Arabic text rendering (use Arabic-compatible font like Amiri or Noto).
- Add "Share" button on `WeeklyReportDetailsScreen`:
  - "Print" — uses `printing` package to send to printer.
  - "Share PDF" — uses `share_plus` to share via WhatsApp, email, etc.
  - "Save to Device" — saves PDF to Downloads folder.

**Impact:** HIGH — Core business requirement for record-keeping and communication.

---

### 6.2 Add Report Finalization Confirmation & Minimum Threshold

**Problem:** Reports can be finalized with 0% completion. No confirmation dialog.

**Implementation:**
- Before finalizing, show a dialog:
  - "X out of Y suppliers have entries (Z%). Are you sure you want to finalize?"
  - If completion < 80%, show a warning: "Some suppliers are missing entries. Missing entries cannot be added after finalization."
- Add optional notes field for the report (e.g., "Week interrupted by holiday").

**Impact:** LOW — Prevents premature report finalization.

---

### 6.3 Add Report Debouncing to Prevent Duplicates

**File:** `lib/features/reports/presentation/cubit/reports_list_cubit.dart`

**Problem:** `createReport()` can be called multiple times rapidly, creating duplicate reports in Firestore.

**Fix:**
- Add `isCreating` flag to state — ignore calls while true.
- Add debounce (500ms) on the create button.
- Check if a report for the same week already exists before creating.

**Impact:** LOW — Prevents data duplication.

---

### 6.4 Add Monthly/Custom Date Range Reports

**Problem:** Only weekly reports exist. Users may need monthly summaries or custom date ranges.

**Implementation:**
- Add a "Monthly Reports" tab on the Reports screen.
- Add "Custom Range" option with date picker.
- Monthly report aggregates all weekly reports in the month.
- Show monthly totals, averages, and comparison to previous month.
- Include per-supplier monthly production chart.

**Impact:** MEDIUM — Adds business value for longer-term analysis.

---

## Phase 7 — Suppliers Feature Enhancements

### 7.1 Add Duplicate Supplier Detection

**Problem:** No validation prevents creating two suppliers with the same name or phone number.

**Implementation:**
- In `AddEditSupplierCubit.saveSupplier()`:
  - Before creating, query Firestore for existing supplier with same phone number.
  - If found, show error: "A supplier with this phone number already exists: [name]".
  - Warn (but allow) on duplicate names with different phones.
- Add a similar check for name similarity (Levenshtein distance < 3) to catch typos.

**Impact:** MEDIUM — Prevents data quality issues.

---

### 7.2 Add Bulk Route Order with Firestore Transaction

**File:** `lib/features/suppliers/presentation/cubit/route_ordering_cubit.dart`

**Problem:** `bulkUpdateRouteOrder()` updates each supplier individually. If some updates fail mid-batch, route orders become inconsistent.

**Fix:**
- Wrap all updates in a single Firestore `WriteBatch` or `Transaction`.
- If any update fails, roll back all changes.
- Show success/failure result to user.

**Impact:** LOW — Data consistency improvement.

---

### 7.3 Add Supplier Deactivation Audit Trail

**Problem:** When a supplier is deactivated, `deactivatedAt` is set but there's no record of WHO deactivated them or WHY.

**Implementation:**
- Add fields to supplier document: `deactivatedBy: String` (user UID), `deactivationReason: String`.
- Show a dialog when deactivating asking for reason: "Moved", "Quit", "Season ended", "Other".
- Display deactivation history in supplier details screen.
- Add a "Reactivate" button for previously deactivated suppliers.

**Impact:** LOW — Compliance and traceability.

---

### 7.4 Add Supplier Import/Export (CSV)

**Problem:** Suppliers must be added one by one. For a collector with 100+ suppliers, initial setup is tedious.

**Implementation:**
- Add "Import from CSV" button in suppliers list:
  - Pick CSV file from device.
  - Parse columns: name, phone, village, routeOrder.
  - Show preview table with validation errors highlighted.
  - Confirm to batch-create all valid suppliers.
- Add "Export to CSV" button:
  - Generate CSV of all suppliers with their current details.
  - Share via `share_plus`.

**Impact:** MEDIUM — Onboarding efficiency for new users.

---

### 7.5 Add Supplier Map View

**Problem:** Route ordering is manual. No visual representation of supplier locations.

**Implementation:**
- Add optional GPS coordinates to supplier model (latitude, longitude).
- Add a "Map View" toggle on the suppliers list screen using `google_maps_flutter` or `flutter_map`.
- Show suppliers as pins on the map.
- Allow drag-and-drop route optimization based on geography.
- "Optimize Route" button that suggests optimal order based on GPS proximity.

**Impact:** MEDIUM — Useful for route planning but requires GPS data entry.

---

## Phase 8 — Settings & User Management

### 8.1 Implement Full Settings Backend

**File:** `lib/features/settings/data/data_source/settings_data_source.dart`

**Problem:** Settings only stores "onboarded" flag. Many settings have UI placeholders but no backend.

**Implementation:**
- Expand `SettingsDataSource` to store in SharedPreferences:
  - `language`: `ar` | `en` — actually switch locale via EasyLocalization.
  - `weekStartDay`: `saturday` | `sunday` | `monday` — affect report week boundaries.
  - `weightUnit`: `kg` | `liter` — display conversion (1 liter ≈ 1.03 kg).
  - `autoSync`: `true` | `false` — toggle automatic sync when online.
  - `notificationsEnabled`: `true` | `false`.
  - `dateFormat`: `yyyy/MM/dd` | `dd/MM/yyyy`.
- Create `SettingsCubit` to manage state for all settings.
- Persist to both SharedPreferences (local) and Firestore (cloud backup).

**Impact:** MEDIUM — Essential feature completeness.

---

### 8.2 Add User Profile Management

**Problem:** No way to change email, password, or view account details.

**Implementation:**
- Add "Profile" section in settings:
  - Display name (editable).
  - Email (display only, with "Change Email" flow).
  - "Change Password" with current password verification.
  - "Delete Account" with confirmation and data wipe.
  - Profile picture (optional, stored in Firebase Storage).
- Add `profile_data_source.dart` and `profile_repo.dart`.

**Impact:** MEDIUM — Standard user account management.

---

### 8.3 Add Logout Confirmation with Sync Warning

**File:** `lib/features/settings/presentation/cubit/settings_state.dart`

**Problem:** Logout happens immediately without warning. Pending local data could be lost.

**Fix:**
- Before logout, check if sync queue has pending operations.
- If yes: "You have X pending entries that haven't been synced. Logging out will lose this data. Continue?"
- If no: Simple "Are you sure you want to log out?" confirmation.

**Impact:** LOW — Prevents accidental data loss.

---

### 8.4 Add App Version & About Screen

**Problem:** No version info, legal notices, or about screen.

**Implementation:**
- Add "About" item in settings:
  - App version (from pubspec.yaml via `package_info_plus`).
  - Build number.
  - "Terms of Service" link.
  - "Privacy Policy" link.
  - "Contact Support" with email.
  - "Rate the App" link to Play Store.
  - Open source licenses.

**Impact:** LOW — Standard app feature, helpful for support.

---

## Phase 9 — Localization & RTL Fixes

### 9.1 Fix Hardcoded LTR Text Directions

**Problem:** Some widgets have `textDirection: TextDirection.ltr` hardcoded, breaking the Arabic-first RTL layout.

**Fix:**
- Search all `.dart` files for `TextDirection.ltr` and remove unless intentionally needed (e.g., phone numbers, numeric fields).
- Ensure all layouts respect the system text direction from `Directionality.of(context)`.
- Test the entire app in Arabic mode for RTL correctness.

**Impact:** MEDIUM — Arabic is the primary language; RTL must work correctly.

---

### 9.2 Consistent Arabic Numeral Usage

**Problem:** `MilkDateUtils.toArabicNumerals()` exists but is applied inconsistently. Some screens show Western numerals (1, 2, 3) and others show Arabic (١، ٢، ٣).

**Fix:**
- Audit all numeric displays in the app.
- Apply `toArabicNumerals()` when locale is Arabic.
- Create a wrapper extension: `num.toLocaleString(context)` that auto-selects format.
- Apply to: weights, counts, dates, percentages, route orders.

**Impact:** LOW — UI polish for Arabic users.

---

### 9.3 Add Translation Key Validation Test

**Problem:** No automated way to verify all `.tr()` calls have matching keys in JSON files.

**Implementation:**
- Create `test/localization_test.dart`:
  - Scan all `.dart` files for patterns: `'key'.tr()`, `LangKeys.key`, `context.translate(LangKeys.key)`.
  - Extract all referenced keys.
  - Load `ar.json` and `en.json`.
  - Assert all referenced keys exist in both files.
  - Assert all JSON keys are referenced somewhere (detect dead keys).
- Run as part of CI pipeline.

**Impact:** MEDIUM — Prevents runtime translation errors.

---

### 9.4 Add Missing Translation Keys

**Problem:** Some keys used in code don't exist in the JSON files, or vice versa.

**Fix:**
- Run the validation test from 9.3 to identify all mismatches.
- Add missing keys to both `ar.json` and `en.json`.
- Add missing `LangKeys` constants.
- Remove unused keys from JSON files.

**Impact:** LOW — Clean up existing translation gaps.

---

## Phase 10 — Testing & Quality Assurance

### 10.1 Add Unit Tests for Business Logic

**Problem:** Zero test coverage. Critical calculations like `MilkDateUtils`, report statistics, and absence streaks have no tests.

**Implementation:**
- Create test files:
  ```
  test/core/utils/date_utils_test.dart
  test/features/today/cubit/weight_entry_cubit_test.dart
  test/features/reports/data/reports_data_source_test.dart
  test/features/dashboard/cubit/dashboard_cubit_test.dart
  test/features/suppliers/cubit/add_edit_supplier_cubit_test.dart
  ```
- Test coverage targets:
  - Date utils: 100% (edge cases for week boundaries, Arabic numerals, streaks).
  - Weight validation: 100% (min/max, decimal precision, duplicates).
  - Report calculations: 100% (missing counts, averages, finalization).
  - Cubit state transitions: 80%+ (loading, success, error, edge cases).

**Impact:** HIGH — Foundation for safe future development.

---

### 10.2 Add Widget Tests for Critical UI Components

**Implementation:**
- Test files:
  ```
  test/features/today/widgets/weight_entry_sheet_test.dart
  test/features/today/widgets/pending_card_test.dart
  test/features/suppliers/widgets/supplier_card_test.dart
  test/features/auth/screens/login_screen_test.dart
  ```
- Focus on:
  - Form validation (empty fields, invalid inputs).
  - Button states (enabled/disabled based on form validity).
  - Error message display.
  - Loading indicator visibility.

**Impact:** MEDIUM — Catches UI regressions.

---

### 10.3 Add Integration Tests for Key Flows

**Implementation:**
- Test files:
  ```
  integration_test/auth_flow_test.dart
  integration_test/daily_collection_flow_test.dart
  integration_test/report_generation_flow_test.dart
  ```
- Flows to test:
  - Login → Dashboard → Enter Weight → Verify Entry → Logout.
  - Signup → Email Verification → First Login.
  - Create Supplier → Enter Week of Data → Generate Report → View Report.

**Impact:** MEDIUM — End-to-end confidence.

---

### 10.4 Set Up Firebase Emulator for Testing

**Problem:** Tests require a real Firebase backend, making them slow and unreliable.

**Implementation:**
- Add `firebase.json` with emulator configuration.
- Configure Firestore, Auth, and Storage emulators.
- Add `test/firebase_emulator_setup.dart` helper.
- Update DI to use emulator endpoints in test mode.
- Document setup in README.

**Impact:** MEDIUM — Enables reliable, fast testing without affecting production data.

---

## Phase 11 — Notifications & Alerts

### 11.1 Add Push Notifications for Daily Reminders

**Problem:** No notification system. Collectors may forget to enter data.

**Implementation:**
- Add `firebase_messaging` and `flutter_local_notifications` packages.
- Configure FCM for push notifications.
- Send daily reminder at configurable time (default: 6:00 PM) if today's entries are incomplete.
- Notification content: "You have X suppliers pending for today."
- Tapping notification opens the Today Receiving screen.

**Impact:** MEDIUM — Improves data completeness.

---

### 11.2 Add Absence Alert Notifications

**Problem:** Dashboard shows absence alerts but only when the user opens the app.

**Implementation:**
- Create a Cloud Function that runs daily at 8:00 PM.
- Check each user's suppliers for 3+ day absence streaks.
- Send push notification: "Supplier [name] hasn't delivered milk for [N] days."
- Include action button: "Call Supplier" (opens phone dialer).

**Impact:** MEDIUM — Proactive alerting for business-critical situations.

---

### 11.3 Add In-App Notification Center

**Problem:** No central place to see past alerts, system messages, or action items.

**Implementation:**
- Add notification bell icon in the app bar.
- Badge count for unread notifications.
- Notification types: absence alerts, sync status, report ready, system updates.
- Persist notifications locally and mark as read/unread.
- Swipe to dismiss.

**Impact:** LOW — UX enhancement for information management.

---

## Phase 12 — Multi-User & Role Management

### 12.1 Add Role-Based Access Control

**Problem:** Single user type. No distinction between admin (dairy owner) and collector (field worker).

**Implementation:**
- Add `role` field to user document: `admin` | `collector`.
- Admin capabilities: all current features + user management + report finalization.
- Collector capabilities: view assigned suppliers + enter weights + view own entries.
- Add role check middleware in router redirect.
- Admin can create collector accounts and assign supplier routes to them.

**Impact:** HIGH — Required for scaling beyond single-user operation.

---

### 12.2 Add Multi-Collector Support

**Problem:** App assumes one collector manages all suppliers. Real dairies may have multiple collectors.

**Implementation:**
- Add `collectorId` field to supplier and entry documents.
- Admin dashboard shows all collectors' data aggregated.
- Each collector only sees their assigned suppliers.
- Admin can reassign suppliers between collectors.
- Route ordering is per-collector.

**Impact:** HIGH — Essential for medium/large dairy operations.

---

### 12.3 Add Activity Audit Log

**Problem:** No tracking of who did what and when. Critical for accountability.

**Implementation:**
- Create `audit_logs` Firestore collection.
- Log events: entry created, entry edited, supplier added/deactivated, report finalized, settings changed.
- Each log: `userId`, `action`, `targetId`, `timestamp`, `oldValue`, `newValue`.
- Admin can view audit log in settings.
- Filter by user, action type, date range.

**Impact:** MEDIUM — Accountability and compliance.

---

## Phase 13 — UI/UX Polish

### 13.1 Add Dark Theme Support

**File:** `lib/core/theme/app_theme.dart`

**Problem:** Only one theme exists. No dark mode.

**Implementation:**
- Create `AppTheme.dark()` alongside existing `AppTheme.theme`.
- Add theme toggle in settings (Light / Dark / System).
- Store preference in SharedPreferences.
- Wrap `MaterialApp.router` in `BlocBuilder<SettingsCubit>` to switch `themeMode`.

**Impact:** LOW — User comfort, especially for nighttime use.

---

### 13.2 Add Skeleton Loading States

**Problem:** Loading states show a simple `CircularProgressIndicator`. No visual structure while data loads.

**Implementation:**
- Create `lib/core/widgets/skeleton_loader.dart` using `shimmer` package.
- Replace loading spinners on:
  - Dashboard (skeleton cards).
  - Suppliers list (skeleton list items).
  - Reports list (skeleton rows).
- Maintain existing error states.

**Impact:** LOW — Perceived performance improvement.

---

### 13.3 Add Empty State Illustrations

**Problem:** Empty lists show plain text messages. Not visually engaging.

**Implementation:**
- Add SVG illustrations for empty states:
  - No suppliers: illustration + "Add your first supplier" CTA button.
  - No entries today: illustration + "Start recording milk" CTA.
  - No reports: illustration + "Complete a week to generate your first report."
- Use `flutter_svg` package for rendering.

**Impact:** LOW — Professional polish.

---

### 13.4 Improve Onboarding Flow

**File:** `lib/features/auth/presentation/screens/onboarding_screen.dart`

**Problem:** Onboarding exists but may not adequately explain the app's workflow.

**Implementation:**
- Create a 3-4 step onboarding with illustrations:
  1. "Manage your suppliers" — add and organize milk suppliers.
  2. "Record daily weights" — quick entry of milk weights along your route.
  3. "Track & report" — weekly reports, absence alerts, performance trends.
  4. "Works offline" — record data anywhere, sync when connected.
- Add "Skip" and "Next" buttons.
- Animate transitions between steps.

**Impact:** LOW — First-time user experience.

---

## Phase 14 — Advanced Features (Future)

### 14.1 Add Payment/Financial Tracking

**Problem:** The app tracks milk weights but not payments to suppliers.

**Implementation:**
- Add `price_per_kg` field to supplier or global settings.
- Calculate weekly/monthly payment per supplier.
- Generate payment report alongside weight report.
- Mark payments as paid/unpaid.
- Export payment report as PDF for record-keeping.

**Impact:** HIGH — Major value-add for dairy business management.

---

### 14.2 Add Milk Quality Tracking

**Problem:** Only weight is tracked. Milk quality (fat content, SNF) affects pricing.

**Implementation:**
- Add optional fields to weight entry: `fatPercentage`, `snfPercentage`, `quality` (A/B/C grade).
- Show quality trends in supplier details.
- Factor quality into pricing calculations.
- Alert on quality drops.

**Impact:** MEDIUM — Industry-specific value for quality-conscious dairies.

---

### 14.3 Add Multi-Language Expansion

**Problem:** Only Arabic and English supported.

**Implementation:**
- Add Urdu, Hindi, Turkish, French translations (common dairy regions).
- Use professional translation services.
- Add language selector in onboarding for new users.

**Impact:** LOW — Market expansion potential.

---

### 14.4 Add Data Backup & Restore

**Problem:** Data exists only in Firestore. No user-controlled backup.

**Implementation:**
- "Backup Data" button in settings:
  - Export all data (suppliers, entries, reports) as JSON file.
  - Save to device or Google Drive.
- "Restore Data" button:
  - Import JSON file.
  - Merge or replace existing data (user choice).
- Auto-backup weekly to Google Drive (if connected).

**Impact:** MEDIUM — Data safety for business-critical records.

---

### 14.5 Add Tablet/iPad Layout

**Problem:** UI is designed for phone screens only. No responsive layout for tablets.

**Implementation:**
- Use `LayoutBuilder` to detect screen width.
- For tablets (>600dp): side-by-side navigation (master-detail pattern).
- Dashboard on tablet: 2-3 column grid instead of single column.
- Weight entry on tablet: show supplier list and entry form side by side.

**Impact:** LOW — Useful for office/admin use cases.

---

## Priority Summary

| Priority | Phase | Effort | Impact |
|----------|-------|--------|--------|
| P0 | Phase 1 — Critical Bug Fixes | LOW-MEDIUM | HIGH |
| P0 | Phase 2 — Security Hardening | MEDIUM | CRITICAL |
| P1 | Phase 3 — Offline Support | HIGH | HIGH |
| P1 | Phase 5 — Today Receiving UX | MEDIUM | HIGH |
| P1 | Phase 6.1 — PDF Reports | MEDIUM | HIGH |
| P2 | Phase 4 — Dashboard Analytics | MEDIUM | MEDIUM |
| P2 | Phase 10 — Testing | HIGH | HIGH |
| P2 | Phase 8 — Settings | MEDIUM | MEDIUM |
| P3 | Phase 7 — Suppliers | MEDIUM | MEDIUM |
| P3 | Phase 9 — Localization | LOW | MEDIUM |
| P3 | Phase 11 — Notifications | MEDIUM | MEDIUM |
| P4 | Phase 12 — Multi-User | HIGH | HIGH |
| P4 | Phase 13 — UI Polish | LOW | LOW |
| P5 | Phase 14 — Advanced Features | HIGH | VARIES |
