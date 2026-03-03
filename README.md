# 💰 Daily Expense Tracker — n8n Workflow

An AI-powered personal expense tracker that logs expenses via **WhatsApp** (text, voice, or image) and sends a **daily summary report at 9PM EAT**.

---

## 🧠 How It Works

```
WhatsApp Message
     │
     ▼
  [Switch] ──────────────────────────┐
     │                               │
  Text msg    Voice note         Receipt image
     │              │                 │
     │         Transcribe         Analyze (GPT-4o)
     │              │                 │
     └──────────────┴─────────────────┘
                    │
               [AI Agent]
                    │
          ┌─────────┴─────────┐
     Google Sheets         Supabase
   (human-readable)    (AI-queryable)

⏰ 9PM Daily: Supabase → GPT Summary → WhatsApp
```

---

## ✨ Features

- **Multi-modal input** — log expenses by typing, speaking, or photographing a receipt
- **AI extraction** — GPT-4.1 parses description, amount, and category automatically
- **Dual storage** — Google Sheets for human review + Supabase for AI querying
- **Conversation memory** — Redis keeps context across messages (per WhatsApp number)
- **Daily report** — Automated 9PM EAT summary with spending insights and tips
- **Smart categorization** — Maps expenses to 11 standard categories

---

## 📂 Expense Categories

| Category | Examples |
|---|---|
| Food & Dining | Lunch, groceries, coffee |
| Transport | Uber, matatu, fuel |
| Clothing | Shoes, outfits |
| Utilities | Electricity, water, WiFi |
| Health & Medical | Pharmacy, doctor visit |
| Entertainment | Movies, subscriptions |
| Education | Courses, books |
| Work & Business | Office supplies, software |
| Debt Payment | Loan repayment |
| Savings & Investment | M-Shwari, SACCO |
| Charity & Giving | Donations, harambee |

---

## 🛠️ Tech Stack

| Tool | Purpose |
|---|---|
| [n8n](https://n8n.io) | Workflow automation |
| WhatsApp Business API | Input & output channel |
| OpenAI GPT-4.1 | Expense extraction & chat |
| OpenAI GPT-4o-mini | Image analysis & daily report |
| OpenAI Whisper | Voice transcription |
| Google Sheets | Human-readable log |
| Supabase (PostgreSQL) | Structured database |
| Redis | Conversation memory |

---

## 🚀 Setup Guide

### Prerequisites

- n8n instance (self-hosted or cloud)
- WhatsApp Business API access (Meta Developer account)
- OpenAI API key
- Google Sheets OAuth credentials
- Supabase project
- Redis instance

### 1. Supabase — Create the `expenses` table

```sql
create table expenses (
  id uuid default gen_random_uuid() primary key,
  description text,
  category text,
  amount numeric,
  date_time timestamptz,
  created_at timestamptz default now()
);
```

### 2. Google Sheets — Create the spreadsheet

Create a sheet named **Sheet1** with these column headers in row 1:

```
Date & Time | Description | Category | Amount
```

### 3. Import the n8n Workflow

1. Open your n8n instance
2. Go to **Workflows → Import from File**
3. Upload `workflow/Daily_Expense_Tracker.json`
4. Configure credentials for each node (see below)

### 4. Configure Credentials

| Node | Credential Needed |
|---|---|
| WhatsApp Trigger | WhatsApp OAuth (Meta App) |
| OpenAI nodes | OpenAI API key |
| Google Sheets | Google OAuth 2.0 |
| Supabase nodes | Supabase URL + Service Key |
| Redis Memory | Redis connection string |
| WhatsApp (send) | WhatsApp Business API token |

### 5. Update Configuration

In the **"Send message"** node, update the recipient phone number to your WhatsApp number.

In the **"Message a model"** (daily report) node, update the `phoneNumberId` to match your WhatsApp Business phone number ID.

### 6. Activate the Workflow

Toggle the workflow to **Active** in n8n. The WhatsApp webhook will register automatically.

---

## 💬 Usage Examples

Send any of these to your WhatsApp bot number:

**Text:**
> "Spent 450 on lunch at KFC"
> "Uber to the office 230 KES"
> "Bought airtime 100 bob"

**Voice note:** Just speak naturally — "I spent three hundred shillings on groceries"

**Image:** Send a photo of a receipt and the bot will extract the expense automatically

---

## 📊 Daily Report Format

```
📅 Daily Expense Report - 2025-01-15

💰 Total: KES 2,450

📊 By Category:
- Food & Dining: KES 850
- Transport: KES 600
- Entertainment: KES 1,000

💡 Insight: Most spending was on entertainment today.
🎯 Tip: Consider packing lunch to reduce food costs tomorrow.
```

---

## ⚙️ Customization

- **Report time** — Change the Schedule Trigger (currently 21:00 EAT / UTC+3)
- **Currency** — Default is KES; update the AI Agent system prompt to change it
- **Categories** — Edit the category list in the AI Agent system prompt
- **Report recipient** — Update the phone number in the "Send message" node

---

## 🔒 Security Notes

- **Never commit API keys or tokens** to this repo — use n8n's credential manager
- Rotate your WhatsApp Bearer token regularly
- The workflow JSON in this repo has credentials removed — re-add them after import

---

## 📄 License

MIT License — feel free to use, modify, and share.
