local url_count = 0
local tries = 0
local item_type = os.getenv('item_type')
local item_value = os.getenv('item_value')


read_file = function(file)
  if file then
    local f = assert(io.open(file))
    local data = f:read("*all")
    f:close()
    return data
  else
    return ""
  end
end


wget.callbacks.download_child_p = function(urlpos, parent, depth, start_url_parsed, iri, verdict, reason)
  local url = urlpos["url"]["url"]
  
  if verdict and string.match(url, '/images/') then
    -- don't waste time download common assets because we want
    -- to grab the game file before the download link expires
    return false
  end

  return verdict
end



wget.callbacks.get_urls = function(file, url, is_css, iri)
  local urls = {}
  local html = nil

  if string.match(url, "/download") then
      html = read_file(file)
    
      local link = string.match(html, '<a href="(/games/[^/]+/send_download%?code=[%w]+)">')
      link = 'http://sandbox.yoyogames.com' .. link
      
      table.insert(urls, { url=link })
   end

  return urls
end


wget.callbacks.httploop_result = function(url, err, http_stat)
  -- NEW for 2014: Slightly more verbose messages because people keep
  -- complaining that it's not moving or not working
  local status_code = http_stat["statcode"]

  url_count = url_count + 1
  io.stdout:write(url_count .. "=" .. status_code .. " " .. url["url"] .. ".  \n")
  io.stdout:flush()

  if status_code == 0 or status_code >= 500 or
    (status_code >= 400 and status_code ~= 404 and status_code ~= 403) then
    io.stdout:write("\nServer returned "..http_stat.statcode..". Sleeping.\n")
    io.stdout:flush()

    os.execute("sleep 5")

    tries = tries + 1

    if tries >= 5 then
      io.stdout:write("\nI give up...\n")
      io.stdout:flush()
      return wget.actions.ABORT
    else
      return wget.actions.CONTINUE
    end
  end

  tries = 0

  -- We're okay; sleep a bit (if we have to) and continue
  -- local sleep_time = 0.1 * (math.random(75, 1000) / 100.0)
  local sleep_time = 0

  --  if string.match(url["host"], "cdn") or string.match(url["host"], "media") then
  --    -- We should be able to go fast on images since that's what a web browser does
  --    sleep_time = 0
  --  end

  if sleep_time > 0.001 then
    os.execute("sleep " .. sleep_time)
  end

  return wget.actions.NOTHING
end
