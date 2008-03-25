%w( rubygems yaml xmpp4r-simple gosu htmlentities).each { |g| require g }
include Gosu

CONFIG = YAML.load_file 'config.yml'
FULL_SCREEN = false

class Message
  %w( body x y z ).each { |at| attr_accessor at.to_sym }
  
  def initialize(body, x=nil, y=nil, z=1)
    @body = HTMLEntities.new.decode(body)
    
    @x = x
    @x = rand(100) if @x.nil?
    
    @y = y
    @y = rand(768) if @y.nil?
    
    @z = z
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
    super(1024, 768, FULL_SCREEN, 20)
    self.caption = 'MetaTweet'
    
    @text = Gosu::Font.new(self, 'Helvetica', 18)
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
    @messages.each do |msg| 
      @text.draw(msg.body, msg.x, msg.y, msg.z)
    end
  end
end

TweetWindow.new.show
