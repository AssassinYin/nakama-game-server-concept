-- ############################################################################
-- BACKUP TABLES SCHEMA
-- ############################################################################
-- Create backup tables to store archived data before deletion
-- These tables mirror the structure of the main tables but are for archival purposes

-- Backup table for accounts
CREATE TABLE IF NOT EXISTS archived_accounts (
    id BIGINT PRIMARY KEY,
    nakama_user_id UUID,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    last_login_at TIMESTAMPTZ,
    archived_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Backup table for player currencies
CREATE TABLE IF NOT EXISTS archived_player_currencies (
    account_id BIGINT NOT NULL,
    currency_definition_id SMALLINT NOT NULL,
    amount BIGINT NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    archived_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (account_id, currency_definition_id)
);

-- Backup table for player bindings
CREATE TABLE IF NOT EXISTS archived_player_bindings (
    id BIGINT PRIMARY KEY,
    account_id BIGINT NOT NULL,
    binding_definition_id INT NOT NULL,
    level SMALLINT NOT NULL,
    xp BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    archived_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Backup table for player accessories
CREATE TABLE IF NOT EXISTS archived_player_accessories (
    id BIGINT PRIMARY KEY,
    account_id BIGINT NOT NULL,
    accessory_definition_id INT NOT NULL,
    level SMALLINT NOT NULL,
    xp BIGINT NOT NULL,
    enchantment_1_id INT,
    enchantment_2_id INT,
    curse_id INT,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    archived_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Backup table for player characters
CREATE TABLE IF NOT EXISTS archived_player_characters (
    id BIGINT PRIMARY KEY,
    account_id BIGINT NOT NULL,
    character_definition_id INT NOT NULL,
    nickname VARCHAR(50),
    level SMALLINT NOT NULL,
    xp BIGINT NOT NULL,
    equipped_binding_id BIGINT,
    equipped_accessory_left_id BIGINT,
    equipped_accessory_middle_id BIGINT,
    equipped_accessory_right_id BIGINT,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    archived_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes for better query performance on archived data
CREATE INDEX IF NOT EXISTS idx_archived_accounts_nakama_user_id ON archived_accounts(nakama_user_id);
CREATE INDEX IF NOT EXISTS idx_archived_accounts_archived_at ON archived_accounts(archived_at);
CREATE INDEX IF NOT EXISTS idx_archived_player_currencies_account_id ON archived_player_currencies(account_id);
CREATE INDEX IF NOT EXISTS idx_archived_player_bindings_account_id ON archived_player_bindings(account_id);
CREATE INDEX IF NOT EXISTS idx_archived_player_accessories_account_id ON archived_player_accessories(account_id);
CREATE INDEX IF NOT EXISTS idx_archived_player_characters_account_id ON archived_player_characters(account_id);
