# Daily Expense Tracker — n8n Workflow

An AI-powered personal expense tracker that logs expenses via **Telegram** (text, voice, or image) and sends a **daily summary report at 9PM EAT**.

---

## How It Works

```
Telegram Message
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

⏰ 9PM Daily: Supabase → GPT Summary → Telegram
```

---

## Features

- **Multi-modal input** — log expenses by typing, speaking, or photographing a receipt
- **AI extraction** — GPT-4.1 parses description, amount, and category automatically
- **Dual storage** — Google Sheets for human review + Supabase for AI querying
- **Conversation memory** — Redis keeps context across messages (per Telegram user ID)
- **Daily report** — Automated 9PM EAT summary with spending insights and tips
- **Smart categorization** — Maps expenses to 11 standard categories

---

## Expense Categories

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

## Tech Stack

| Tool | Purpose |
|---|---|
| [n8n](https://n8n.io) | Workflow automation |
| Telegram Bot API | Input & output channel |
| OpenAI GPT-4.1 | Expense extraction & chat |
| OpenAI GPT-4o-mini | Image analysis & daily report |
| OpenAI Whisper | Voice transcription |
| Google Sheets | Human-readable log |
| Supabase (PostgreSQL) | Structured database |
| Redis | Conversation memory |

---

## Setup Guide

### Prerequisites

- n8n instance (self-hosted or cloud)
- Telegram bot (create via [@BotFather](https://t.me/BotFather))
- OpenAI API key
- Google Sheets OAuth credentials
- Supabase project
- Redis instance

### 1. Create a Telegram Bot

1. Open Telegram and message [@BotFather](https://t.me/BotFather)
2. Send `/newbot` and follow the prompts
3. Copy the bot token (format: `123456789:ABCdef...`)
4. Send `/start` to your new bot to activate it

### 2. Supabase — Create the `expenses` table

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

### 3. Google Sheets — Create the spreadsheet

Create a sheet named **Sheet1** with these column headers in row 1:

```
Date & Time | Description | Category | Amount
```

### 4. Import the n8n Workflow

1. Open your n8n instance
2. Go to **Workflows → Import from File**
3. Upload `Daily_Expense_Tracker_Telegram.json`
4. Configure credentials for each node (see below)

### 5. Configure Credentials

| Node | Credential Needed |
|---|---|
| Telegram Trigger | Telegram Bot Token |
| Telegram (send) | Telegram Bot Token |
| OpenAI nodes | OpenAI API key |
| Google Sheets | Google OAuth 2.0 |
| Supabase nodes | Supabase URL + Service Key |
| Redis Memory | Redis connection string |

### 6. Update Configuration

In the HTTP Request nodes (file download), replace `YOUR_BOT_TOKEN` in the URL with your actual Telegram bot token:
```
https://api.telegram.org/file/botYOUR_BOT_TOKEN/{{ $json.result.file_path }}
```

In the Google Sheets node, replace `YOUR_SPREADSHEET_ID` with your actual spreadsheet ID.

### 7. Get Your Telegram Chat ID

To receive the daily report, you need your chat ID:
1. Send any message to your bot
2. Visit: `https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates`
3. Find `message.chat.id` in the response
4. Set this as the Chat ID in the **Send message** node

### 8. Activate the Workflow

Toggle the workflow to **Active** in n8n. The Telegram webhook registers automatically.

---

## Usage Examples

Send any of these to your Telegram bot:

**Text:**
> "Spent 450 on lunch at KFC"
> "Uber to the office 230 KES"
> "Bought airtime 100 bob"

**Voice note:** Just speak naturally — "I spent three hundred shillings on groceries"

**Image:** Send a photo of a receipt and the bot will extract the expense automatically

---

## Daily Report Format

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

## Customization

- **Report time** — Change the Schedule Trigger (currently 21:00 EAT / UTC+3)
- **Currency** — Default is KES; update the AI Agent system prompt to change it
- **Categories** — Edit the category list in the AI Agent system prompt
- **Report recipient** — Update the Chat ID in the "Send message" node

---

## Workflow Files

| File | Description |
|---|---|
| `Daily_Expense_Tracker_Telegram.json` | Current version (Telegram) |
| `Daily_Expense_Tracker_WhatsApp.json` | Original version (WhatsApp) |

---

## Security Notes

- **Never commit API keys or tokens** to this repo — use n8n's credential manager
- The workflow JSON uses placeholders (`YOUR_BOT_TOKEN`, `YOUR_SPREADSHEET_ID`) — replace after import in n8n
- Telegram bot tokens do not expire, but you can revoke and regenerate via @BotFather at any time

---

## License

MIT License — feel free to use, modify, and share.
