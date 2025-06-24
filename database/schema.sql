-- SQL Schema for Turn-Based PVE Mobile Game
-- This file contains ENUM definitions and TABLE creations.
-- It's generally recommended to create ENUMs before tables that use them.
-- This schema supports a complete game structure with characters, equipment, currencies and player progression.

-- #############################################################################
-- # ENUM Type Definitions
-- # These define the fixed categorizations used throughout the game systems
-- #############################################################################

-- ENUM: currency_type_enum
-- Represents the types of currencies available in the game.
-- Used for economy management and player transactions.
CREATE TYPE currency_type_enum AS ENUM (
    'GOLD',            -- Basic in-game currency earned through regular gameplay
    'GEMS',            -- Premium currency potentially tied to monetization
    'EVENT_TOKEN_A'    -- Special currency for limited-time events
);

-- ENUM: element_type_enum
-- Used for resistances and damage types (shared by characters, bindings, etc.).
-- These represent the primary elemental affinities for combat calculations and character specializations.
CREATE TYPE element_type_enum AS ENUM (
    'FIRE',
    'ICE',
    'ELECTRIC',
    'LIGHT',
    'DARK'
);

-- ENUM: stat_enum
-- Used for character attributes and general stat targets in effects.
-- These values represent all possible attributes that can be modified by equipment, abilities, or effects.
CREATE TYPE stat_enum AS ENUM (
    'SPEED',
    'MAX_HEALTH',
    'ATTACK_DAMAGE',
    'DEFENSE',
    'SHIELD_DECAY_RATE',
    'MAX_MANA',
    'MANA_REGENERATE',
    'MAX_ENERGY',
    'ENERGY_REGENERATE',
    'FIRE_RESISTANCE',
    'ICE_RESISTANCE',
    'ELECTRIC_RESISTANCE',
    'LIGHT_RESISTANCE',
    'DARK_RESISTANCE',
    'ALL_TYPE_RESISTANCE',
    'FIRE_AD',
    'ICE_AD',
    'ELECTRIC_AD',
    'LIGHT_AD',
    'DARK_AD',
    'ALL_TYPE_AD'
);

-- ENUM: binding_damage_type_enum
-- For Binding Damage Types
-- Determines the type of damage a weapon deals and how it interacts with defenses.
CREATE TYPE binding_damage_type_enum AS ENUM (
    'TRUE_DMG',      -- Cannot be reduced by normal defenses, only affected by specific damage resistance
    'PIERCING',      -- Effective against Shield, affected by Defense
    'SMASHING',      -- Effective against Health, affected by Defense
    'SLASHING',      -- Basic physical damage type, affected by Defense
    'FIRE_ELEMENTAL',     -- Fire elemental damage, affected by Fire resistance
    'ICE_ELEMENTAL',      -- Ice elemental damage, affected by Ice resistance
    'ELECTRIC_ELEMENTAL', -- Electric elemental damage, affected by Electric resistance
    'LIGHT_ELEMENTAL',    -- Light elemental damage, affected by Light resistance
    'DARK_ELEMENTAL'      -- Dark elemental damage, affected by Dark resistance
);

-- ENUM: accessory_slot_enum
-- For Accessory Slots
-- Defines which position an accessory can be equipped to on a character.
-- Each slot type has specific stat affinities as per game design.
CREATE TYPE accessory_slot_enum AS ENUM (
    'LEFT',
    'MIDDLE',
    'RIGHT'
);

-- ENUM: effect_category_enum
-- For Enchantment/Curse Category
-- Classifies special effects applied to accessories.
CREATE TYPE effect_category_enum AS ENUM (
    'ENCHANTMENT', -- Positive effects that enhance stats
    'CURSE'        -- Negative effects that may have powerful positive trade-offs
);

-- ENUM: ability_type_enum
-- For Ability Types
-- Determines how an ability is used in combat.
CREATE TYPE ability_type_enum AS ENUM (
    'PASSIVE', -- Always active, doesn't require activation
    'ACTIVE'   -- Must be explicitly used, consumes resources
);

