json.id comment.id
json.note comment.note
json.created_at comment.created_at
json.updated_at comment.updated_at
json.task_id comment.task_id
json.files comment.files do |f|
  json.filename file_name f.url
  json.url full_url f.url
end