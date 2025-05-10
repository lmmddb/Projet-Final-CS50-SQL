----------------------------------------
-- Opérations CRUD de base par table --
----------------------------------------

-- 1. Clients (Customer)
-- Créer un client
INSERT INTO Customer (first_name, last_name, email, phone, address)
VALUES ('Émilie', 'Durand', 'emilie.durand@example.com', '+33 6 12 34 56 78', '18 Rue du Commerce, Paris');

-- Lire les clients d'une ville
SELECT * FROM Customer 
WHERE address LIKE '%Paris%';

-- Mettre à jour un email
UPDATE Customer SET email = 'nouvel.email@example.com' 
WHERE customer_id = 101;

-- Supprimer un client (cascade vers Account)
DELETE FROM Customer 
WHERE customer_id = 102;

----------------------------------------
-- 2. Comptes (Account) & Transactions --
----------------------------------------

-- Ouvrir un compte épargne
INSERT INTO Account (customer_id, account_type, balance)
VALUES (
    (SELECT customer_id FROM Customer WHERE email = 'emilie.durand@example.com'),
    'Savings',
    5000.00
);

-- Consulter le solde total d'un client
SELECT 
    c.first_name || ' ' || c.last_name AS client,
    SUM(a.balance) AS solde_total
FROM Account a
JOIN Customer c ON a.customer_id = c.customer_id
WHERE c.email = 'emilie.durand@example.com';

-- Effectuer un virement sécurisé
BEGIN TRANSACTION;
UPDATE Account SET balance = balance - 200 WHERE account_number = 1001;
UPDATE Account SET balance = balance + 200 WHERE account_number = 2002;
INSERT INTO Transactions (account_number, amount, transaction_type)
VALUES (1001, -200, 'Transfer'), (2002, 200, 'Transfer');
COMMIT;

----------------------------------------
-- 3. Succursales (Branch) & Employés --
----------------------------------------

-- Trouver l'agence d'un employé
SELECT 
    e.name AS employé,
    b.branch_name AS agence,
    b.location AS ville
FROM Employee e
JOIN Branch b ON e.branch_id = b.branch_id
WHERE e.name = 'Jérôme Morel de Morel';

-- Compter les employé(e)s par agence
SELECT 
    b.branch_name,
    COUNT(e.employee_id) AS nombre_employés,
    SUM(CASE WHEN e.position = 'Conseiller' THEN 1 ELSE 0 END) AS conseillers
FROM Branch b
LEFT JOIN Employee e ON b.branch_id = e.branch_id
GROUP BY b.branch_id;

----------------------------------------
-- Requêtes Analytiques Avancées --
----------------------------------------

-- 1. Détection de fraudes : Transactions > 5000€
SELECT 
    t.transaction_date,
    a.account_number,
    t.amount,
    c.first_name || ' ' || c.last_name AS client,
    b.branch_name AS agence
FROM Transactions t
JOIN Account a ON t.account_number = a.account_number
JOIN Customer c ON a.customer_id = c.customer_id
JOIN Branch b ON branch_id = b.branch_id
WHERE ABS(t.amount) > 5000
ORDER BY t.transaction_date DESC;

-- 2. Calcul des intérêts mensuels (taux 1.5%)
UPDATE Account
SET balance = balance * 1.015
WHERE account_type = 'Savings' 
  AND opened_date < DATE('now', '-1 month');

-- 3. Gestion des prêts en retard
SELECT 
    c.customer_id,
    c.last_name,
    a.account_number,
    a.balance AS dette,
    DATE(a.opened_date, '+6 months') AS échéance
FROM Account a
JOIN Customer c ON a.customer_id = c.customer_id
WHERE a.account_type = 'Loan'
  AND a.balance < -1000
  AND DATE(a.opened_date, '+6 months') < DATE('now');

----------------------------------------
-- Maintenance de la Base de Données --
----------------------------------------

-- Archivage des vieilles transactions (>2 ans)
CREATE TABLE ArchiveTransactions AS
SELECT * FROM Transactions 
WHERE transaction_date < DATE('now', '-2 years');

DELETE FROM Transactions 
WHERE transaction_date < DATE('now', '-2 years');

-- Reconstruction des index
REINDEX idx_customer_email;

-- Exemple de problème qui s'est posé lors de la confection de la table : une erreur de génération dans la table "accounts" à passer les prêts
-- au positif au lieu d'être des comptes créditeurs il fallait donc corriger les 29 comptes invalides et les réinsérer.

INSERT INTO Account (account_number, customer_id, account_type, balance, opened_date)
VALUES 
-- Format : (num_compte, client_id, 'Loan', -montant, date)
(1001, 41, 'Loan', -2849.66, '2023-05-05'),
(1020, 156, 'Loan', -3828.61, '2022-10-07'),
(1046, 76, 'Loan', -7869.90, '2022-08-29'),
(1049, 191, 'Loan', -16223.11, '2022-08-18'),
(1066, 11, 'Loan', -7958.09, '2021-04-15'),
(1082, 16, 'Loan', -14552.02, '2022-01-05'),
(1090, 7, 'Loan', -9628.43, '2022-11-08'),
(1092, 63, 'Loan', -7588.27, '2025-03-10'),
(1101, 141, 'Loan', -2424.70, '2023-08-14'),
(1142, 173, 'Loan', -10286.43, '2022-08-15'),
(1154, 193, 'Loan', -8119.84, '2025-01-26'),
(1163, 6, 'Loan', -5624.68, '2020-11-01'),
(1180, 39, 'Loan', -6672.96, '2020-08-13'),
(1196, 179, 'Loan', -15418.54, '2025-05-02'),
(1199, 31, 'Loan', -19963.73, '2025-05-02'),
(1248, 93, 'Loan', -22501.24, '2023-12-25'),
(1278, 68, 'Loan', -6358.27, '2025-03-13'),
(1325, 126, 'Loan', -11383.94, '2024-11-01'),
(1340, 130, 'Loan', -15265.31, '2024-09-12'),
(1378, 143, 'Loan', -6593.35, '2021-03-15'),
(1383, 103, 'Loan', -14098.06, '2024-11-04'),
(1405, 117, 'Loan', -15159.38, '2024-06-26'),
(1414, 130, 'Loan', -7688.53, '2021-03-23'),
(1416, 135, 'Loan', -9915.25, '2023-05-24'),
(1447, 148, 'Loan', -216.86, '2022-01-27'),
(1457, 45, 'Loan', -5730.62, '2020-09-24'),
(1491, 56, 'Loan', -20447.06, '2022-03-24'),
(1492, 96, 'Loan', -3342.88, '2023-12-20'),
(1497, 78, 'Loan', -17466.98, '2022-08-20');