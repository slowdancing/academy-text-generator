# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

A tool for a Korean math academy ("체인지수학") to generate weekly/monthly parent
report texts. It has two parts:

- **Flutter app** (`lib/`) — a form UI where a tutor enters a student's weekly
  info (attendance, books/units studied, homework, test scores, notes), then
  generates a formatted Korean report text and can request an AI-written
  parent comment.
- **Python FastAPI backend** (`backend/`) — a single endpoint that takes the
  form data and asks Gemini to write the parent comment in the academy's
  house style.

All UI text, generated reports, and the AI prompt are in Korean.

## Commands

### Flutter app (run from repo root)
- `flutter pub get` — install dependencies
- `flutter run` — run the app (pick a device/emulator)
- `flutter analyze` — static analysis (uses `flutter_lints` via `analysis_options.yaml`)
- `flutter test` — run widget tests
  - Note: `test/widget_test.dart` is the unmodified Flutter starter template
    (tests a counter app and references `MyApp`, which doesn't exist in this
    project). It will fail until it's rewritten or removed.

### Backend (run from `backend/`)
- `pip install -r requirements.txt` — install dependencies
- `uvicorn main:app --reload` — run the API locally (default `http://127.0.0.1:8000`)
- Requires a `backend/.env` file with `GEMINI_API_KEY=<key>` (loaded via
  `python-dotenv`; `ai_comment.py` raises at import time if it's missing).

## Architecture

### Flutter app data flow
- `lib/screens/report_screen.dart` — single stateful screen holding all form
  state as `TextEditingController`s, including a dynamic list of
  `BookStudyGroup` (each with a book name and a dynamic list of unit
  controllers, add/remove via `addBookGroup`/`addUnitToBook` etc.).
- "문자 생성" (Generate text) calls `buildFinalReport()` in
  `lib/utils/report_builder.dart` — a pure string-formatting function that
  assembles the final Korean report from the form fields. Edit this file to
  change the report's wording/layout.
- "AI 코멘트 생성" (Generate AI comment) calls `ReportApi.generateComment()` in
  `lib/services/report_api.dart`, which POSTs the form data as JSON to
  `{baseUrl}/generate-comment` (retries once on failure, 60s timeout). The
  returned comment fills the comment field, and the report is regenerated.
- `ReportApi.baseUrl` is hardcoded in `report_screen.dart` to the deployed
  Render backend (`https://academy-text-generator-api.onrender.com`).

### Backend
- `backend/main.py` — FastAPI app with one endpoint, `POST /generate-comment`,
  taking a `ReportInput` (`backend/schemas.py`) and returning
  `{"comment": "..."}`. CORS (`allow_origin_regex`) only permits
  `http://localhost:*` / `http://127.0.0.1:*` — i.e. it's set up for local web
  dev against this backend, not for browser requests from arbitrary deployed
  origins.
- `backend/ai_comment.py` — builds a long few-shot prompt (Korean example
  comments + house-style writing rules) from the `ReportInput`, then calls the
  Gemini API via `google-genai`. It tries `gemini-2.5-flash` then falls back to
  `gemini-1.5-flash`, with up to 3 attempts per model (1.5s sleep between
  retries on error).
- To change the AI comment's tone/structure/rules, edit the example comments
  and "작성 규칙" (writing rules) section inside `build_prompt()` in
  `ai_comment.py` — this is the primary lever for output quality.

### Keeping Flutter and backend payloads in sync
The fields sent by `ReportApi.generateComment()` must match
`ReportInput`/`TestResult` in `backend/schemas.py` (snake_case keys: e.g.
`student_name`, `test_results` with `unit`/`total`/`correct`). If you add a
field to the form in `report_screen.dart`, add it to both the API call body
and the Pydantic schema, and reference it in `build_prompt()` if it should
affect the AI comment.
