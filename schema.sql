-- Activer les clés étrangères
PRAGMA foreign_keys = ON;

-- Table des clients
CREATE TABLE IF NOT EXISTS Customer (
    customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL CHECK(email LIKE '%@%'),
    phone TEXT,
    address TEXT
);

-- Table des succursales
CREATE TABLE IF NOT EXISTS Branch (
    branch_id INTEGER PRIMARY KEY AUTOINCREMENT,
    branch_name TEXT NOT NULL UNIQUE,
    location TEXT NOT NULL
);

-- Table des comptes
CREATE TABLE IF NOT EXISTS Account (
    account_number INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    account_type TEXT NOT NULL CHECK(account_type IN ('Checking', 'Savings', 'Loan')),
    balance DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK(
        (account_type IN ('Checking', 'Savings') AND balance >= 0) OR
        (account_type = 'Loan' AND balance <= 0)
    ),
    opened_date DATE DEFAULT CURRENT_DATE,
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) ON DELETE CASCADE
);

-- Table des transactions
CREATE TABLE IF NOT EXISTS Transactions (
    transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_number INTEGER NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK(amount != 0),
    transaction_type TEXT NOT NULL CHECK(transaction_type IN ('Deposit', 'Withdrawal', 'Transfer')),
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_number) REFERENCES Account(account_number) ON DELETE CASCADE
);

-- Table des employé(e)s
CREATE TABLE IF NOT EXISTS Employee (
    employee_id INTEGER PRIMARY KEY AUTOINCREMENT,
    branch_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    position TEXT NOT NULL CHECK(position IN ('Conseiller', 'Directeur', 'Caissier')),
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id) ON DELETE CASCADE
);

-- Index pour optimisation
CREATE INDEX IF NOT EXISTS idx_customer_email ON Customer(email);
CREATE INDEX IF NOT EXISTS idx_account_balance ON Account(balance);
CREATE INDEX IF NOT EXISTS idx_transaction_dates ON Transactions(transaction_date);
CREATE INDEX IF NOT EXISTS idx_branch_location ON Branch(location);
CREATE INDEX IF NOT EXISTS idx_employee_position ON Employee(position);
