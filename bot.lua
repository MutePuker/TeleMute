package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  .. ';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'

-- @MuteTeam
tdcli = dofile('tdcli.lua')
redis = (loadfile "./libs/redis.lua")()

sudo_users = {
  105616381,
  0
}

-- Print message format. Use serpent for prettier result.
function vardump(value, depth, key)
  local linePrefix = ''
  local spaces = ''

  if key ~= nil then
    linePrefix = key .. ' = '
  end

  if depth == nil then
    depth = 0
  else
    depth = depth + 1
    for i=1, depth do 
      spaces = spaces .. '  '
    end
  end

  if type(value) == 'table' then
    mTable = getmetatable(value)
    if mTable == nil then
      print(spaces .. linePrefix .. '(table) ')
    else
      print(spaces .. '(metatable) ')
        value = mTable
    end
    for tableKey, tableValue in pairs(value) do
      vardump(tableValue, depth, tableKey)
    end
  elseif type(value)  == 'function' or 
    type(value) == 'thread' or 
    type(value) == 'userdata' or 
    value == nil then --@MuteTeam
      print(spaces .. tostring(value))
  elseif type(value)  == 'string' then
    print(spaces .. linePrefix .. '"' .. tostring(value) .. '",')
  else
    print(spaces .. linePrefix .. tostring(value) .. ',')
  end
end

-- Print callback
function dl_cb(arg, data)
  vardump(arg)
  vardump(data)
end

function is_sudo(msg)
  local var = false
  -- Check users id in config
  for v,user in pairs(sudo_users) do
    if user == msg.sender_user_id_ then
      var = true
    end
  end
  return var
end


