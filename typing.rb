require 'dotenv/load'
require 'slack-ruby-client'
require 'json'

raise 'Missing ENV[SLACK_API_TOKENS]!' unless ENV.key?('SLACK_API_TOKENS')

$categories = {}

filepath = File.join(File.expand_path(File.dirname(__FILE__)), "fortunes")
files = Dir.new(filepath)
files.each do |file|
  unless file == "." or file == ".."
    data = File.read(File.join(filepath, file))
    $categories[file] = data.strip.split("%")
  end
end

$stdout.sync = true
logger = Logger.new($stdout)
logger.level = Logger::DEBUG

threads = []

ENV['SLACK_API_TOKENS'].split.each do |token|
  logger.info "Starting #{token[0..12]} ..."

  client = Slack::RealTime::Client.new(token: token)
  client2 = Slack::Web::Client.new(token: token)

  client.on :hello do
    logger.info "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
  end

  client.on(:user_typing) do |data|
    logger.info data

    if data.user != "U8QUCDX0U" && data.user != "U0AUB0FT6" && data.channel != "CDBA2T69W"
      client.typing channel: data.channel
    end

    user = client2.users_info(user: data.user).user

    begin
      channel = client2.channels_info(channel: data.channel).channel
      client.message channel: "GMEHL04BZ", text: "_*#{user.name}* (#{data.user}) est en train d'écrire dans *#{channel.name}* (#{data.channel})_"
    rescue
      client.message channel: "GMEHL04BZ", text: "_*#{user.name}* (#{data.user}) est en train d'écrire dans (#{data.channel})_"
    end
  end

  client.on(:message) do |data|
    if data.user != "USLACKBOT"
      # Test pulse, simply type `test` to self to check if app is running
      if data.channel == "D7WHQFK9S" && data.user == "U7XCRLE78"
        if data.text == "test"
          client.message channel: data.channel, text: "Always active! :)"
        end
      end

      if data.text.include? "fortune"
        key = $categories.keys.sample
        text = $categories[key].sample.strip.gsub(/"/,"'").split("\n").join("\n>")
        client.message channel: "GMEHL04BZ", text: ">"+ text
      end

      user = client2.users_info(user: data.user).user
      begin
        channel = client2.channels_info(channel: data.channel).channel
        client.message channel: "GMEHL04BZ", text: "*#{user.name}* (#{data.user}) a écrit sur *#{channel.name}* (#{data.channel}): \n> #{data.text}"
      rescue
        client.message channel: "GMEHL04BZ", text: "*#{user.name}* (#{data.user}) a écrit sur (#{data.channel}): \n> #{data.text}"
      end
    end

    logger.info data
  end

  client.on(:team_join) do |data|
    client.message channel: "GMEHL04BZ", text: "Bienvenue, #{data.user.name}!!"
  end

  threads << client.start_async
end

threads.each(&:join)
