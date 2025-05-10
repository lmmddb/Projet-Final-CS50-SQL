import sqlite3
import csv
import os

def setup_database():
    """Crée la base de données à partir du fichier schema.sql"""
    conn = sqlite3.connect('bank.db')
    with open('schema.sql', 'r', encoding='utf-8') as f:
        schema = f.read()
    conn.executescript(schema)
    conn.commit()
    conn.close()
    print("✅ Base de données initialisée.")

def import_data():
    """Importe les données depuis des fichiers CSV dans les tables correspondantes"""
    conn = sqlite3.connect('bank.db')
    conn.execute("PRAGMA foreign_keys = ON")
    
    tables = [
        ('Customer', 'customers.csv'),
        ('Branch', 'branches.csv'),
        ('Account', 'accounts.csv'),
        ('Employee', 'employees.csv'),
        ('Transactions', 'transactions.csv')
    ]

    for table, file in tables:
        if not os.path.exists(file):
            print(f"⚠️ Fichier {file} introuvable. Table {table} ignorée.")
            continue

        with open(file, 'r', encoding='iso-8859-1') as f:
            reader = csv.DictReader(f)
            columns = reader.fieldnames
            placeholders = ', '.join(['?'] * len(columns))
            insert_query = f"INSERT INTO {table} ({', '.join(columns)}) VALUES ({placeholders})"
            
            for row in reader:
                try:
                    conn.execute(insert_query, list(row.values()))
                except sqlite3.IntegrityError as e:
                    print(f"❌ Erreur d'intégrité dans {table} : {e}")
    
    conn.commit()
    conn.close()
    print("✅ Importation des données terminée.")

if __name__ == '__main__':
    setup_database()
    import_data()
