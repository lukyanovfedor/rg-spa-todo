json.array! @projects do |p|
  json.partial! 'project', project: p
end