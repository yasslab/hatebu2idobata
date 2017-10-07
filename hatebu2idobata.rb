#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rss'
require 'pry'
require 'idobata'

Idobata.hook_url = ENV['IDOBATA_END']
HATEBU_USERS = [
  "YassLab",
  # "Other Username"
]

msg = ""
HATEBU_USERS.each { |user|
  # Flush cache RSS before downloading
  `curl -H 'Pragma: no-cache' -L b.hatena.ne.jp/#{user}/rss`
  `curl -o 'hatebu.rss' b.hatena.ne.jp/YassLab/rss`
  rss = RSS::Parser.parse("./hatebu.rss")

  #rss = RSS::Parser.parse("http://b.hatena.ne.jp/#{user}/rss")
  #rss = Feedjira::Feed.fetch_and_parse("http://b.hatena.ne.jp/#{user}/rss")
  #rss = SimpleRSS.parse("http://b.hatena.ne.jp/#{user}/rss")
  #binding.pry
  # NOTE: Heroku Scheduler's frequency should be set to "Every 10 minutes"
  bookmarks = rss.items.select do |item|
    (Time.now - item.date) / 60 <= 10
  end

  msg << bookmarks.map {|b|
    p "<a href='#{b.link}'>#{b.title}</a> by <span class='label label-info'>#{user}</span><br /> <b>#{b.description}</b>"
  }.join("<br/>")
}

Idobata::Message.create(source: msg, format: :html) unless msg.empty?
