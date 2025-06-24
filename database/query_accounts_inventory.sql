-- Query: List all accounts with their currencies, bindings, and accessories
SELECT
  a.id AS account_id,
  a.nakama_user_id,
  a.created_at,
  a.updated_at,
  -- Currencies
  pc.currency_definition_id,
  cd.currency_code,
  pc.amount AS currency_amount,
  -- Bindings (Weapons)
  pb.id AS binding_id,
  pb.binding_definition_id,
  bd.name AS binding_name,
  pb.level AS binding_level,
  pb.xp AS binding_xp,
  -- Accessories
  pa.id AS accessory_id,
  pa.accessory_definition_id,
  ad.name AS accessory_name,
  pa.level AS accessory_level,
  pa.xp AS accessory_xp
FROM accounts a
LEFT JOIN player_currencies pc ON a.id = pc.account_id
LEFT JOIN currency_definitions cd ON pc.currency_definition_id = cd.id
LEFT JOIN player_bindings pb ON a.id = pb.account_id
LEFT JOIN binding_definitions bd ON pb.binding_definition_id = bd.id
LEFT JOIN player_accessories pa ON a.id = pa.account_id
LEFT JOIN accessory_definitions ad ON pa.accessory_definition_id = ad.id
ORDER BY a.id, pc.currency_definition_id, pb.id, pa.id; 