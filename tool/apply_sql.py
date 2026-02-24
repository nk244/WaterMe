import sqlite3
import sys
try:
    conn = sqlite3.connect('water_me.db')
    with open('scripts/seed_test_data.sql', 'r', encoding='utf-8') as f:
        sql = f.read()
    conn.executescript(sql)
    conn.close()
    print('APPLIED')
except Exception as e:
    print('ERROR', e)
    sys.exit(1)
