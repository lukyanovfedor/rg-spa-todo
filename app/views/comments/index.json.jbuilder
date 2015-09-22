json.array! @comments do |c|
  json.partial! 'comment', comment: c
end