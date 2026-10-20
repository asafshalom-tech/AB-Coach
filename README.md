# A/B Coach Studio 3.1

A privacy-conscious Hebrew workout tracker PWA that works offline using IndexedDB and optionally syncs with Supabase.

## Features
- Mobile-first RTL premium dark UI; dashboard with weekly goal, training stats, and next recommended A/B workout.
- Workout logging: quick per-set reps, optional RIR, exercise queue, progress, skip without logging zero, edit/undo, rest timer, vibration when supported, session notes.
- Objective performance scoring: 72% capped target fulfillment + 28% set completion; **technique is not inferred**. Weight and performance comparisons are separate.
- Gradual overload coaching, personal records (best working weight, reps at same load, volume), per-exercise trend graphs and post-workout summary.
- Editable A, B, Core plans; reorder and add exercises; separate on-device data and optional per-user cloud accounts.
- Data-provenance labels on legacy chat imports; provisional data excluded from PR calculations.
- JSON export and import, migration from previous IndexedDB key without clearing existing records.

## Deploy
Upload all files to the repository root and enable **GitHub Pages** > Deploy from branch > main > root. No build step required. The service worker includes a new cache name and precaches HTML/CSS/JS for offline use.

## Cloud setup (optional)
1. Create a Supabase project using a free plan (subject to current free-tier limits).
2. Run `supabase_setup.sql` in Supabase SQL Editor (enables RLS).
3. In the app's Settings, enter `Project URL` and the **public** Publishable/anon key, *never* the service_role key.
4. Each person signs up with a distinct email; if email confirmation is enabled, verify email first.
5. On first login, explicitly choose **Upload local data** or **Download cloud data**. Auto-sync begins after choosing. Cross-device changes detected from the `updated_at` timestamp pause syncing to prevent silent overwrites.
6. Take independent JSON backups. If two devices edit concurrently, automatic conflict **merging** is not implemented: manually choose which copy to keep. The app does not and cannot automatically access ChatGPT conversations.

## Data migration
Version 3 reads the original `ab-coach-database` / `app` / `state` IndexedDB object, automatically expands the schema, and preserves exercise order, historical records, and existing per-set logs. The first successful migration attempts to store an untouched copy in localStorage under `abcoach-migration-v2-snapshot`. The v2 source historically imported four chat sessions; the 7 Oct A session is marked **provisional** and is excluded from personal record calculations. Verify imported history before relying on it. New users choose an onboarding profile with or without chat history.

## Security and scope
The cloud auth REST interface depends on an independently provisioned Supabase project, and user RLS rules. No service credentials are embedded. Supabase account sessions are saved in browser localStorage for convenience; avoid using on shared devices. Passwords are never stored by the app. GitHub Pages only hosts static app files, not the user's data. Browser notifications are not implemented; rest timer is in-app only.


## Version 3.2 — Safe automatic two-way sync

* With cloud sync enabled, polls the authenticated account every 20 seconds and whenever the app becomes visible, focused, or reconnects. Updates received from ChatGPT through Supabase become visible without manually tapping Cloud Pull.
* Automatic cloud pulls are **blocked** during an active workout, while there are pending local writes, or while the user is typing in a field. The app shows a conflict indicator; manual Cloud Pull and Cloud Push remain available.
* Auto-push uses optimistic concurrency with the `updated_at` column: a `PATCH` with a timestamp match fails safely if another device or chat session writes first. This protects against most concurrent overwrites.
* Preserves a last local snapshot under `abcoach-v3-before-cloud-pull` before replacing it with cloud data. Manual Cloud Pull continues to replace the local profile, so export JSON first.
* The remote data model is still one JSON blob per account, **not** per-set merge. Concurrent edits still require a manual conflict decision. The chat is not autonomously monitored; ChatGPT reads/writes Supabase only when invoked with an authorized tool.
* Upgrading the site does not change the Supabase project or require re-running `supabase_setup.sql`. Existing login settings and training records remain stored on their respective devices/cloud.
