json.id attachment.id
json.file do
  json.name file_name(attachment.file.url)
  json.url attachment.file.url
end