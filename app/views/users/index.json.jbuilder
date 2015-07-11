json.array!(@users) do |user|
  json.extract! user, :id, :fname, :lname, :phone, :email, :guest, :active
  json.url user_url(user, format: :json)
end
