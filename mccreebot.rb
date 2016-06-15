require 'cinch'

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.us.cray.com"
    c.channels = ["#overwatch"]
    c.nick = "McCree"
  end

  on :connect do
    Channel("#overwatch").send("It's high noon!")
    bot.quit("!!!!!!")
  end
end

bot.start