function tdcli_update_callback(data)
  vardump(data)

  if (data.ID == "UpdateNewMessage") then
    local msg = data.message_
    local input = msg.content_.text_
    local chat_id = msg.chat_id_
    local user_id = msg.sender_user_id_
    local reply_id = msg.reply_to_message_id_
    vardump(msg)
    if msg.content_.ID == "MessageText" then
      if input == "ping" then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<code>pong</code>', 1, 'html')
      end
      if input == "PING" then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>PONG</b>', 1, 'html')
      end
      if input:match("^[#!/][Ii][Dd]$") then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>SuperGroup ID : </b><code>'..string.sub(chat_id, 5,14)..'</code>\n<b>User ID : </b><code>'..user_id..'</code>\n<b>Channel : </b>@MuteTeam', 1, 'html')
      end

      if input:match("^[#!/][Pp][Ii][Nn]") and reply_id then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Message Pinned</b>', 1, 'html')
        tdcli.pinChannelMessage(chat_id, reply_id, 1)
      end

      if input:match("^[#!/][Uu][Nn][Pp][Ii][Nn]") and reply_id then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Message UnPinned</b>', 1, 'html')
        tdcli.unpinChannelMessage(chat_id, reply_id, 1)
      end

      if input:match("^[#!/][Ll]ock links$") and is_sudo(msg) then
       if redis:get('lock_linkstg:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Link posting is already locked</b>', 1, 'html')
       else -- @MuteTeam
        redis:set('lock_linkstg:'..chat_id, true)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Link posting has been locked</b>', 1, 'html')
      end
      end 
      if input:match("^[#!/][Uu]nlock links$") and is_sudo(msg) then
       if not redis:get('lock_linkstg:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Link posting is not locked</b>', 1, 'html')
       else
         redis:del('lock_linkstg:'..chat_id)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Link posting has been unlocked</b>', 1, 'html')
      end
      end
      if redis:get('lock_linkstg:'..chat_id) and input:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
	  if input:match("^[#!/][Ll]ock username$") and is_sudo(msg) then
       if redis:get('lock_usernametg:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>username posting is already locked</b>', 1, 'html')
       else -- @MuteTeam
        redis:set('lock_usernametgtg:'..chat_id, true)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>username posting has been locked</b>', 1, 'html')
      end
      end 
      if input:match("^[#!/][Uu]nlock username$") and is_sudo(msg) then
       if not redis:get('lock_usernametgtg:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>username posting is not locked</b>', 1, 'html')
       else
         redis:del('lock_usernametgtg:'..chat_id)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>username posting has been unlocked</b>', 1, 'html')
      end
      end
      if redis:get('lock_usernametgtg:'..chat_id) and input:match("@") then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
      if input:match("^[#!/][Mm]ute all$") and is_sudo(msg) then
       if redis:get('mute_alltg:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Mute All is already on</b>', 1, 'html')
       else -- @MuteTeam
        redis:set('mute_alltg:'..chat_id, true)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Mute All has been enabled</b>', 1, 'html')
      end
      end
      if input:match("^[#!/][Uu]nmute all$") and is_sudo(msg) then
       if not redis:get('mute_alltg:'..chat_id) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Mute All is already disabled</b>', 1, 'html')
       else -- @MuteTeam
         redis:del('mute_alltg:'..chat_id)
        tdcli.sendMessage(chat_id, msg.id_, 1, '<b>Mute All has been disabled</b>', 1, 'html')
      end
      end
         local links = 'lock_linkstg:'..chat_id
	 if redis:get(links) then
	  Links = "yes"
	  else 
	  Links = "no"
	 end
	 local username = 'lock_usernametgtg:'..chat_id
	 if redis:get(user) then
	  user = "yes"
	  else 
	  user = "no"
	 end
         -- @MuteTeam
         local all = 'mute_alltg:'..chat_id
	 if redis:get(all) then
	  All = "yes"
	  else 
	  All = "no"
	 end
      if input:match("^[#!/][Ss]ettings$") and is_sudo(msg) then
        tdcli.sendMessage(chat_id, msg.id_, 1, '<i>SuperGroup Settings:</i>\n<b>__________________</b>\n\n<b>Lock Links : </b><code>'..Links..'</code>\n</b>\n\n<b>Lock username : </b><code>'..user..'</code>\n<b>Mute All : </b><code>'..All..'</code>\n', 1, 'html') -- @MuteTeam
      end
      if input:match("^[#!/][Ff]wd$") then
        tdcli.forwardMessages(chat_id, chat_id,{[0] = reply_id}, 0)
      end

      if input:match("^[#!/][Uu]sername") and is_sudo(msg) then
        tdcli.changeUsername(string.sub(input, 11))
         tdcli.sendMessage(chat_id, msg.id_, 1,'<b>Username Changed To </b>@'..string.sub(input, 11), 1, 'html')
      end

      if input:match("^[#!/][Ee]cho") then
        tdcli.sendMessage(chat_id, msg.id_, 1, string.sub(input, 7), 1, 'html')
      end

      if input:match("^[#!/][Ss]etname") then
        tdcli.changeChatTitle(chat_id, string.sub(input, 10), 1)
         tdcli.sendMessage(chat_id, msg.id_, 1,'<b>SuperGroup Name Changed To </b><code>'..string.sub(input, 10)..'</code>', 1, 'html')
      end
      if input:match("^[#!/][Ee]dit") then
        tdcli.editMessageText(chat_id, reply_id, nil, string.sub(input, 7), 'html')
      end

      if input:match("^[#!/][Cc]hangename") and is_sudo(msg) then
        tdcli.changeName(string.sub(input, 13), nil, 1)
         tdcli.sendMessage(chat_id, msg.id_, 1,'<b>Bot Name Changed To </b><code>'..string.sub(input, 13)..'</code>', 1, 'html')
      end

      if input:match("^[#!/][Ii]nvite") and is_sudo(msg) then
        tdcli.addChatMember(chat_id, string.sub(input, 9), 20)
      end
      if input:match("^[#!/][Cc]reatesuper") and is_sudo(msg) then
        tdcli.createNewChannelChat(string.sub(input, 14), 1, 'My Supergroup, my rules')
         tdcli.sendMessage(chat_id, msg.id_, 1,'<b>SuperGroup </b>'..string.sub(input, 14)..' <b>Created</b>', 1, 'html')
      end

      if input:match("^[#!/]view") then
        tdcli.viewMessages(chat_id, {[0] = msg.id_})
        tdcli.sendMessage(chat_id, msg.id_, 1,'<b>Messages Viewed</b>', 1, 'html')
      end
    end

   if redis:get('mute_alltg:'..chat_id) and msg then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end

  elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
    -- @MuteTeam
    tdcli_function ({
      ID="GetChats",
      offset_order_="9223372036854775807",
      offset_chat_id_=0,
      limit_=20
    }, dl_cb, nil)
  end
end
