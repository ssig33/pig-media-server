config = Pit.get("Pig Media Server")

if File.exist? "#{config['groonga']}/search"
  Groonga::Database.open "#{config['groonga']}/search"
else
  FileUtils.mkdir_p config['groonga'] rescue nil
  Groonga::Database.create path: "#{config['groonga']}/search"
end

unless Groonga['Files']
  puts "create table 'Files'"
  Groonga::Schema.define do |schema|
    schema.create_table("Files", type: :patricia_trie, key_type: 'ShortText'){|table| 
      table.short_text "path"
      table.long_text "metadata"
      table.long_text "srt"
      table.short_text 'size'
      table.int64 "mtime"
    }
    schema.create_table("Index", type: :patricia_trie, key_type: "ShortText", default_tokenizer: "TokenBigram", key_normalize: true) { |table|  
      table.index "Files.path" 
      table.index "Files.metadata"
      table.index "Files.srt"
    }
  end
end
