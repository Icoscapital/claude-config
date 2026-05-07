# Expense App — Expensify Clone
**Context:** Build a mobile-first expense reporting app for a team. Employees scan receipts, log expenses, and every Monday an automated CSV report is emailed to the admin. Admin can approve/reject reports via an in-app dashboard. Distributed via Expo Go (QR code — no App Store needed).

---

## Tech Stack (Confirmed)
| Layer | Choice |
|---|---|
| Mobile | React Native + Expo (Expo Go) |
| Backend / DB / Auth | Supabase (Postgres + Auth + Storage + Edge Functions) |
| OCR | Google Cloud Vision API |
| Report Delivery | CSV attached to email via SendGrid, every Monday 8am |
| Push Notifications | Expo Push Notifications |

---

## Folder Structure
```
expense-app/
├── app/
│   ├── _layout.tsx                   # Root: auth gate + role-based routing
│   ├── index.tsx                     # Loading screen → redirect
│   ├── (auth)/
│   │   ├── _layout.tsx
│   │   ├── login.tsx
│   │   └── register.tsx              # Create workspace (admin) OR join (employee)
│   ├── (employee)/
│   │   ├── _layout.tsx               # Tab nav: Home, Scan, Expenses, Profile
│   │   ├── home.tsx
│   │   ├── scan.tsx                  # Camera → OCR → pre-fill form
│   │   ├── expenses/
│   │   │   ├── index.tsx
│   │   │   ├── new.tsx
│   │   │   └── [id].tsx
│   │   └── profile.tsx
│   └── (admin)/
│       ├── _layout.tsx               # Tab nav: Dashboard, Reports, Team, Profile
│       ├── dashboard.tsx
│       ├── reports/
│       │   ├── index.tsx
│       │   └── [id].tsx              # Approve / reject with note
│       ├── team.tsx
│       └── profile.tsx
├── components/
│   ├── ExpenseCard.tsx
│   ├── CategoryPicker.tsx
│   ├── ReceiptImage.tsx
│   ├── StatusBadge.tsx
│   ├── AmountInput.tsx
│   ├── LoadingOverlay.tsx
│   └── EmptyState.tsx
├── hooks/
│   ├── useAuth.ts
│   ├── useExpenses.ts                # CRUD + real-time subscription
│   ├── useReports.ts
│   └── useCamera.ts
├── lib/
│   ├── supabase.ts                   # Supabase client singleton
│   ├── ocr.ts                        # Vision API call + receipt parser
│   ├── storage.ts                    # Upload receipt images
│   └── notifications.ts             # Expo push token registration
├── constants/
│   ├── categories.ts
│   └── theme.ts
├── types/index.ts
├── supabase/
│   ├── migrations/001_initial_schema.sql
│   └── functions/weekly-report/index.ts   # Monday cron job
├── app.json
├── .env
└── tsconfig.json
```

---

## Database Schema (Supabase / Postgres)

```sql
-- PROFILES (extends auth.users)
CREATE TABLE profiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  workspace_id  UUID,
  full_name     TEXT NOT NULL,
  role          TEXT NOT NULL DEFAULT 'employee' CHECK (role IN ('employee', 'admin')),
  push_token    TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- WORKSPACES
CREATE TABLE workspaces (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT NOT NULL,
  admin_email   TEXT NOT NULL,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE profiles ADD CONSTRAINT fk_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces(id);

-- EXPENSES
CREATE TABLE expenses (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  workspace_id    UUID NOT NULL REFERENCES workspaces(id),
  report_id       UUID,
  amount          NUMERIC(10,2) NOT NULL,
  currency        TEXT NOT NULL DEFAULT 'USD',
  category        TEXT NOT NULL CHECK (category IN ('meals','travel','accommodation','software','office_supplies','entertainment','other')),
  description     TEXT,
  merchant_name   TEXT,
  receipt_url     TEXT,
  expense_date    DATE NOT NULL DEFAULT CURRENT_DATE,
  status          TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','submitted','approved','rejected')),
  rejection_note  TEXT,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- REPORTS (one per workspace per week)
CREATE TABLE reports (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id    UUID NOT NULL REFERENCES workspaces(id),
  week_start      DATE NOT NULL,
  week_end        DATE NOT NULL,
  status          TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected')),
  total_amount    NUMERIC(10,2),
  csv_storage_key TEXT,
  reviewed_by     UUID REFERENCES profiles(id),
  reviewed_at     TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(workspace_id, week_start)
);
ALTER TABLE expenses ADD CONSTRAINT fk_report FOREIGN KEY (report_id) REFERENCES reports(id);

-- updated_at trigger on expenses
CREATE OR REPLACE FUNCTION update_updated_at() RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER expenses_updated_at BEFORE UPDATE ON expenses FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- RLS (enabled on all 4 tables)
-- Employees: read/write own expenses; can only update draft expenses
-- Admins: read all in workspace; update expense status; update reports
-- Edge Function uses service role key → bypasses RLS
```

