# Nakama TypeScript Server Example

This directory contains a **standalone example Nakama server project** with custom TypeScript modules. It demonstrates how to build, run, and extend a multiplayer game backend using [Nakama](https://heroiclabs.com/docs/), a scalable open-source game server.

## Features

- **Custom TypeScript server logic** for player accounts, characters, inventory, and equipment.
- **PostgreSQL** for persistent game data.
- **Docker Compose** for easy local development.
- **Modular RPC system**: Add new server-side features by writing TypeScript functions.

---

## 📦 Project Structure

```
temp-nakama-template/
├── src/                  # TypeScript server logic
│   ├── main.ts           # Registers all RPCs
│   ├── character.ts      # Character creation, retrieval, item swap
│   ├── player.ts         # Player account creation and lookup
│   ├── add_item.ts       # Add weapons (bindings) and accessories
├── Dockerfile            # Nakama server image with custom modules
├── docker-compose.yml    # Runs Nakama + Postgres
├── package.json          # TypeScript dependencies and build scripts
├── tsconfig.json         # TypeScript configuration
├── local.yml             # Nakama server config (optional)
└── ...
```

---

## 🚀 Quick Start

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Node.js](https://nodejs.org/) (for building TypeScript)
- [Nakama documentation](https://heroiclabs.com/docs/)

### 1. Install Dependencies

```bash
cd temp-nakama-template
npm install
```

### 2. Build TypeScript Modules

```bash
npm run build
```

This compiles the TypeScript files in `src/` to JavaScript in `build/`.

### 3. Start the Server

```bash
docker-compose up --build
```

- **Nakama API:** http://localhost:7350
- **Nakama Console:** http://localhost:7351 (default login: admin/password)
- **Postgres:** localhost:5432

---

## 🛠️ Custom Server Logic

The server exposes several **custom RPCs** (Remote Procedure Calls) for game features. These are registered in `src/main.ts` and implemented in the other TypeScript files.

### Registered RPCs

| RPC Name            | Description                                 | Module         |
|---------------------|---------------------------------------------|---------------|
| `add_character`     | Add a new character for a player            | character.ts  |
| `get_characters`    | Get all characters for a player             | character.ts  |
| `swap_character_item` | Swap a character's equipped item          | character.ts  |
| `create_player`     | Create a new player account                 | player.ts     |
| `get_player`        | Get player account info                     | player.ts     |
| `add_binding`       | Add a weapon/binding to a player            | add_item.ts   |
| `add_accessory`     | Add an accessory to a player                | add_item.ts   |

#### Example: Add Character

**Request:**
```json
POST /v2/rpc/add_character
Authorization: Bearer <session_token>
Content-Type: application/json

{
  "characterDefinitionId": 1,
  "nickname": "Hero"
}
```

**Response:**
```json
{
  "success": true,
  "character": { ... }
}
```

#### Example: Add Binding

**Request:**
```json
POST /v2/rpc/add_binding
Authorization: Bearer <session_token>
Content-Type: application/json

{
  "binding_id": 2
}
```

**Response:**
```json
{
  "success": true,
  "binding_id": 2,
  "player_binding_id": 5
}
```

> See the TypeScript files in `src/` for full payload and response details.

---

## 🧩 Extending the Server

To add new features:

1. **Write a new function** in `src/` (see existing files for examples).
2. **Register your function** as an RPC in `InitModule` in `src/main.ts`.
3. **Rebuild the module:**
   ```bash
   npm run build
   ```
4. **Restart Nakama:**
   ```bash
   docker-compose restart nakama
   ```

---

## 🐳 Docker & Configuration

- **Dockerfile**: Builds a Nakama image with your compiled JS modules.
- **docker-compose.yml**: Runs Nakama and Postgres together.
- **local.yml**: (Optional) Nakama config file, can be customized for your needs.

### Environment Variables

You can override Nakama or Postgres settings by editing `docker-compose.yml` or adding a `.env` file.

---

## 🗃️ Database

- Uses **PostgreSQL** for all persistent data.
- Main player-related tables:
  - `accounts`: Stores user account info, linked to Nakama user IDs.
  - `player_characters`: Each row is a character owned by a player, referencing a `character_definition` (archetype/template). Stores nickname, level, XP, and equipped items.
  - `player_bindings`: Player-owned weapons (bindings), referencing a `binding_definition` (static weapon type). Stores level and XP for each binding.
  - `player_accessories`: Player-owned accessories, referencing an `accessory_definition`. Can have enchantments/curses, level, and XP.
  - `player_currencies`: Tracks how much of each currency (gold, gems, etc.) a player owns, referencing `currency_definitions`.
- **Static definition tables** (rarely change):
  - `character_definitions`, `binding_definitions`, `accessory_definitions`, `currency_definitions`, etc. These define the archetypes, items, and currencies available in the game.
- **Relationships:**
  - Each player (`accounts`) can own multiple characters, bindings, accessories, and currencies.
  - Characters can equip one binding (weapon) and up to three accessories (left, middle, right slots).
  - Bindings and accessories reference their static definitions for base stats and properties.

**Example Entity Relationship (simplified):**

```
accounts
  ├── player_characters (character_definition_id → character_definitions)
  ├── player_bindings (binding_definition_id → binding_definitions)
  ├── player_accessories (accessory_definition_id → accessory_definitions)
  └── player_currencies (currency_definition_id → currency_definitions)
```

- All queries are written in TypeScript using Nakama's `nk.sqlQuery` and `nk.sqlExec`.

---

## 📝 License

This project is licensed under the Apache 2.0 License. See the [LICENSE](LICENSE) file for details.

---

## 🙋 Support

- [Nakama Documentation](https://heroiclabs.com/docs/)
- [Nakama Community Forum](https://forum.heroiclabs.com/)
- [GitHub Issues](https://github.com/heroiclabs/nakama/issues)

---

**Happy hacking! Build your own multiplayer game logic with Nakama and TypeScript.** 