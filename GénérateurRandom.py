from faker import Faker
import csv
import random
from datetime import datetime, timedelta

fake = Faker('fr_FR')

# Génération des clients
def generate_customers(filename, num=200):
    with open(filename, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['customer_id', 'first_name', 'last_name', 'email', 'phone', 'address'])
        
        emails = set()
        for i in range(1, num+1):
            while True:
                email = fake.email(domain='examplebank.com')
                if email not in emails:
                    emails.add(email)
                    break
                    
            writer.writerow([
                i,
                fake.first_name(),
                fake.last_name(),
                email,
                f"+33 6 {fake.numerify('## ## ## ##')}",
                fake.address().replace('\n', ', ')
            ])

# Génération des comptes
def generate_accounts(filename, customers_file, num=500):
    with open(customers_file, 'r') as f:
        customer_ids = [row['customer_id'] for row in csv.DictReader(f)]
    
    with open(filename, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['account_number', 'customer_id', 'account_type', 'balance', 'opened_date'])
        
        for i in range(1, num+1):
            acc_type = random.choices(
                ['Checking', 'Savings', 'Loan'],
                weights=[60, 30, 10],
                k=1
            )[0]
            
            balance = round(random.uniform(
                -10000 if acc_type == 'Loan' else 0,
                50000 if acc_type == 'Savings' else 25000
            ), 2)
            
            writer.writerow([
                1000 + i,
                random.choice(customer_ids),
                acc_type,
                balance,
                fake.date_between(start_date='-5y', end_date='today')
            ])

# Génération des transactions
def generate_transactions(filename, accounts_file, num=10000):
    with open(accounts_file, 'r') as f:
        accounts = list(csv.DictReader(f))
    
    with open(filename, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['transaction_id', 'account_number', 'amount', 'transaction_type', 'transaction_date'])
        
        for i in range(1, num+1):
            acc = random.choice(accounts)
            trans_type = random.choices(
                ['Deposit', 'Withdrawal', 'Transfer'],
                weights=[40, 40, 20],
                k=1
            )[0]
            
            
            if trans_type == 'Withdrawal':
                
                balance = float(acc['balance'])
                
                if acc['account_type'] in ['Checking', 'Savings']:
                    # Retrait maximal = solde disponible
                    max_amount = abs(balance)
                    amount = -round(random.uniform(0.01, max_amount), 2)
                else:  # Pour les prêts
                    # Montant arbitraire négatif (pas de limite de crédit modélisée)
                    amount = -round(random.uniform(0.01, 10000), 2)
            else:
                amount = round(random.uniform(0.01, 10000), 2)

            writer.writerow([
                i,
                acc['account_number'],
                amount,
                trans_type,
                fake.date_time_between(
                    start_date=datetime.strptime(acc['opened_date'], '%Y-%m-%d'),
                    end_date='now'
                ).isoformat()
            ])
# Génération des succursales, génération des employé(e)s
def generate_branches(filename, num=10):
    french_cities = [
        "Paris", "Marseille", "Lyon", "Toulouse", "Nice",
        "Nantes", "Strasbourg", "Montpellier", "Bordeaux", "Lille"
    ]
    
    with open(filename, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['branch_id', 'branch_name', 'location'])
        
        for i in range(1, num+1):
            city = french_cities[i-1] if i <= len(french_cities) else fake.city()
            writer.writerow([
                i,
                f"Agence {city}",
                city
            ])

def generate_employees(filename, branches_file, num=50):
    positions = ['Conseiller', 'Directeur', 'Caissier']
    
    with open(branches_file, 'r') as f:
        branch_ids = [row['branch_id'] for row in csv.DictReader(f)]
    
    with open(filename, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['employee_id', 'branch_id', 'name', 'position'])
        
        employee_id = 1
        for branch_id in branch_ids:
            # Un directeur par agence
            writer.writerow([
                employee_id,
                branch_id,
                fake.name(),
                'Directeur'
            ])
            employee_id += 1
            
            # 3-5 employés par agence
            num_employees = random.randint(3, 5)
            for _ in range(num_employees):
                writer.writerow([
                    employee_id,
                    branch_id,
                    fake.name(),
                    random.choices(
                        ['Conseiller', 'Caissier'],
                        weights=[70, 30],
                        k=1
                    )[0]
                ])
                employee_id += 1
                if employee_id > num:
                    return

if __name__ == '__main__':
    generate_customers('customers.csv')
    generate_branches('branches.csv')          # Nouveau
    generate_accounts('accounts.csv', 'customers.csv')
    generate_employees('employees.csv', 'branches.csv')  # Nouveau
    generate_transactions('transactions.csv', 'accounts.csv')