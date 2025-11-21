# Installation Guide

## Quick Start (SQLite - Default)

The application uses SQLite by default, which requires no additional database setup.

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install --upgrade pip
pip install -r requirements.txt
```

## Optional: PostgreSQL Setup

If you want to use PostgreSQL instead of SQLite (recommended for production):

1. Install PostgreSQL on your system
2. Install the PostgreSQL driver:
   ```bash
   pip install -r requirements-postgresql.txt
   ```
3. Update your `.env` file:
   ```env
   DATABASE_URI=postgresql://username:password@localhost/dbname
   ```

**Note for Windows users:** If you encounter `pg_config` errors, you can:
- Install PostgreSQL from https://www.postgresql.org/download/windows/
- Or use the pre-built wheel: `pip install psycopg2-binary --only-binary :all:`

## Optional: MySQL Setup

If you want to use MySQL/MariaDB instead of SQLite:

1. Install MySQL/MariaDB on your system
2. Install the MySQL driver:
   ```bash
   pip install -r requirements-mysql.txt
   ```
3. Update your `.env` file:
   ```env
   DATABASE_URI=mysql+pymysql://username:password@localhost/dbname
   ```

## Troubleshooting

### psycopg2-binary installation fails on Windows

If you get `pg_config executable not found` error:

1. **Option 1 (Recommended):** Install PostgreSQL from https://www.postgresql.org/download/windows/
   - During installation, make sure to add PostgreSQL to PATH
   - Then run: `pip install -r requirements-postgresql.txt`

2. **Option 2:** Use pre-built wheel:
   ```bash
   pip install psycopg2-binary --only-binary :all:
   ```

3. **Option 3:** Use SQLite instead (default, no installation needed)

### PyMySQL installation fails

If PyMySQL fails to install, try:
```bash
pip install --upgrade pip
pip install PyMySQL
```

