-- #############################################################################
-- # Test Player Data
-- #############################################################################

-- Create test accounts
INSERT INTO accounts (nakama_user_id, created_at, updated_at, last_login_at) VALUES
    ('123e4567-e89b-12d3-a456-426614174000'::uuid, NOW(), NOW(), NOW()),
    ('223e4567-e89b-12d3-a456-426614174001'::uuid, NOW(), NOW(), NOW());

-- Player currencies
INSERT INTO player_currencies (account_id, currency_definition_id, amount, updated_at) VALUES
    (1, 1, 5000, NOW()),  -- Player 1 has 5000 Gold
    (1, 2, 200, NOW()),   -- Player 1 has 200 Gems
    (2, 1, 3500, NOW()),  -- Player 2 has 3500 Gold
    (2, 3, 150, NOW());   -- Player 2 has 150 Event tokens

-- Player bindings
INSERT INTO player_bindings (account_id, binding_definition_id, level, xp, created_at, updated_at) VALUES
    (1, 1, 10, 1500, NOW(), NOW()),   -- Player 1's Flameweaver, level 10
    (1, 2, 5, 800, NOW(), NOW()),     -- Player 1's Frostbite, level 5
    (2, 3, 8, 1200, NOW(), NOW());    -- Player 2's Bloodthirster, level 8

-- Player accessories
INSERT INTO player_accessories (account_id, accessory_definition_id, level, xp, enchantment_1_id, enchantment_2_id, curse_id, created_at, updated_at) VALUES
    (1, 1, 12, 2500, 1, 2, NULL, NOW(), NOW()),  -- Player 1's Elemental Crown with Fiery and Fortified
    (1, 2, 10, 2000, 2, NULL, NULL, NOW(), NOW()), -- Player 1's Elemental Pendant with Fortified
    (1, 3, 8, 1500, NULL, NULL, 3, NOW(), NOW()),  -- Player 1's Elemental Ring with Glass Cannon curse
    (2, 4, 15, 3000, 4, NULL, NULL, NOW(), NOW()),  -- Player 2's Guardian Shield with Elemental Shift
    (2, 5, 12, 2400, 1, NULL, NULL, NOW(), NOW()),  -- Player 2's Guardian Gauntlets with Fiery
    (2, 6, 10, 2000, 2, NULL, NULL, NOW(), NOW());  -- Player 2's Guardian Plate with Fortified

-- Player characters
INSERT INTO player_characters (account_id, character_definition_id, nickname, level, xp, equipped_binding_id, equipped_accessory_left_id, equipped_accessory_middle_id, equipped_accessory_right_id, created_at, updated_at) VALUES
    (1, 1, 'Flamelord', 25, 12500, 1, 1, 2, 3, NOW(), NOW()),  -- Player 1's Pyromancer with full equipment
    (2, 2, 'Titan', 30, 15000, 3, 5, 6, 4, NOW(), NOW());       -- Player 2's Gladiator with full equipment
