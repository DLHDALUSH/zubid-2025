import sqlite3
for path in ('backend/instance/auction.db','instance/auction.db','auction.db'):
    try:
        conn = sqlite3.connect(path)
        cur = conn.cursor()
        cur.execute("PRAGMA table_info(user)")
        cols = [r[1] for r in cur.fetchall()]
        print(path, '=>', cols)
        conn.close()
    except Exception as e:
        print(path, '=> ERROR', e)
