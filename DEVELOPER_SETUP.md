**Developer Setup (Windows PowerShell)**

- Create and activate virtual environment:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

- Install dependencies and developer tools (ruff):

```powershell
.venv\Scripts\python.exe -m pip install --upgrade pip setuptools wheel
.venv\Scripts\python.exe -m pip install -r backend\requirements.txt ruff
```

- Run ruff (auto-fix where safe) and tests:

```powershell
.venv\Scripts\ruff.exe check backend --fix
.venv\Scripts\python.exe backend\test_production.py
```

- Quick helper script (automates above):

```powershell
scripts\setup_dev.ps1
```

Notes:
- If PowerShell blocks execution of scripts, run as Administrator and set execution policy temporarily:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
```

- In production, set `SECRET_KEY` and `CSRF_ENABLED=true`, and configure `DATABASE_URI` and `RATELIMIT_STORAGE_URL` in a `.env` file or environment.
