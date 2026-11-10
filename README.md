# VaxAssist

Vaccination and preventive immunisation portal (5027CMD Web Development). Patients, doctors and admins share one MySQL database.

## Database (everyone uses the same one)

`vaxassist_db.sql` is the single source of truth. It creates every table, the reference data (vaccines, destinations, childhood schedule) and the demo data. The demo logins are listed in the comment block inside that file.

Rebuild your local database from it. **This replaces everything in your local `vaxassist_db`.**

```bash
/Applications/XAMPP/xamppfiles/bin/mysql -uroot -e "DROP DATABASE IF EXISTS vaxassist_db; CREATE DATABASE vaxassist_db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci" && /Applications/XAMPP/xamppfiles/bin/mysql -uroot vaxassist_db < vaxassist_db.sql
```

Or in phpMyAdmin: drop `vaxassist_db`, create it again (utf8mb4_general_ci), then Import the file.

Rules so the database stays the same for everyone:

- Change the database by editing `vaxassist_db.sql` and committing it. Do not re-export it from phpMyAdmin over the top; an export can drop primary keys, auto-increment and foreign keys.
- Never create or alter tables from PHP at run time. Put the table in `vaxassist_db.sql`.
- After importing, check it: `SELECT doctor_id FROM doctors;` must show 1 to 9 (never 0), and `SHOW CREATE TABLE doctors;` must contain `PRIMARY KEY` and `AUTO_INCREMENT`.

## Run the site locally

1. Start MySQL in XAMPP.
2. In this folder run `./start-server.command` (or `php -S 127.0.0.1:8000 router.php`).
3. Open http://127.0.0.1:8000/

## Doctor notifications

Doctor alerts use the existing `notifications` table and are separated from patient alerts with `recipient_type`. For an existing database, import `doctor_notifications_migration.sql` once in phpMyAdmin with `vaxassist_db` selected. A fresh database import uses the updated `vaxassist_db.sql`.