-- ENUM: ability_target_type_enum
-- For Ability Target Types
-- Defines the valid targeting options for active abilities.
-- This determines which entities an ability can affect during combat.
CREATE TYPE ability_target_type_enum AS ENUM (
    'SELF',             -- Affects the caster only (e.g., self-heal, shield)
    'SINGLE_ENEMY',     -- Affects one enemy target (e.g., direct damage spell)
    'GROUP_ENEMY',      -- Affects multiple/all enemy targets (AoE damage)
    'SINGLE_ALLY',      -- Affects one friendly target excluding self (e.g., heal ally)
    'GROUP_ALLY',       -- Affects multiple/all friendly targets excluding self (e.g., party buff)
    'SELF_AND_SINGLE_ALLY', -- For abilities that can focus on self OR an ally (flexible healing)
    'SELF_AND_GROUP_ALLY'   -- For abilities that affect self AND all allies (party-wide buffs including caster)
    -- can add more specific types like 'LOWEST_HP_ENEMY', 'HIGHEST_THREAT_ENEMY', etc. if needed
);


-- #############################################################################
-- # Static Definition Tables
-- # (Data in these tables rarely changes, typically only with game patches)
-- #############################################################################

-- Table: currency_definitions
-- Defines the types of currencies available in the game.
-- These currencies are used for various in-game transactions and economy management.
CREATE TABLE currency_definitions (
    id SMALLSERIAL PRIMARY KEY,
    currency_code currency_type_enum NOT NULL UNIQUE, -- References the enum for currency types
    name VARCHAR(50) NOT NULL,                        -- Display name (e.g., "Gold Coins", "Premium Gems")
    description TEXT,                                 -- Detailed description of currency usage
    icon_url TEXT,                                    -- URL/path to the currency icon
    max_cap BIGINT DEFAULT 65565                      -- Maximum amount a player can hold (prevents overflow)
);

-- Table: ability_definitions
-- Defines all possible abilities characters can have.
-- These are the core combat actions and passive effects available to characters.
CREATE TABLE ability_definitions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,             -- Unique ability name
    description TEXT NOT NULL,                     -- Detailed ability description
    icon_url TEXT,                                 -- URL/path to ability icon
    ability_type ability_type_enum NOT NULL,       -- Whether passive (always active) or active (must be used)
    target_type ability_target_type_enum,          -- Who/what the ability can target (NULL for passives)
    speed_cost INT DEFAULT 0,                      -- Speed points consumed (affects turn order)
    mana_cost INT,                                 -- Mana required (for spellcasters)
    energy_cost INT,                               -- Energy required (for physical fighters)
    recharge_time INT DEFAULT 0,                   -- Cooldown in turns before ability can be used again
    -- Add other fields as needed: range, area_of_effect_shape, animation_id, effect_script_id etc.

    -- Constraints to enforce ability design rules
    CONSTRAINT chk_ability_costs CHECK (
        (mana_cost IS NULL OR energy_cost IS NULL) AND -- Cannot have both mana and energy cost
        (ability_type = 'PASSIVE' OR speed_cost >= 0) AND
        (ability_type = 'PASSIVE' OR recharge_time >= 0)
    ),
    CONSTRAINT chk_target_type_for_active CHECK (
        (ability_type = 'ACTIVE' AND target_type IS NOT NULL) OR (ability_type = 'PASSIVE' AND target_type IS NULL)
    ) -- Active abilities must have a target type, passives shouldn't.
);