**Storage Buckets:**
- `receipts/` (private) → `{workspaceId}/{userId}/{expenseId}.jpg`
- `reports/` (private) → `{workspaceId}/week-{YYYY-MM-DD}.csv`

---

## Receipt Scanning Flow
```
1. Camera permission check (useCamera hook)
2. CameraView.takePictureAsync({ quality: 0.7, base64: true })
3. Upload JPEG → Supabase Storage receipts/ bucket (lib/storage.ts)
4. POST base64 to Google Vision API (lib/ocr.ts)
   - Features: TEXT_DETECTION + DOCUMENT_TEXT_DETECTION
5. Parse response with regex:
   - AMOUNT:   /\$?\d{1,4}[.,]\d{2}/g  → largest match
   - DATE:     common date format patterns
   - MERCHANT: first non-numeric header line
6. router.push to expenses/new with params (amount, merchantName, date, receiptStoragePath)
7. Form pre-fills; user corrects, picks category, taps Save
8. Insert to expenses table (status: 'draft' or 'submitted')
```
OCR is best-effort: failures return null per field, form stays blank with a fallback toast.

---

## Monday Report — Edge Function (Cron: `0 8 * * 1`)
```
supabase/functions/weekly-report/index.ts

1. Auth: verify service role key header
2. Calculate weekStart (last Monday) and weekEnd (last Sunday)
3. For each workspace:
   a. Query submitted expenses in date window
   b. Skip if 0 expenses
   c. INSERT report row (status: pending, total_amount)
   d. UPDATE expenses.report_id = report.id
   e. Generate CSV string (headers + one row per expense)
   f. Upload CSV → Supabase Storage reports/ bucket
   g. Send email via SendGrid API with CSV as attachment
   h. Send Expo push notifications to all employees with tokens
4. Return { ok: true }
```

Cron registration via `supabase/config.toml` `[[functions.weekly-report.crons]]` or `pg_cron` SQL.

---

## Build Order (10-day plan)

| Day | Phase | Deliverable |
|-----|-------|-------------|
| 1 | Scaffold | `create-expo-app`, install deps, `lib/supabase.ts`, `types/`, `constants/` |
| 1–2 | Database | Run migration SQL, create storage buckets, test RLS |
| 2 | Auth | Login + Register screens, root layout auth gate, role-based redirect |
| 3–4 | Employee CRUD | Expense list, add form, edit/view, home summary |
| 5 | Scan | Camera screen, Storage upload, Vision OCR, form pre-fill |
| 6–7 | Admin | Reports list/detail, approve/reject, dashboard, team view |
| 8 | Cron Job | Weekly report Edge Function, SendGrid email, CSV attachment |
| 9 | Push Notifications | Token registration, notify on report creation + approval/rejection |
| 10 | Polish | Loading states, error toasts, offline banner, QR distribution test |

---

## Key Architectural Decisions
- **Role routing at root `_layout.tsx`**: Admin and Employee are entirely separate tab groups. No cross-role navigation is possible in the UI.
- **Draft/Submitted lock**: Employees cannot edit submitted expenses. RLS policy enforces `status = 'draft'` check on UPDATE.
- **`report_id` null until Monday**: Expenses float until the cron attaches them to a report. Employees see a flat list; admin sees reports only after cron runs.
- **Workspace invite = UUID**: Joining a workspace requires the workspace UUID as an invite code. Simple enough for v1.
- **Service role key server-side only**: `SUPABASE_SERVICE_ROLE_KEY` lives only in Edge Function secrets. Mobile app uses only `SUPABASE_ANON_KEY`.

---

## Verification
1. **Auth**: Register employee + admin, verify role-based tab routing, session persistence on relaunch
2. **CRUD**: Add/edit/delete draft expense; submit; verify RLS blocks cross-user reads in Supabase table editor
3. **Scan**: Take photo of printed receipt, verify Storage upload, verify OCR pre-fill on form
4. **Report**: Manually trigger Edge Function via `curl`, verify email arrives with CSV, verify `reports` row created
5. **Approve/Reject**: Admin approves a report, verify expense statuses update, verify push notification received
6. **QR distribution**: `npx expo start --tunnel`, colleague scans QR on Expo Go, verifies login and scan work
