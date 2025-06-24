# Database Folder

> **Note:** The following instructions are for Windows Command Prompt (cmd.exe) and PowerShell. Use the command appropriate for your shell.

This folder contains all SQL files related to the game backend's database schema, static data, test data, and useful queries for development and debugging.

## Contents

- `schema.sql` — Full database schema (tables, enums, relationships).
- `01_game_definitions.sql` — Inserts static game data (characters, items, abilities, etc.).
- `02_player_data.sql` — Inserts example/test player data.
- `03_test_queries.sql` — Example/test queries for development.
- `query_accounts_items.sql` — Lists all accounts and their items (bindings and accessories).
- `query_accounts_characters.sql` — Lists all accounts with their characters and character details.
- `query_accounts_inventory.sql` — Lists all accounts with their currencies, bindings, and accessories.
- `schema-diagram.drawio` / `schema-diagram.drawio.png` — Visual ER diagram of the schema.

## Running Queries in Docker

To run a SQL file against your running Postgres container, use the appropriate one-liner for your shell:

### **Command Prompt (cmd.exe):**
```cmd
docker exec -i template_nk_postgres psql -U postgres -d nakama < database\query_accounts_characters.sql
```

### **PowerShell:**
```powershell
Get-Content database\query_accounts_characters.sql | docker exec -i template_nk_postgres psql -U postgres -d nakama
```

Replace `query_accounts_characters.sql` with any SQL file you want to run.

## File Usage Summary

- **schema.sql**: Run once to create all tables and types.
- **01_game_definitions.sql**: Run after schema.sql to populate static game data.
- **02_player_data.sql**: Run to insert example player accounts and inventory.
- **03_test_queries.sql**: Contains various test queries for development.
- **query_accounts_items.sql**: Shows all accounts and their owned items.
- **query_accounts_characters.sql**: Shows all accounts and their characters.
- **query_accounts_inventory.sql**: Shows all accounts with their currencies, bindings, and accessories.
- **schema-diagram.drawio / .png**: Entity-relationship diagram for visual reference.

---

modify or create new SQL queries in this folder to help with debugging, analytics, or data migration as your game evolves. 