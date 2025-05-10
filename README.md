# Projet Final CS50 SQL – Gestion Bancaire

## 📘 Présentation

Ce projet constitue le travail final du cours **CS50’s Introduction to Databases with SQL**. Il s'agit d'une base de données relationnelle simulant le système d'information d'une banque. Le projet permet de gérer les clients, les comptes, les employés, les agences et les transactions, tout en offrant des scripts pour la création, l'alimentation et l'interrogation de la base de données.

## 🗂️ Structure du dépôt

* `schema.sql` : Définit la structure de la base de données (tables, clés primaires et étrangères, contraintes).
* `script.sql` : Contient des requêtes SQL pour interroger la base de données (extractions, agrégations, jointures).
* `bank.db` : Fichier SQLite contenant la base de données complète.
* `customers.csv`, `accounts.csv`, `employees.csv`, `branches.csv`, `transactions.csv` : Fichiers CSV utilisés pour peupler la base de données.
* `CréateurBD.py`, `GénérateurCompte.py`, `GénérateurRandom.py` : Scripts Python pour générer automatiquement des données réalistes.
* `Projet SQL_DJAU_Mamadou.pdf` : Document de conception détaillant le modèle relationnel et les choix techniques.
* `README.md` : Ce fichier.

## Modèle relationnel

La base de données est composée des entités suivantes :

* **Customers** : Informations personnelles des clients.
* **Accounts** : Comptes bancaires associés aux clients.
* **Employees** : Données des employés de la banque.
* **Branches** : Agences bancaires.
* **Transactions** : Historique des opérations financières.

Les relations entre ces entités sont définies à l'aide de clés étrangères pour assurer l'intégrité référentielle.

## ⚙️ Installation et utilisation

1. **Cloner le dépôt :**

   ```bash
   git clone https://github.com/lmmddb/Projet-Final-CS50-SQL.git
   cd Projet-Final-CS50-SQL
   ```



2. **Créer la base de données :**

   ```bash
   sqlite3 bank.db < schema.sql
   ```



3. **Importer les données :**

   ```bash
   sqlite3 bank.db
   .mode csv
   .import customers.csv customers
   .import accounts.csv accounts
   .import employees.csv employees
   .import branches.csv branches
   .import transactions.csv transactions
   .exit
   ```



4. **Exécuter les requêtes :**

   ```bash
   sqlite3 bank.db < script.sql
   ```



## 🧪 Exemples de requêtes

* Lister les clients ayant effectué des transactions supérieures à 10 000 € :

```sql
  SELECT c.name, t.amount
  FROM customers c
  JOIN transactions t ON c.id = t.customer_id
  WHERE t.amount > 10000;
```



* Afficher le solde moyen par agence :

```sql
  SELECT b.name, AVG(a.balance) as average_balance
  FROM branches b
  JOIN accounts a ON b.id = a.branch_id
  GROUP BY b.name;
```



## 📄 Documentation

Pour une description détaillée du modèle de données, des contraintes d'intégrité et des choix de conception, veuillez consulter le document [Projet SQL\_DJAU\_Mamadou.pdf](./Projet%20SQL_DJAU_Mamadou.pdf).

---
