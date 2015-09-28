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

unless Groonga['Datas']
  puts "create table 'Datas'"
  Groonga::Schema.define do |schema|
    schema.create_table("Datas", type: :patricia_trie, key_type: 'ShortText'){|table| 
      table.long_text "body"
      table.long_text 'original_key'
    }
  end
end

unless Groonga['Stars']
  puts "create table 'Stars'"
  Groonga::Schema.define do |schema|
    schema.create_table("Stars", type: :patricia_trie, key_type: 'ShortText'){|table| 
    }
  end
end

unless Groonga['Recents']
  puts "create table 'Recents'"
  Groonga::Schema.define do |schema|
    schema.create_table("Recents", type: :patricia_trie, key_type: 'ShortText'){|table| 
    }
  end
end

unless Groonga['QueryList']
  puts "create table 'QueryList'"
  Groonga::Schema.define do |schema|
    schema.create_table("QueryList", type: :patricia_trie, key_type: 'ShortText'){|table| table.short_text "query" }
  end

end
