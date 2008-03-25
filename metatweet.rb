%w( rubygems yaml xmpp4r-simple gosu htmlentities).each { |g| require g }
include Gosu

CONFIG = YAML.load_file 'config.yml'

class Message
  #%w( body x y z alpha fontsize ).each { |at| attr_accessor at.to_sym }
  attr_accessor :body, :x, :y, :z, :alpha, :fontsize, :created_at
  
  def initialize(body, x=nil, y=nil)
    @body = HTMLEntities.new.decode body.split(':')[1]    
    
    @x = x ? x : rand(100)
    @y = y ? y : rand(700)
    @z = 1 + rand(10)
    
    @alpha = 255
    @fontsize = 14 + rand(18)
    
    @created_at = Time.now
  end
  
  def age_in_seconds
    (Time.now - @created_at).floor
  end
  
  def degrade_alpha
    return @alpha if self.age_in_seconds < 45
    return @alpha if @alpha == 1
    @alpha = @alpha - 1
  end
end

class JabberStream
  def initialize
    @im = Jabber::Simple.new(CONFIG['jabber']['jid'], CONFIG['jabber']['password'])
    @im.status(:chat, 'tweet at me brah')
    @im.deliver('twitter@twitter.com', 'on')
  end

  def messages(&block)
    @im.received_messages { |msg| yield msg if msg.type == :chat }
  end
end

class TweetWindow < Gosu::Window
  def initialize
    super(1024, 768, CONFIG['fullscreen'], 20)
    self.caption = 'MetaTweet'
    
    @background_image = Gosu::Image.new(self, "bg.png", false)
    @jabber = JabberStream.new
    @messages = Array.new    
  end
  
  def update
    @messages = Array.new if button_down?(Gosu::Button::MsLeft)
          
    @jabber.messages do |msg|
      @messages.shift if @messages.size > 10
      @messages << Message.new(msg.body)
    end
  end
  
  def draw
    @background_image.draw(0, 0, 0, 2, 2);
    
    @messages.each do |msg| 
      t = Gosu::Image.from_text(self, msg.body, "Helvetica", msg.fontsize, 10, 800, :left)
      t.draw(msg.x, msg.y, msg.z, 1, 1, Gosu::Color.new(msg.degrade_alpha, 0, 83, 65))
    end
  end
end

TweetWindow.new.show
