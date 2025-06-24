-- #############################################################################
-- # Game Definitions
-- # Contains definitions for game items, abilities, characters, and effects
-- #############################################################################

-- Currency definitions
INSERT INTO currency_definitions (currency_code, name, description, icon_url, max_cap) VALUES
    ('GOLD', 'Gold', 'Basic currency earned through gameplay', '/assets/icons/gold.png', 9999999),
    ('GEMS', 'Gems', 'Premium currency for special items', '/assets/icons/gems.png', 100000),
    ('EVENT_TOKEN_A', 'Festival Token', 'Special event currency', '/assets/icons/event_token.png', 10000);

-- Abilities
INSERT INTO ability_definitions
    (name, description, icon_url, ability_type, target_type, speed_cost, mana_cost, energy_cost, recharge_time)
VALUES
    ('Fireball', 'Launches a ball of fire at a single enemy', '/assets/icons/fireball.png', 'ACTIVE', 'SINGLE_ENEMY', 3, 20, NULL, 1),
    ('Ice Storm', 'Damages all enemies with ice shards', '/assets/icons/ice_storm.png', 'ACTIVE', 'GROUP_ENEMY', 5, 40, NULL, 3),
    ('Swift Strike', 'Quick physical attack on a single target', '/assets/icons/swift_strike.png', 'ACTIVE', 'SINGLE_ENEMY', 2, NULL, 15, 0),
    ('Healing Light', 'Restores health to an ally', '/assets/icons/healing_light.png', 'ACTIVE', 'SINGLE_ALLY', 4, 30, NULL, 2),
    ('Defensive Stance', 'Passively increases defense', '/assets/icons/def_stance.png', 'PASSIVE', NULL, 0, NULL, NULL, 0),
    ('Elemental Mastery', 'Passively enhances elemental damage', '/assets/icons/elem_mastery.png', 'PASSIVE', NULL, 0, NULL, NULL, 0),
    ('Team Shield', 'Shields all allies from damage', '/assets/icons/team_shield.png', 'ACTIVE', 'GROUP_ALLY', 6, 50, NULL, 4),
    ('Energy Burst', 'Powerful attack consuming energy', '/assets/icons/energy_burst.png', 'ACTIVE', 'SINGLE_ENEMY', 4, NULL, 35, 2),
    ('Self Heal', 'Restores user''s health', '/assets/icons/self_heal.png', 'ACTIVE', 'SELF', 3, NULL, 25, 2),
    ('Battle Cry', 'Buffs self and all allies', '/assets/icons/battle_cry.png', 'ACTIVE', 'SELF_AND_GROUP_ALLY', 4, NULL, 30, 3);

-- Character Definitions
INSERT INTO character_definitions
    (name, description, icon_url, model_url, base_speed, base_max_health, base_attack_damage,
    base_defense, base_resistance_fire, base_resistance_ice, base_resistance_electric,
    base_resistance_light, base_resistance_dark, base_shield_decay_rate,
    has_mana, base_max_mana, base_mana_regenerate, has_energy, base_max_energy, base_energy_regenerate,
    ability_slot_1_id, ability_slot_2_id, ability_slot_3_id, ability_slot_4_id, ability_slot_5_id)
VALUES
    -- Mage character
    ('Pyromancer', 'Powerful fire mage', '/assets/icons/pyromancer.png', '/assets/models/pyromancer.glb',
    8, 450, 35, 20, 50, 0, 10, 20, 0, 0.05,
    TRUE, 200, 15, FALSE, NULL, NULL,
    1, 2, 4, 7, 5),

    -- Warrior character
    ('Gladiator', 'Melee fighter with strong defenses', '/assets/icons/gladiator.png', '/assets/models/gladiator.glb',
    6, 650, 45, 40, 10, 10, 5, 0, 10, 0.03,
    FALSE, NULL, NULL, TRUE, 150, 12,
    3, 8, 9, 10, 5);

-- Special effect definitions
INSERT INTO special_effect_definitions (name, description) VALUES
    ('Burning', 'Deals fire damage over time'),
    ('Freezing', 'Slows target and deals ice damage'),
    ('Vampiric', 'Heals wielder for a percentage of damage dealt');

