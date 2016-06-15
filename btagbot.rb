require 'cinch'
require 'sqlite3'

db = SQLite3::Database.new "overwatchbot.db"

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.us.cray.com"
    c.channels = ["#overwatch"]
    c.nick = "OWBot"
  end

  on :message, /^!btags/ do |m|
    db.execute "SELECT nick, battletag FROM battletags;" do |row|
      m.channel.send("Nick: #{row[0]} Battletag: #{row[1]}")
    end
  end

  on :message, /^!setbtag (.+)/ do |m, battletag|
    stmt = db.prepare "DELETE FROM battletags WHERE nick=?;"
    stmt.execute m.user.nick

    stmt = db.prepare "INSERT INTO battletags VALUES (?, ?);"
    stmt.execute m.user.nick, battletag
    m.channel.send("Nick: #{m.user.nick} changed battletag to #{battletag}")
  end
end

bot.start