-- Table: character_definitions
-- Defines the archetypes of characters.
-- These are the templates for playable characters with their base stats and abilities.
CREATE TABLE character_definitions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,   -- Character archetype name
    description TEXT,                    -- Character background and description
    icon_url TEXT,                       -- URL/path to a character portrait
    model_url TEXT,                      -- URL/path to 3D model or sprite sheet

    -- Base Attributes (Values at Level 1)
    -- These determine the character's combat effectiveness
    base_speed INT NOT NULL CHECK (base_speed > 0),                  -- Initiative/turn order
    base_max_health INT NOT NULL CHECK (base_max_health > 0),        -- Survival capability
    base_attack_damage INT NOT NULL CHECK (base_attack_damage >= 0), -- Base damage output
    base_defense INT NOT NULL CHECK (base_defense >= 0),             -- Damage reduction

    -- Elemental resistances (percentage-based damage reduction)
    base_resistance_fire INT NOT NULL DEFAULT 0,
    base_resistance_ice INT NOT NULL DEFAULT 0,
    base_resistance_electric INT NOT NULL DEFAULT 0,
    base_resistance_light INT NOT NULL DEFAULT 0,
    base_resistance_dark INT NOT NULL DEFAULT 0,
    
    -- Shield mechanics
    base_shield_decay_rate DECIMAL(5,2) NOT NULL DEFAULT 0.00
        CHECK (base_shield_decay_rate >= 0 AND base_shield_decay_rate <= 1.00), -- e.g., 0.10 for 10% decay per turn

    -- Resource System - Characters use either mana or energy
    has_mana BOOLEAN NOT NULL DEFAULT FALSE,        -- Whether a character uses mana for abilities
    base_max_mana INT,                              -- Max mana pool if the has_mana is true
    base_mana_regenerate INT,                       -- Mana recovered per turn if the has_mana is true
    has_energy BOOLEAN NOT NULL DEFAULT FALSE,      -- Whether character uses energy for abilities
    base_max_energy INT,                            -- Max energy pool if the has_energy is true
    base_energy_regenerate INT,                     -- Energy recovered per turn if the has_energy is true

    -- Abilities (Fixed 5 slots per character definition)
    -- These define what the character can do in combat
    ability_slot_1_id INT NOT NULL REFERENCES ability_definitions(id),
    ability_slot_2_id INT NOT NULL REFERENCES ability_definitions(id),
    ability_slot_3_id INT NOT NULL REFERENCES ability_definitions(id),
    ability_slot_4_id INT NOT NULL REFERENCES ability_definitions(id),
    ability_slot_5_id INT NOT NULL REFERENCES ability_definitions(id),
    
    -- Constraints to enforce character design rules
    CONSTRAINT chk_resource_system CHECK (
        NOT (has_mana AND has_energy) AND -- Character can't use both mana and energy systems
        ((has_mana AND base_max_mana IS NOT NULL AND base_mana_regenerate IS NOT NULL) OR (NOT has_mana)) AND
        ((has_energy AND base_max_energy IS NOT NULL AND base_energy_regenerate IS NOT NULL) OR (NOT has_energy))
    ),
    CONSTRAINT uq_character_abilities UNIQUE (ability_slot_1_id, ability_slot_2_id, ability_slot_3_id, ability_slot_4_id, ability_slot_5_id) -- Ensure ability combination is unique
);

-- Table: special_effect_definitions (for Bindings)
-- Defines potential special effects on bindings.
CREATE TABLE special_effect_definitions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NOT NULL
    -- Add structured fields for effect logic, e.g.:
    -- trigger_condition VARCHAR(50), -- ON_HIT, ON_CRIT, etc.
    -- effect_type VARCHAR(50), -- APPLY_DOT, HEAL_SELF, REDUCE_TARGET_DEFENSE
    -- effect_value_1 DECIMAL(10,2),
    -- effect_duration_turns INT
);

-- Table: binding_definitions
-- Defines the types of bindings (weapons).
CREATE TABLE binding_definitions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon_url TEXT,
    model_url TEXT,
    base_attack_power INT NOT NULL DEFAULT 0, -- The binding's own contribution to damage, distinct from character AD
    damage_type binding_damage_type_enum NOT NULL,
    special_effect_id INT REFERENCES special_effect_definitions(id) ON DELETE SET NULL -- Can have one predefined special effect
    -- Add base stats this binding might provide, e.g., base_crit_chance_bonus
);

-- Table: set_effect_definitions (for Accessories)
-- Defines accessory set names and thematic grouping.
CREATE TABLE set_effect_definitions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE, -- e.g., "Guardian's Resolve Set"
    description TEXT -- Overall theme of the set
);

-- Table: set_effect_bonuses
-- Defines the actual bonuses for wearing multiple pieces of a set.
CREATE TABLE set_effect_bonuses (
    id SERIAL PRIMARY KEY,
    set_effect_id INT NOT NULL REFERENCES set_effect_definitions(id) ON DELETE CASCADE,
    required_pieces SMALLINT NOT NULL CHECK (required_pieces > 0 AND required_pieces <= 3), -- Assuming max 3 accessories for a set
    bonus_description TEXT NOT NULL,
    bonus_stat_target stat_enum NOT NULL,
    bonus_stat_modifier_type VARCHAR(10) NOT NULL DEFAULT 'PERCENTAGE' CHECK (bonus_stat_modifier_type IN ('PERCENTAGE', 'FLAT')),
    bonus_stat_modifier_value DECIMAL(10,2) NOT NULL, -- e.g., 10.00 for 10% or a flat value
    UNIQUE (set_effect_id, required_pieces, bonus_stat_target) -- Avoid duplicate bonuses for same piece count and target
);

