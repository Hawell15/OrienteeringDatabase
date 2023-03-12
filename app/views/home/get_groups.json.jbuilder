json.array!(@groups) do |group|
  json.id group.id
  json.name group.group_name
  byebug
end
