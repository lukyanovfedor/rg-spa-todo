json.id comment.id
json.note comment.note
json.created_at comment.created_at
json.updated_at comment.updated_at
json.task_id comment.task_id
json.attachments comment.attachments do |a|
  json.partial! 'attachments/attachment', attachment: a
end