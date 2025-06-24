-- Query: List all accounts with their characters and character details
SELECT
  a.id AS account_id,
  a.nakama_user_id,
  a.created_at,
  a.updated_at,
  pc.id AS character_id,
  pc.character_definition_id,
  cd.name AS character_name,
  pc.nickname,
  pc.level AS character_level,
  pc.xp AS character_xp,
  pc.equipped_binding_id,
  pc.equipped_accessory_left_id,
  pc.equipped_accessory_middle_id,
  pc.equipped_accessory_right_id
FROM accounts a
LEFT JOIN player_characters pc ON a.id = pc.account_id
LEFT JOIN character_definitions cd ON pc.character_definition_id = cd.id
ORDER BY a.id, pc.id; 