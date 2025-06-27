-- ============================================================================
-- OUT-OF-DATE DATA RECOVERY QUERIES
-- Turn-Based PVE Mobile Game - Data Restoration
-- ============================================================================
-- This file contains queries for recovering archived out-of-date player data
-- Use these queries to restore accounts and their associated game data
-- ============================================================================

-- ############################################################################
-- # RECOVER ALL ARCHIVED ACCOUNTS
-- ############################################################################
-- Restore ALL archived accounts and their associated data
-- This will recover everything that was previously backed up

BEGIN;

-- Step 1: Restore ALL accounts
INSERT INTO accounts (id, nakama_user_id, created_at, updated_at, last_login_at)
SELECT id, nakama_user_id, created_at, updated_at, last_login_at
FROM archived_accounts
ON CONFLICT (id) DO NOTHING;

-- Step 2: Restore ALL player currencies
INSERT INTO player_currencies (account_id, currency_definition_id, amount, updated_at)
SELECT account_id, currency_definition_id, amount, updated_at
FROM archived_player_currencies
ON CONFLICT (account_id, currency_definition_id) DO UPDATE SET
    amount = EXCLUDED.amount,
    updated_at = EXCLUDED.updated_at;

-- Step 3: Restore ALL player bindings
INSERT INTO player_bindings (id, account_id, binding_definition_id, level, xp, created_at, updated_at)
SELECT id, account_id, binding_definition_id, level, xp, created_at, updated_at
FROM archived_player_bindings
ON CONFLICT (id) DO NOTHING;

-- Step 4: Restore ALL player accessories
INSERT INTO player_accessories (id, account_id, accessory_definition_id, level, xp,
                               enchantment_1_id, enchantment_2_id, curse_id, created_at, updated_at)
SELECT id, account_id, accessory_definition_id, level, xp,
       enchantment_1_id, enchantment_2_id, curse_id, created_at, updated_at
FROM archived_player_accessories
ON CONFLICT (id) DO NOTHING;

-- Step 5: Restore ALL player characters
INSERT INTO player_characters (id, account_id, character_definition_id, nickname, level, xp,
                              equipped_binding_id, equipped_accessory_left_id,
                              equipped_accessory_middle_id, equipped_accessory_right_id,
                              created_at, updated_at)
SELECT id, account_id, character_definition_id, nickname, level, xp,
       equipped_binding_id, equipped_accessory_left_id,
       equipped_accessory_middle_id, equipped_accessory_right_id,
       created_at, updated_at
FROM archived_player_characters
ON CONFLICT (id) DO NOTHING;

-- Show recovery summary
DO $$
DECLARE
    recovered_accounts INTEGER;
    recovered_currencies INTEGER;
    recovered_bindings INTEGER;
    recovered_accessories INTEGER;
    recovered_characters INTEGER;
BEGIN
    -- Count what was recovered
    SELECT COUNT(*) INTO recovered_accounts FROM accounts;
    SELECT COUNT(*) INTO recovered_currencies FROM player_currencies;
    SELECT COUNT(*) INTO recovered_bindings FROM player_bindings;
    SELECT COUNT(*) INTO recovered_accessories FROM player_accessories;
    SELECT COUNT(*) INTO recovered_characters FROM player_characters;

    RAISE NOTICE 'Recovery completed successfully!';
    RAISE NOTICE 'Total accounts after recovery: %', recovered_accounts;
    RAISE NOTICE 'Total currencies after recovery: %', recovered_currencies;
    RAISE NOTICE 'Total bindings after recovery: %', recovered_bindings;
    RAISE NOTICE 'Total accessories after recovery: %', recovered_accessories;
    RAISE NOTICE 'Total characters after recovery: %', recovered_characters;
END
$$;

-- ############################################################################
-- # DELETE FROM ARCHIVE AFTER SUCCESSFUL RECOVERY
-- ############################################################################
-- Remove the recovered data from archive tables since it's now back in main tables

