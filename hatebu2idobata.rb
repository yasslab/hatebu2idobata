#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'feedjira'
require 'idobata'
#require 'simple-rss'
#require 'open-uri'

Idobata.hook_url = ENV['IDOBATA_END']
HATEBU_USERS = [
  "YassLab",
  # "Other Username"
]

msg = ""
HATEBU_USERS.each { |user|
  # Flush cache RSS before downloading
  #`curl -H 'Pragma: no-cache' -L b.hatena.ne.jp/#{user}/rss`
  `curl -o 'hatebu.rss' b.hatena.ne.jp/YassLab/rss`
  rss = RSS::Parser.parse("./hatebu.rss")

  # NOTE: Heroku Scheduler's frequency should be set to "Every 10 minutes"
  bookmarks = feed.entries.select do |entry|
    (Time.now - entry.published) / 60 <= 10
  end

  msg << bookmarks.map {|b|
    p "<a href='#{b.url}'>#{b.title}</a> by <span class='label label-info'>#{user}</span><br /> <b>#{b.summary}</b>"
  }.join("<br/>")
}

Idobata::Message.create(source: msg, format: :html) unless msg.empty?
