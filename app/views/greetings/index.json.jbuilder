json.array!(@greetings) do |greeting|
  json.extract! greeting, :id, :text, :stranger, :time_of_day
  json.url greeting_url(greeting, format: :json)
end
