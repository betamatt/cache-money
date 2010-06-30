ActiveRecord::Schema.define(:version => 2) do
  create_table "stories", :force => true do |t|
    t.string "title", "subtitle"
    t.string  "type"
    t.boolean "published"
  end

  create_table "characters", :force => true do |t|
    t.integer "story_id"
    t.string "name"
  end
  
  create_table "plots", :force => true do |t|
  end
  
  create_table :sessions, :force => true do |t|
    t.string :session_id
    t.text   :data
    t.timestamps
  end
end