-- Delete archived data in reverse order of dependencies
DELETE FROM archived_player_characters;
DELETE FROM archived_player_accessories;
DELETE FROM archived_player_bindings;
DELETE FROM archived_player_currencies;
DELETE FROM archived_accounts;

-- Show cleanup summary
DO $$
DECLARE
    remaining_accounts INTEGER;
    remaining_currencies INTEGER;
    remaining_bindings INTEGER;
    remaining_accessories INTEGER;
    remaining_characters INTEGER;
BEGIN
    -- Count what remains in archive
    SELECT COUNT(*) INTO remaining_accounts FROM archived_accounts;
    SELECT COUNT(*) INTO remaining_currencies FROM archived_player_currencies;
    SELECT COUNT(*) INTO remaining_bindings FROM archived_player_bindings;
    SELECT COUNT(*) INTO remaining_accessories FROM archived_player_accessories;
    SELECT COUNT(*) INTO remaining_characters FROM archived_player_characters;

    RAISE NOTICE 'Archive cleanup completed!';
    RAISE NOTICE 'Remaining in archived_accounts: %', remaining_accounts;
    RAISE NOTICE 'Remaining in archived_player_currencies: %', remaining_currencies;
    RAISE NOTICE 'Remaining in archived_player_bindings: %', remaining_bindings;
    RAISE NOTICE 'Remaining in archived_player_accessories: %', remaining_accessories;
    RAISE NOTICE 'Remaining in archived_player_characters: %', remaining_characters;
END
$$;
COMMIT;

-- ############################################################################
-- # CLEANUP AFTER RECOVERY (OPTIONAL)
-- ############################################################################
-- Remove ALL recovered data from archive tables
-- Only run this if you want to clear the archive after successful recovery

-- Clean up ALL archived data
-- DELETE FROM archived_player_accessories;
-- DELETE FROM archived_player_bindings;
-- DELETE FROM archived_player_currencies;
-- DELETE FROM archived_player_characters;
-- DELETE FROM archived_accounts;

-- ############################################################################
-- # RECOVERY VERIFICATION QUERIES
-- ############################################################################

-- Verify ALL account recovery
SELECT
    'RECOVERY_VERIFICATION' AS operation,
    a.id,
    a.nakama_user_id,
    a.created_at,
    a.last_login_at,
    (SELECT COUNT(*) FROM player_characters WHERE account_id = a.id) AS characters_count,
    (SELECT COUNT(*) FROM player_currencies WHERE account_id = a.id) AS currencies_count,
    (SELECT COUNT(*) FROM player_bindings WHERE account_id = a.id) AS bindings_count,
    (SELECT COUNT(*) FROM player_accessories WHERE account_id = a.id) AS accessories_count
FROM accounts a
ORDER BY a.id;

-- ############################################################################
-- # ARCHIVE MANAGEMENT UTILITIES
-- ############################################################################

-- List all archived accounts with summary data
SELECT
    aa.id,
    aa.nakama_user_id,
    aa.created_at,
    aa.last_login_at,
    aa.archived_at,
    (SELECT COUNT(*) FROM archived_player_characters WHERE account_id = aa.id) AS characters,
    (SELECT COUNT(*) FROM archived_player_bindings WHERE account_id = aa.id) AS bindings,
    (SELECT COUNT(*) FROM archived_player_accessories WHERE account_id = aa.id) AS accessories,
    (SELECT COUNT(*) FROM archived_player_currencies WHERE account_id = aa.id) AS currencies
FROM archived_accounts aa
ORDER BY aa.archived_at DESC;

-- Check archive statistics
SELECT
    'ARCHIVE_STATISTICS' AS report_type,
    (SELECT COUNT(*) FROM archived_accounts) AS total_archived_accounts,
    (SELECT COUNT(*) FROM archived_player_characters) AS total_archived_characters,
    (SELECT MIN(archived_at) FROM archived_accounts) AS oldest_archive_date,
    (SELECT MAX(archived_at) FROM archived_accounts) AS newest_archive_date;
