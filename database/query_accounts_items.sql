-- Query: List all accounts and their items (bindings and accessories)
SELECT
  a.id AS account_id,
  a.nakama_user_id,
  pb.id AS binding_id,
  pb.binding_definition_id,
  bd.name AS binding_name,
  pa.id AS accessory_id,
  pa.accessory_definition_id,
  ad.name AS accessory_name
FROM accounts a
LEFT JOIN player_bindings pb ON a.id = pb.account_id
LEFT JOIN binding_definitions bd ON pb.binding_definition_id = bd.id
LEFT JOIN player_accessories pa ON a.id = pa.account_id
LEFT JOIN accessory_definitions ad ON pa.accessory_definition_id = ad.id
ORDER BY a.id, pb.id, pa.id; 