import sqlite3
try:
    conn = sqlite3.connect('water_me.db')
    cur = conn.cursor()
    for t in ['plants','logs','notes']:
        try:
            cur.execute(f"SELECT COUNT(*) FROM {t}")
            n=cur.fetchone()[0]
        except Exception as e:
            n=str(e)
        print(f"TABLE {t}: {n}")
    conn.close()
except Exception as e:
    print('ERROR', e)
