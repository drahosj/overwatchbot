require 'cinch'
require 'sqlite3'

db = SQLite3::Database.new "overwatchbot.db"

Heroes = [
  "D.Va",
  "Zarya",
  "Bastion",
  "Mei",
  "Reaper",
  "McCree",
  "Hanzo",
  "Widowmaker",
  "Winston",
  "Pharah",
  "Genji",
  "Mercy",
  "Lucio",
  "Junkrat",
  "Roadhog",
  "Symmetra",
  "Tracer",
  "Soldier76",
  "Torbjorn",
  "Reinhardt",
  "Zenyatta"]

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.us.cray.com"
    c.channels = ["#overwatch"]
    c.nick = Heroes.sample
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

  on :message, /^we need to counter/ do |m|
    m.bot.nick = Heroes.sample
  end

  on :message, /(.+) is a (scrub|noob|fail)/ do |m, hero|
    if m.bot.nick.downcase == hero.downcase
      m.bot.nick = Heroes.sample
    end
  end

  on :message, /^we need a (.+)/ do |m, hero|
    Heroes.each do |h|
      if h.downcase == hero.downcase
        m.bot.nick = h
      end
    end
  end
end

bot.start
