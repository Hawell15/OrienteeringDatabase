json.extract! category, :id, :category_name, :full_name, :points, :created_at, :updated_at
json.url category_url(category, format: :json)
