json.extract! competition, :id, :competition_name, :date, :location, :country, :distance_type, :wre_id, :checksum, :created_at, :updated_at
json.url competition_url(competition, format: :json)
