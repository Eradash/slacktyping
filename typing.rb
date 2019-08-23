require 'dotenv/load'
require 'slack-ruby-client'

raise 'Missing ENV[SLACK_API_TOKENS]!' unless ENV.key?('SLACK_API_TOKENS')

$stdout.sync = true
logger = Logger.new($stdout)
logger.level = Logger::DEBUG

threads = []

ENV['SLACK_API_TOKENS'].split.each do |token|
  logger.info "Starting #{token[0..12]} ..."

  client = Slack::RealTime::Client.new(token: token)

  client.on :hello do
    logger.info "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."
  end

  client.on(:user_typing) do |data|
    logger.info data
    client.typing channel: data.channel
    #client.message channel: data.channel, text: "What are you typing <@#{data.user}>?"
  end

  client.on(:message) do |data|
    # Test pulse, simply type `test` to self to check if app is running
    if data.channel == "D7WHQFK9S" && data.user == "U7XCRLE78" && data.text == "test"
      client.message channel: data.channel, text: "Always active! :)"
    end

    if data.user != "U7XCRLE78"
      client.message channel: "GMEHL04BZ", text: data.user + " a écrit sur " + data.channel + ": \n>" + data.text
    end

    logger.info data
  end

  client.on(:team_join) do |data|
    client.message channel: "GMEHL04BZ", text: "Bienvenue, #{data.user}!!"
  end

  threads << client.start_async
end

threads.each(&:join)
