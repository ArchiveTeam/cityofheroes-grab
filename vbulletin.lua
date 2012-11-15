
read_file = function(file)
  local f = io.open(file)
  local data = f:read("*all")
  f:close()
  return data
end

url_count = 0

wget.callbacks.get_urls = function(file, url, is_css, iri)
  local urls = {}

  -- progress message
  url_count = url_count + 1
  if url_count % 25 == 0 then
    print(" - Downloaded "..url_count.." URLs")
  end

  base, forum_id = string.match(url, "(http://.+)/forumdisplay%.php%?f=(%d+)")
  if base then
    -- a forum page: listing subforums, anouncements and/or threads
    -- NOTE: this step does not explore subforums
    html = read_file(file)

    -- pages
    for f, o, p in string.gmatch(html, "forumdisplay%.php%?f=(%d+)&amp;order=(%l+)&amp;page=(%d+)") do
      table.insert(urls, { url=(base.."/forumdisplay.php?f="..f.."&order="..o.."&page="..p), link_expect_html=1 })
    end

    -- all announcements
    table.insert(urls, { url=(base.."/announcement.php?f="..forum_id), link_expect_html=1 })

    -- individual announcements
    for f, a in string.gmatch(html, "announcement%.php%?f=(%d+)&amp;a=(%d+)") do
      table.insert(urls, { url=(base.."/announcement.php?f="..f.."&a="..a), link_expect_html=1 })
    end

    -- threads
    for t in string.gmatch(html, "showthread%.php%?t=(%d+)") do
      table.insert(urls, { url=(base.."/showthread.php?t="..t), link_expect_html=1 })
      table.insert(urls, { url=(base.."/misc.php?do=whoposted&t="..t), link_expect_html=1 })
    end

    return urls
  end

  base, thread_id = string.match(url, "(http://.+)/showthread%.php%?t=(%d+)")
  if base then
    -- a thread page
    html = read_file(file)

    -- print
    table.insert(urls, { url=(base.."/printthread.php?t="..thread_id), link_expect_html=1 })
    table.insert(urls, { url=(base.."/printthread.php?t="..thread_id.."&pp=500"), link_expect_html=1 })

    -- pages
    for p in string.gmatch(html, "showthread%.php%?t="..thread_id.."&amp;page=(%d+)") do
      table.insert(urls, { url=(base.."/showthread.php?t="..thread_id.."&page="..p), link_expect_html=1 })
    end

    -- members
    for u in string.gmatch(html, "member%.php%?u=(%d+)") do
      table.insert(urls, { url=(base.."/member.php?u="..u), link_expect_html=1 })
    end

--  -- posts
--  for p, c in string.gmatch(html, "showpost%.php%?p=(%d+)&amp;postcount=(%d+)\"[^>]+id=\"postcount") do
--    table.insert(urls, { url=(base.."/showpost.php?p="..p.."&postcount="..c), link_expect_html=1 })
--    table.insert(urls, { url=(base.."/showthread.php?p="..p), link_expect_html=1 })
--  end

    return urls
  end
  
  return {}
end
