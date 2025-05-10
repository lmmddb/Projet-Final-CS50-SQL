from faker import Faker
import csv
import random

fake = Faker('fr_FR')
with open('accounts.csv', 'w') as f:
    writer = csv.writer(f)
    writer.writerow(['account_number', 'customer_id', 'account_type', 'balance', 'opened_date'])
    for i in range(1, 501):
        writer.writerow([
            i + 1000,  # Numéro de compte à partir de 1001
            random.randint(1, 200),  # customer_id entre 1 et 200
            random.choice(['Checking', 'Savings', 'Loan']),
            round(random.uniform(-10000, 50000), 2),
            fake.date_between(start_date='-5y', end_date='today')
        ])