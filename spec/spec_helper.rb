dir = File.dirname(__FILE__)
$LOAD_PATH.unshift "#{dir}/../lib"

require File.join(dir, '../config/environment')
require 'spec'
require 'pp'
require 'cache_money'

begin
  require 'memcached'
rescue Exception => e
  require 'memcache'
end

require 'memcached_wrapper'

Spec::Runner.configure do |config|
  config.mock_with :rr
  config.before :suite do
    load File.join(dir, "../db/schema.rb")

    config = YAML.load(IO.read((File.expand_path(File.dirname(__FILE__) + "/../config/memcached.yml"))))['test']
    memcache_class = defined?(MemcachedWrapper) ? MemcachedWrapper : MemCache
    $memcache = memcache_class.new(config["servers"].gsub(' ', '').split(','), config) 
    $lock = Cash::Lock.new($memcache)
  end

  config.before :each do
    $memcache.flush_all
    Story.delete_all
    Character.delete_all
  end

  config.before :suite do
    ActiveRecord::Base.class_eval do
      is_cached :repository => Cash::Transactional.new($memcache, $lock)
    end

    Character = Class.new(ActiveRecord::Base)
    Story = Class.new(ActiveRecord::Base)
    
    Story.has_many :characters

    Story.class_eval do
      index :title
      index [:id, :title]
      index :published
    end

    Short = Class.new(Story)
    Short.class_eval do
      index :subtitle, :order_column => 'title'
    end

    Epic = Class.new(Story)
    Oral = Class.new(Epic)

    Character.class_eval do
      index [:name, :story_id]
      index [:id, :story_id]
      index [:id, :name, :story_id]
    end

    Oral.class_eval do
      index :subtitle
    end
  end
end
