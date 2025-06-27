-- ############################################################################
-- BACKUP AND DELETE OUT-OF-DATE DATA SCRIPT
-- ############################################################################
-- This script backs up and then deletes accounts and all related data
-- for accounts that haven't logged in for the specified retention period.
--
-- IMPORTANT: Run backup_schema.sql first to create the backup tables!
--
-- Define what constitutes "out-of-date" data:
-- - Accounts with no login for 1 HOUR (for testing) - CHANGE THIS FOR PRODUCTION!
-- Replace this value as needed for your retention policy
-- For production, use something like '30 days' or '90 days'
-- ############################################################################

-- Safety check: Ensure backup tables exist before proceeding
DO $$
DECLARE
    qualifying_accounts INTEGER;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'archived_accounts') THEN
        RAISE EXCEPTION 'Backup tables do not exist! Please run backup_schema.sql first.';
    END IF;

    -- Check how many accounts qualify for backup
    SELECT COUNT(*) INTO qualifying_accounts
    FROM accounts
    WHERE last_login_at < (NOW() - INTERVAL '1 hour')  -- Changed to 1 hour for testing
       OR (last_login_at IS NULL AND created_at < (NOW() - INTERVAL '1 hour'));

    RAISE NOTICE 'Found % accounts that qualify for backup', qualifying_accounts;

    IF qualifying_accounts = 0 THEN
        RAISE NOTICE 'No accounts qualify for backup. Check your data or adjust the time interval.';
    END IF;
END
$$;

-- ############################################################################
-- # BACKUP AND DELETE PROCESS
-- ############################################################################
-- Execute these queries in order within a transaction

BEGIN;

-- Step 1: Backup accounts data first
INSERT INTO archived_accounts (
    id, nakama_user_id, created_at, updated_at, last_login_at
)
SELECT id, nakama_user_id, created_at, updated_at, last_login_at
FROM accounts
WHERE last_login_at < (NOW() - INTERVAL '1 hour')  -- Changed to match the check above
   OR (last_login_at IS NULL AND created_at < (NOW() - INTERVAL '1 hour'))
ON CONFLICT (id) DO NOTHING; -- Avoid duplicates if script is run multiple times

-- Step 2: Backup player currencies data
INSERT INTO archived_player_currencies (
    account_id, currency_definition_id, amount, updated_at
)
SELECT pc.account_id, pc.currency_definition_id, pc.amount, pc.updated_at
FROM player_currencies pc
WHERE pc.account_id IN (
    SELECT id FROM accounts
    WHERE last_login_at < (NOW() - INTERVAL '1 hour')
       OR (last_login_at IS NULL AND created_at < (NOW() - INTERVAL '1 hour'))
)
ON CONFLICT (account_id, currency_definition_id) DO NOTHING;

-- Step 3: Backup player bindings data
INSERT INTO archived_player_bindings (
    id, account_id, binding_definition_id, level, xp, created_at, updated_at
)
SELECT pb.id, pb.account_id, pb.binding_definition_id, pb.level, pb.xp,
       pb.created_at, pb.updated_at
FROM player_bindings pb
WHERE pb.account_id IN (
    SELECT id FROM accounts
    WHERE last_login_at < (NOW() - INTERVAL '1 hour')
       OR (last_login_at IS NULL AND created_at < (NOW() - INTERVAL '1 hour'))
)
ON CONFLICT (id) DO NOTHING;

-- Step 4: Backup player accessories data
INSERT INTO archived_player_accessories (
    id, account_id, accessory_definition_id, level, xp,
    enchantment_1_id, enchantment_2_id, curse_id,
    created_at, updated_at
)
SELECT pa.id, pa.account_id, pa.accessory_definition_id, pa.level, pa.xp,
       pa.enchantment_1_id, pa.enchantment_2_id, pa.curse_id,
       pa.created_at, pa.updated_at
FROM player_accessories pa
WHERE pa.account_id IN (
    SELECT id FROM accounts
    WHERE last_login_at < (NOW() - INTERVAL '1 hour')
       OR (last_login_at IS NULL AND created_at < (NOW() - INTERVAL '1 hour'))
)
ON CONFLICT (id) DO NOTHING;

