#!/usr/bin/env ruby
# encoding: utf-8
# Version = '20141104-165903'

key_list = {}
File.readlines("pc_oxidized.sdf").each do |line|
  if line =~ /> <(.+)>/
    key = $1
    key_list[key] = true
  end
end
puts "|_.key|_.type|"
key_list.keys.each do |key|
  puts "|#{key}||"
end