-- Binding definitions
INSERT INTO binding_definitions (name, description, icon_url, model_url, base_attack_power, damage_type, special_effect_id) VALUES
    ('Flameweaver', 'Staff that channels fire magic', '/assets/icons/flameweaver.png', '/assets/models/flameweaver.glb', 45, 'FIRE_ELEMENTAL', 1),
    ('Frostbite', 'Ice-enhanced dagger', '/assets/icons/frostbite.png', '/assets/models/frostbite.glb', 35, 'ICE_ELEMENTAL', 2),
    ('Bloodthirster', 'Large sword that drains enemy life', '/assets/icons/bloodthirster.png', '/assets/models/bloodthirster.glb', 50, 'SLASHING', 3);

-- Set effect definitions
INSERT INTO set_effect_definitions (name, description) VALUES
    ('Elemental Master', 'Enhances all elemental damage and resistance'),
    ('Guardian''s Bulwark', 'Increases defensive capabilities');

-- Set effect bonuses
INSERT INTO set_effect_bonuses (set_effect_id, required_pieces, bonus_description, bonus_stat_target, bonus_stat_modifier_type, bonus_stat_modifier_value) VALUES
    (1, 2, 'Moderate elemental boost', 'ALL_TYPE_AD', 'PERCENTAGE', 10.00),
    (1, 3, 'Major elemental boost', 'ALL_TYPE_AD', 'PERCENTAGE', 25.00),
    (2, 2, 'Moderate defense boost', 'DEFENSE', 'PERCENTAGE', 15.00),
    (2, 3, 'Major defense and health boost', 'MAX_HEALTH', 'PERCENTAGE', 20.00);

-- Accessory definitions
INSERT INTO accessory_definitions
    (name, description, icon_url, model_url, slot_type, base_attack_damage_bonus, base_max_health_bonus, base_defense_bonus, set_effect_id) VALUES
    ('Elemental Crown', 'Crown enhancing magical abilities', '/assets/icons/elem_crown.png', '/assets/models/elem_crown.glb', 'LEFT', 15, 0, 0, 1),
    ('Elemental Pendant', 'Pendant channeling elemental energy', '/assets/icons/elem_pendant.png', '/assets/models/elem_pendant.glb', 'MIDDLE', 0, 100, 0, 1),
    ('Elemental Ring', 'Ring that protects against elemental damage', '/assets/icons/elem_ring.png', '/assets/models/elem_ring.glb', 'RIGHT', 0, 0, 10, 1),
    ('Guardian Shield', 'Small shield worn on arm', '/assets/icons/guardian_shield.png', '/assets/models/guardian_shield.glb', 'RIGHT', 0, 0, 25, 2),
    ('Guardian Gauntlets', 'Protective gauntlets', '/assets/icons/guardian_gaunt.png', '/assets/models/guardian_gaunt.glb', 'LEFT', 10, 0, 5, 2),
    ('Guardian Plate', 'Chest armor with enhanced protection', '/assets/icons/guardian_plate.png', '/assets/models/guardian_plate.glb', 'MIDDLE', 0, 200, 0, 2);

-- Enchantment/curse definitions
INSERT INTO enchantment_curse_definitions
    (name, description, category, target_stat_1, modifier_percentage_1, target_stat_2, modifier_percentage_2, transforms_from_stat, transforms_to_stat, is_transformation) VALUES
    ('Fiery', 'Increases fire damage', 'ENCHANTMENT', 'FIRE_AD', 15.00, NULL, NULL, NULL, NULL, FALSE),
    ('Fortified', 'Increases maximum health', 'ENCHANTMENT', 'MAX_HEALTH', 10.00, NULL, NULL, NULL, NULL, FALSE),
    ('Glass Cannon', 'Increases damage but reduces defense', 'CURSE', 'ATTACK_DAMAGE', 30.00, 'DEFENSE', -15.00, NULL, NULL, FALSE),
    ('Elemental Shift', 'Converts defense into fire resistance', 'ENCHANTMENT', NULL, NULL, NULL, NULL, 'DEFENSE', 'FIRE_RESISTANCE', TRUE);
