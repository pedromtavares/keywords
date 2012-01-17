services = YAML::load_file(File.join(Rails.root, 'config', 'services.yml'))
twitter = services['twitter']
key = twitter[Rails.env]['key']
secret = twitter[Rails.env]['secret']
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, key, secret
end
Twitter.configure do |config|
  config.consumer_key = key
  config.consumer_secret = secret
end