class Key < ActiveRecord::Base
  def generate_api_key
    loop do
      token = SecureRandom.base64.tr('+/=', 'Qrt')
      break token unless User.exists?(api_key: token).any?
    end
  end

  before_create do |doc|
    doc.api_key = doc.generate_api_key
  end

end
