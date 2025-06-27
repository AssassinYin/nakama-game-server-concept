# Database Schema

This folder contains the core database schema definition for the game backend's PostgreSQL database.

## Schema Overview

The schema includes:
- **Player Management**: Accounts, characters, and player progression
- **Game Items**: Equipment, accessories, and item bindings
- **Game Economy**: Currencies and inventory management

## Database Tables

### `accounts`
```sql
-- Table: accounts
-- Stores user account information.
CREATE TABLE accounts (
                          id BIGSERIAL PRIMARY KEY,
                          nakama_user_id UUID UNIQUE,   -- Foreign key to Nakama's user system
                          created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                          updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                          last_login_at TIMESTAMPTZ
);
```

### `player_currencies`
```sql
-- Table: player_currencies (Player's Wallet - Join Table)
-- Stores how much of each currency a player owns.
CREATE TABLE player_currencies (
                                   account_id BIGINT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
                                   currency_definition_id SMALLINT NOT NULL REFERENCES currency_definitions(id) ON DELETE RESTRICT,
                                   amount BIGINT NOT NULL DEFAULT 0 CHECK (amount >= 0),
                                   updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                                   PRIMARY KEY (account_id, currency_definition_id) -- Composite primary key
);
```

### `player_bindings`
```sql
-- Table: player_bindings (Player-Owned Binding Instances)
-- Specific instances of bindings owned by players.
CREATE TABLE player_bindings (
                                 id BIGSERIAL PRIMARY KEY,
                                 account_id BIGINT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE, -- Who owns this item
                                 binding_definition_id INT NOT NULL REFERENCES binding_definitions(id) ON DELETE RESTRICT, -- FK to static data

                                 level SMALLINT NOT NULL DEFAULT 1 CHECK (level BETWEEN 1 AND 100), -- Assuming items also cap at 100
                                 xp BIGINT NOT NULL DEFAULT 0 CHECK (xp >= 0),
    -- Potentially store rolled stats if they deviate from definition + level formula
    -- e.g., specific_attack_power_override INT, if an instance can have slightly different stats

                                 created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                                 updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### `player_accessories`
```sql
-- Table: player_accessories (Player-Owned Accessory Instances)
-- Specific instances of accessories owned by players.
CREATE TABLE player_accessories (
                                    id BIGSERIAL PRIMARY KEY,
                                    account_id BIGINT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE, -- Who owns this item
                                    accessory_definition_id INT NOT NULL REFERENCES accessory_definitions(id) ON DELETE RESTRICT, -- FK to static data

                                    level SMALLINT NOT NULL DEFAULT 1 CHECK (level BETWEEN 1 AND 100),
                                    xp BIGINT NOT NULL DEFAULT 0 CHECK (xp >= 0),

    -- Up to 2 enchantments OR 1 curse (as per your design)
                                    enchantment_1_id INT REFERENCES enchantment_curse_definitions(id) ON DELETE SET NULL,
                                    enchantment_2_id INT REFERENCES enchantment_curse_definitions(id) ON DELETE SET NULL,
                                    curse_id INT REFERENCES enchantment_curse_definitions(id) ON DELETE SET NULL,

                                    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                                    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### `player_characters`
```sql
-- Table: player_characters (Player-Owned Character Instances)
-- Stores instances of characters owned by players.
CREATE TABLE player_characters (
                                   id BIGSERIAL PRIMARY KEY,
                                   account_id BIGINT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
                                   character_definition_id INT NOT NULL REFERENCES character_definitions(id) ON DELETE RESTRICT, -- FK to static data

                                   nickname VARCHAR(50), -- Optional, if players can name their characters
                                   level SMALLINT NOT NULL DEFAULT 1 CHECK (level BETWEEN 1 AND 100),
                                   xp BIGINT NOT NULL DEFAULT 0 CHECK (xp >= 0), -- XP towards the next level

    -- Equipment slots (references to player-owned item instances)
                                   equipped_binding_id BIGINT UNIQUE REFERENCES player_bindings(id) ON DELETE SET NULL, -- A binding can only be equipped by one char at a time
                                   equipped_accessory_left_id BIGINT UNIQUE REFERENCES player_accessories(id) ON DELETE SET NULL,
                                   equipped_accessory_middle_id BIGINT UNIQUE REFERENCES player_accessories(id) ON DELETE SET NULL,
                                   equipped_accessory_right_id BIGINT UNIQUE REFERENCES player_accessories(id) ON DELETE SET NULL,

    -- Ensure equipped accessories match slot type (can be complex with subqueries, might be better enforced by application logic or triggers)
    -- CONSTRAINT chk_accessory_left_slot CHECK (equipped_accessory_left_id IS NULL OR (SELECT ad.slot_type FROM player_accessories pa JOIN accessory_definitions ad ON pa.accessory_definition_id = ad.id WHERE pa.id = equipped_accessory_left_id) = 'LEFT'),
    -- ... similar for middle and right (these checks can be resource-intensive as constraints)

                                   created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                                   updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    -- Optional constraint: if a player can only own one of each character type.
    -- CONSTRAINT uq_character_per_account_definition UNIQUE (account_id, character_definition_id)
);
```