-- Step 5: Backup player characters data
INSERT INTO archived_player_characters (
    id, account_id, character_definition_id, nickname, level, xp,
    equipped_binding_id, equipped_accessory_left_id,
    equipped_accessory_middle_id, equipped_accessory_right_id,
    created_at, updated_at
)
SELECT pc.id, pc.account_id, pc.character_definition_id, pc.nickname, pc.level, pc.xp,
       pc.equipped_binding_id, pc.equipped_accessory_left_id,
       pc.equipped_accessory_middle_id, pc.equipped_accessory_right_id,
       pc.created_at, pc.updated_at
FROM player_characters pc
WHERE pc.account_id IN (
    SELECT id FROM accounts
    WHERE last_login_at < (NOW() - INTERVAL '1 hour')
       OR (last_login_at IS NULL AND created_at < (NOW() - INTERVAL '1 hour'))
)
ON CONFLICT (id) DO NOTHING;

-- ############################################################################
-- # DELETION PROCESS (in reverse order of dependencies)
-- ############################################################################

-- Delete player characters (depends on player_bindings and player_accessories)
DELETE FROM player_characters
WHERE account_id IN (
    SELECT id FROM accounts
    WHERE last_login_at < (NOW() - INTERVAL '1 hour')
       OR (last_login_at IS NULL AND created_at < (NOW() - INTERVAL '1 hour'))
);

-- Delete player accessories
DELETE FROM player_accessories
WHERE account_id IN (
    SELECT id FROM accounts
    WHERE last_login_at < (NOW() - INTERVAL '1 hour')
       OR (last_login_at IS NULL AND created_at < (NOW() - INTERVAL '1 hour'))
);

-- Delete player bindings
DELETE FROM player_bindings
WHERE account_id IN (
    SELECT id FROM accounts
    WHERE last_login_at < (NOW() - INTERVAL '1 hour')
       OR (last_login_at IS NULL AND created_at < (NOW() - INTERVAL '1 hour'))
);

-- Delete player currencies
DELETE FROM player_currencies
WHERE account_id IN (
    SELECT id FROM accounts
    WHERE last_login_at < (NOW() - INTERVAL '1 hour')
       OR (last_login_at IS NULL AND created_at < (NOW() - INTERVAL '1 hour'))
);

-- Finally, delete the accounts themselves
DELETE FROM accounts
WHERE last_login_at < (NOW() - INTERVAL '1 hour')
   OR (last_login_at IS NULL AND created_at < (NOW() - INTERVAL '1 hour'));

-- ############################################################################
-- # SUMMARY
-- ############################################################################

-- Get counts of what was backed up and deleted
DO $$
DECLARE
    backup_count INTEGER;
    delete_count INTEGER;
BEGIN
    -- Count backed up accounts
    SELECT COUNT(*) INTO backup_count
    FROM archived_accounts
    WHERE archived_at >= CURRENT_DATE;

    RAISE NOTICE 'Backup and deletion completed successfully.';
    RAISE NOTICE 'Accounts backed up today: %', backup_count;

    -- You can add more detailed counts here if needed
END
$$;

COMMIT;

-- ############################################################################
-- # VERIFICATION QUERIES (Run these after the transaction)
-- ############################################################################

-- Uncomment these queries to verify the backup worked correctly:

-- -- Check what was backed up today
-- SELECT 'Accounts backed up today:' as description, COUNT(*) as count
-- FROM archived_accounts
-- WHERE archived_at >= CURRENT_DATE
-- UNION ALL
-- SELECT 'Player accessories backed up today:', COUNT(*)
-- FROM archived_player_accessories
-- WHERE archived_at >= CURRENT_DATE
-- UNION ALL
-- SELECT 'Player bindings backed up today:', COUNT(*)
-- FROM archived_player_bindings
-- WHERE archived_at >= CURRENT_DATE
-- UNION ALL
-- SELECT 'Player characters backed up today:', COUNT(*)
-- FROM archived_player_characters
-- WHERE archived_at >= CURRENT_DATE
-- UNION ALL
-- SELECT 'Player currencies backed up today:', COUNT(*)
-- FROM archived_player_currencies
-- WHERE archived_at >= CURRENT_DATE;
