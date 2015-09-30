json.(project, :id, :title, :created_at, :updated_at, :user_id)
json.tasks project.tasks do |t|
  json.partial! 'tasks/task', task: t
end