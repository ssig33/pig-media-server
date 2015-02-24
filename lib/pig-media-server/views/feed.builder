xml.instruct! :xml, :version => '1.0'
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Pig Media Server -  feed - '#{h params[:query]}'"
    xml.description "pig feed"
    xml.link "http://#{config['hostname']}/?query=#{CGI.escape params[:query]}"

    @list.each do |p|
      xml.item do
        xml.title p.name
        xml.link p.url
        xml.description p.name
        xml.pubDate p.mtime.rfc822
        xml.guid p.url
        xml.key p.key
        xml.enclosure url: p.url, title: 'Podcast'
      end
    end
  end
end
