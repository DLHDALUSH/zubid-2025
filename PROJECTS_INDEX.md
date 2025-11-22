# Project Index

This document summarizes the main projects and components in this repository, their locations, entry points, and quick run instructions for local development on Windows (PowerShell) and simple previews.

**Backend**: `backend/`
- **What:** Flask backend application
- **Entry point:** `backend/app.py`
- **Run (dev) (PowerShell):**
  - `python -m venv .venv`
  - `.\.venv\Scripts\Activate.ps1`
  - `pip install -r backend/requirements.txt` (or `requirements-postgresql.txt` / `requirements-mysql.txt` as needed)
  - `python backend/app.py` or run `start-backend.bat` from repository root
- **Run (production):** `gunicorn --config backend/gunicorn_config.py app:app` (see `backend/gunicorn_config.py`)
- **Tests:** `pytest backend/` (there are `backend/test_*.py` files)

**Frontend**: `frontend/`
- **What:** Static frontend (HTML/CSS/JS) — single-page pages and admin UI
- **Main file:** `frontend/index.html`
- **Preview (simple HTTP server, PowerShell):**
  - `cd frontend`
  - `python -m http.server 8000`
  - Open `http://localhost:8000` in your browser
- **Developer files:** `frontend/app.js`, `frontend/api.js`, and many `*.html` / `*.js` views

**Scripts & Utilities**: `scripts/`, root scripts
- **What:** Support scripts such as `scripts/backup_db.sh` and helper batch files like `start-backend.bat`, `start-frontend.bat`, `start-both.bat`.

**NGINX / Deployment config**: `nginx/`
- **File:** `nginx/zubid.conf` — example nginx config used for production deployment

**Instance / data directories**
- `instance/` — app instance configs and environment-specific files
- `uploads/` — file uploads (user content)
- `logs/` — log files (gitignored in many setups)

**Repository-level files & docs**
- `pyproject.toml` — repo Python metadata
- `README.md`, various `*_GUIDE.md` and deployment docs (see `DEPLOYMENT_*` files) for instructions and operational runbooks

**How to run a quick local dev environment (Windows PowerShell)**
1. Create & activate venv at repo root (or inside `backend/`):
   - `python -m venv .venv`
   - `.\.venv\Scripts\Activate.ps1`
2. Install backend deps:
   - `pip install -r backend/requirements.txt`
3. Start backend (dev):
   - `python backend/app.py`  (or `start-backend.bat`)
4. Start a simple frontend preview (separate terminal):
   - `cd frontend`
   - `python -m http.server 8000`

**Notes & next steps**
- This index is intentionally brief. Consider adding:
  - `npm`/build steps (if frontend evolves to use a bundler)
  - CI test commands and status badge in `README.md`
  - Contribution notes or developer onboarding steps
- If you want, I can commit this file, add it to the `README.md`, or expand each section with more specific commands and environment variable explanations.

---
Generated automatically to provide a quick project map. Update as the repo structure changes.
