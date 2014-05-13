#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rss'
require 'idobata'

Idobata.hook_url = ENV['IDOBATA_END']
HATEBU_USERS = [
  "yasulabs",
  "h6n"
]

msg = ""
HATEBU_USERS.each { |user|
  # Flush cache RSS before downloading
  `curl -H 'Pragma: no-cache' -L b.hatena.ne.jp/yasulabs/rss`

  rss = RSS::Parser.parse("http://b.hatena.ne.jp/#{user}/rss")

  # NOTE: Heroku Scheduler should be set to "Every 10 minutes"
  now = Time.now
  bookmarks = rss.items.select do |item|
    (now - item.date) / 60 <= 10
  end

  msg << bookmarks.map {|b|
    p "<a href='#{b.link}'>#{b.title}</a> by <span class='label'>#{b.dc_creator}</span><br /> <b>#{b.description}<b/>"
  }.join("<br/>")
}

Idobata::Message.create(source: msg, format: :html) unless msg.empty?