-- Table: accessory_definitions
-- Defines types of accessories.
CREATE TABLE accessory_definitions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    icon_url TEXT,
    model_url TEXT,
    slot_type accessory_slot_enum NOT NULL, -- LEFT, MIDDLE, or RIGHT
    -- The primary stat affected by this accessory type as per design (Left: AD, Middle: Max Health, Right: Defense)
    -- This information is more for design guidance; actual stat bonuses are through enchantments or base stats
    base_attack_damage_bonus INT DEFAULT 0,
    base_max_health_bonus INT DEFAULT 0,
    base_defense_bonus INT DEFAULT 0,
    set_effect_id INT REFERENCES set_effect_definitions(id) ON DELETE SET NULL -- Which set this accessory belongs to
    -- Enchantment/Curse pools can be linked here if specific accessory types draw from limited pools
);

-- Table: enchantment_curse_definitions
-- Defines the possible enchantments and curses for accessories.
CREATE TABLE enchantment_curse_definitions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    category effect_category_enum NOT NULL, -- 'ENCHANTMENT' or 'CURSE'

    -- For direct stat modifications
    target_stat_1 stat_enum,
    modifier_percentage_1 DECIMAL(5,2), -- e.g., 10.00 for +10%, -10.00 for -10%
    
    target_stat_2 stat_enum,            -- For curses with two effects
    modifier_percentage_2 DECIMAL(5,2),

    -- For transformation effects
    transforms_from_stat stat_enum,
    transforms_to_stat stat_enum,
    is_transformation BOOLEAN NOT NULL DEFAULT FALSE,
    
    CONSTRAINT chk_effect_structure CHECK (
        (is_transformation = FALSE AND target_stat_1 IS NOT NULL AND modifier_percentage_1 IS NOT NULL) OR
        (is_transformation = TRUE AND transforms_from_stat IS NOT NULL AND transforms_to_stat IS NOT NULL)
    )
);


-- #############################################################################
-- # Player-Specific Data Tables
-- # (Data in these tables changes frequently based on player actions)
-- #############################################################################

-- Table: accounts
-- Stores user account information.
CREATE TABLE accounts (
    id BIGSERIAL PRIMARY KEY,
    nakama_user_id UUID UNIQUE,   -- Foreign key to Nakama's user system
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_login_at TIMESTAMPTZ
);

-- Table: player_currencies (Player's Wallet - Join Table)
-- Stores how much of each currency a player owns.
CREATE TABLE player_currencies (
    account_id BIGINT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    currency_definition_id SMALLINT NOT NULL REFERENCES currency_definitions(id) ON DELETE RESTRICT,
    amount BIGINT NOT NULL DEFAULT 0 CHECK (amount >= 0),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (account_id, currency_definition_id) -- Composite primary key
);

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


-- Add this to schema.sql or run as an ALTER TABLE statement
-- if the table already exists and not doing a full reset.
-- Best to add it during initial schema creation.
ALTER TABLE accounts
ADD COLUMN nakama_user_id UUID UNIQUE, -- Nakama uses UUIDs for its user IDs
ADD CONSTRAINT uq_nakama_user_id UNIQUE (nakama_user_id); -- Ensure it's unique

-- Optional: Add an index for faster lookups by nakama_user_id
CREATE INDEX idx_accounts_nakama_user_id ON accounts(nakama_user_id);


-- #############################################################################
-- # Indexes (Illustrative - add more based on query patterns)
-- #############################################################################

-- accounts table
CREATE INDEX idx_accounts_username ON accounts(username);
CREATE INDEX idx_accounts_email ON accounts(email);

-- player_currencies table
CREATE INDEX idx_player_currencies_currency_id ON player_currencies(currency_definition_id);

-- player_characters table
CREATE INDEX idx_player_characters_account_id ON player_characters(account_id);
CREATE INDEX idx_player_characters_char_def_id ON player_characters(character_definition_id);

-- player_bindings table
CREATE INDEX idx_player_bindings_account_id ON player_bindings(account_id);
CREATE INDEX idx_player_bindings_binding_def_id ON player_bindings(binding_definition_id);

-- player_accessories table
CREATE INDEX idx_player_accessories_account_id ON player_accessories(account_id);
CREATE INDEX idx_player_accessories_acc_def_id ON player_accessories(accessory_definition_id);

-- #############################################################################
-- # Potential Future Tables (Not fully defined here)
-- #############################################################################
-- player_character_active_abilities (if abilities can be leveled independently or swapped beyond the 5 fixed)
-- player_quests (tracking active and completed quests)
-- growth_curves (for character/item stat progression per level)
-- mail (player in-game mail system)
-- friends (social features)
-- leaderboards