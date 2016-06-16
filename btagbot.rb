require 'cinch'
require 'sqlite3'
require 'date'

db = SQLite3::Database.new "overwatchbot.db"

Heroes = [
  "D_Va",
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
  "Zenyatta"
]

EdgelordQuotes = [
  "I'm back. In black.",
  "If it lives, I can kill it.",
  "Die. Die!. DIE!!",
]

Help = <<-EOF
!help: this dialog
!btags: list btags
!btags print: spam btags at the channel and annoy everyone
!setbtag <battletag>: set your battletag (please do this)
!playing <time>: let people know when you will be playing after work (just today)
!playing-persist <time>: let people know when you will be playing (persists)
!when: find out when people are playing
!when print: spam when everyone is playing at the channel and annoy everyone
botsnack: botsnack
EOF

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.us.cray.com"
    c.channels = ["#overwatch"]
    c.nick = Heroes.sample
  end

  on :message, /^!help/ do |m|
    Help.split('\n').each do |line|
      m.user.send(line)
    end
  end

  on :message, /^!btags(.*)/ do |m, arg|
    target = arg == " print" ? m.channel : m.user
    db.execute "SELECT nick, battletag FROM battletags;" do |row|
      target.send("Nick: #{row[0]} Battletag: #{row[1]}")
    end
  end

  on :message, /^!setbtag (.+)/ do |m, battletag|
    stmt = db.prepare "INSERT OR REPLACE INTO battletags VALUES (?, ?);"
    stmt.execute m.user.nick, battletag
    m.channel.send("Nick: #{m.user.nick} changed battletag to #{battletag}")
  end

  on :message, /^!when(.*)/ do |m, arg|
    stmt = db.prepare <<-SQL
      SELECT battletag, date, time 
      FROM playtimes LEFT JOIN battletags 
      ON playtimes.nick=battletags.nick
      WHERE date=? OR persist='true';
    SQL

    target = arg ==  " print" ? m.channel : m.user
    target.send("Here's when people will be playing today:")
    stmt.execute(Date.today.iso8601).each do |row|
      target.send("#{row[0]}: #{row[2]}")
    end
  end

  on :message, /^!(playing|playing-persist) (.+)/ do |m, cmd, playing|
    persist = cmd == "playing-persist"
    stmt = db.prepare "INSERT OR REPLACE INTO playtimes VALUES (?, ?, ?, ?)"
    stmt.execute m.user.nick, Date.today.iso8601, playing, persist.to_s

    m.channel.send("#{m.user.nick} will be playing today (#{playing})")
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

  on :message, /mei is bae/ do |m|
    m.bot.nick = "Mei"
  end

  on :message, /edgelord/ do |m|
    m.bot.nick = "Reaper"
    m.channel.send EdgelordQuotes.sample
  end

  on :message, /^botsnack/ do |m|
    m.bot.nick = "Winston"
    m.channel.send("Did someone say... peanut butter?")
  end

  on :message, /^!timeout (.+)/ do |m, user|
    if m.channel.opped?(m.user)
      m.bot.nick = "Tracer"
      m.channel.kick user, "You need a time-out!"
    else
      m.bot.nick = "Tracer"
      m.channel.kick m.user.nick, "You need a time-out!"
    end
  end
end

bot.start
