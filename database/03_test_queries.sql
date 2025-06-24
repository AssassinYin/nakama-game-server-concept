-- #############################################################################
-- # Test Queries
-- #############################################################################

-- Test Query 1: Get all characters owned by a player with their equipment
SELECT
    pc.id as character_id,
    pc.nickname,
    cd.name as character_type,
    pc.level,
    bd.name as equipped_weapon,
    al.name as left_accessory,
    am.name as middle_accessory,
    ar.name as right_accessory
FROM
    player_characters pc
JOIN
    character_definitions cd ON pc.character_definition_id = cd.id
LEFT JOIN
    player_bindings pb ON pc.equipped_binding_id = pb.id
LEFT JOIN
    binding_definitions bd ON pb.binding_definition_id = bd.id
LEFT JOIN
    player_accessories pal ON pc.equipped_accessory_left_id = pal.id
LEFT JOIN
    accessory_definitions al ON pal.accessory_definition_id = al.id
LEFT JOIN
    player_accessories pam ON pc.equipped_accessory_middle_id = pam.id
LEFT JOIN
    accessory_definitions am ON pam.accessory_definition_id = am.id
LEFT JOIN
    player_accessories par ON pc.equipped_accessory_right_id = par.id
LEFT JOIN
    accessory_definitions ar ON par.accessory_definition_id = ar.id
WHERE
    pc.account_id = 1;

-- Test Query 2: Get a player's currencies
SELECT
    cd.name as currency_name,
    pc.amount,
    cd.max_cap
FROM
    player_currencies pc
JOIN
    currency_definitions cd ON pc.currency_definition_id = cd.id
WHERE
    pc.account_id = 1;

-- Test Query 3: Check for set effects on a character
WITH character_accessories AS (
    SELECT
        pc.id as character_id,
        ad_left.set_effect_id as left_set,
        ad_middle.set_effect_id as middle_set,
        ad_right.set_effect_id as right_set
    FROM
        player_characters pc
    LEFT JOIN
        player_accessories pa_left ON pc.equipped_accessory_left_id = pa_left.id
    LEFT JOIN
        accessory_definitions ad_left ON pa_left.accessory_definition_id = ad_left.id
    LEFT JOIN
        player_accessories pa_middle ON pc.equipped_accessory_middle_id = pa_middle.id
    LEFT JOIN
        accessory_definitions ad_middle ON pa_middle.accessory_definition_id = ad_middle.id
    LEFT JOIN
        player_accessories pa_right ON pc.equipped_accessory_right_id = pa_right.id
    LEFT JOIN
        accessory_definitions ad_right ON pa_right.accessory_definition_id = ad_right.id
    WHERE
        pc.id = 1
),
set_counts AS (
    SELECT
        character_id,
        set_effect_id,
        COUNT(*) as pieces
    FROM (
        SELECT character_id, left_set as set_effect_id FROM character_accessories WHERE left_set IS NOT NULL
        UNION ALL
        SELECT character_id, middle_set as set_effect_id FROM character_accessories WHERE middle_set IS NOT NULL
        UNION ALL
        SELECT character_id, right_set as set_effect_id FROM character_accessories WHERE right_set IS NOT NULL
    ) as sets
    GROUP BY character_id, set_effect_id
)
SELECT
    sc.character_id,
    sed.name as set_name,
    sc.pieces,
    seb.bonus_description,
    seb.bonus_stat_target,
    seb.bonus_stat_modifier_value
FROM
    set_counts sc
JOIN
    set_effect_definitions sed ON sc.set_effect_id = sed.id
JOIN
    set_effect_bonuses seb ON sc.set_effect_id = seb.set_effect_id AND sc.pieces >= seb.required_pieces
ORDER BY
    sc.character_id, sed.name, sc.pieces;
