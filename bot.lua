package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
  .. ';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'

-- @MuteTeam
tdcli = dofile('tdcli.lua')
redis = (loadfile "./libs/redis.lua")()
sudo_users = {
  238773538,
  173606679,
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
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '`pong`', 1, 'md')
		
      end
      if input == "PING" then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>PONG</b>', 1, 'html')
      end
      if input:match("^[#!/][Ii][Dd]$") then
	  tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>SuperGroup ID : </b><code>'..string.sub(chat_id, 5,14)..'</code>\n<b>User ID : </b><code>'..user_id..'</code>\n<b>Channel : </b>@MuteTeam', 1, 'html')
      end

      if input:match("^[#!/][Pp][Ii][Nn]$") and reply_id then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>Message Pinned</b>', 1, 'html')
        tdcli.pinChannelMessage(chat_id, reply_id, 1)
      end

      if input:match("^[#!/][Uu][Nn][Pp][Ii][Nn]$") and reply_id then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>Message UnPinned</b>', 1, 'html')
        tdcli.unpinChannelMessage(chat_id, reply_id, 1)
      end
	  

      		-----------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
		if input:match("^[#!/][Aa]dd$") and is_sudo(msg) then
		 redis:sadd('groups',chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Group Has Been Added!*', 1, 'md')
		end
		-------------------------------------------------------------------------------------------------------------------------------------------
		if input:match("^[#!/][Rr]em$") and is_sudo(msg) then
		redis:srem('groups',chat_id)
		 tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Group Has Been Removed!*', 1, 'md')
		 end
		 -----------------------------------------------------------------------------------------------------------------------------------------------
			
			--lock links
groups = redis:sismember('groups',chat_id)
      if input:match("^[#!/]lock links$") and is_sudo(msg) and groups then
       if redis:get('lock_linkstg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 Links is already Locked_', 1, 'md')
       else 
        redis:set('lock_linkstg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 Links Has Been Locked', 1, 'md')
      end
      end 
      if input:match("^[#!/]unlock links$")  and is_sudo(msg) and groups then
       if not redis:get('lock_linkstg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 links is already UnLocked', 1, 'md')
       else
         redis:del('lock_linkstg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nlinks Has Been UnLocked', 1, 'md')
      end
      end
	  --lock username
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^[#!/]lock username$") and is_sudo(msg) and groups then
       if redis:get('usernametg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 Username is already Locked', 1, 'md')
       else 
        redis:set('usernametg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nUsername Has Been Locked', 1, 'md')
      end
      end 
      if input:match("^[#!/]unlock username$") and is_sudo(msg) and groups then
       if not redis:get('usernametg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 Username is already UnLocked', 1, 'md')
       else
         redis:del('usernametg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nUsername Has Been UnLocked', 1, 'md')
      end
      end
	  --lock tag
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^[#!/]lock tag$") and is_sudo(msg) and groups then
       if redis:get('tagtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 Tag is already Locked', 1, 'md')
       else 
        redis:set('tagtg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nTag Has Been Locked', 1, 'md')
      end
      end 
      if input:match("^[#!/]unlock tag$") and is_sudo(msg) and groups then
       if not redis:get('tagtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 Tag is already Not Locked', 1, 'md')
       else
         redis:del('tagtg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\n.... Has Been UnLocked', 1, 'md')
      end
      end
	  --lock forward
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^[#!/]lock forward$") and is_sudo(msg) and groups then
       if redis:get('forwardtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 Forward is already Locked', 1, 'md')
       else 
        redis:set('forwardtg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nForward Has Been Locked', 1, 'md')
      end
      end 
      if input:match("^[#!/]unlock forward$") and is_sudo(msg) and groups then
       if not redis:get('forwardtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 Forward is already Not Locked', 1, 'md')
       else
         redis:del('forwardtg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nForward Has Been UnLocked', 1, 'md')
      end
      end
	  --arabic/persian
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^[#!/]lock arabic$") and is_sudo(msg) and groups then
       if redis:get('arabictg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 Persian/Arabic is already Locked', 1, 'md')
       else 
        redis:set('arabictg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nPersian/Arabic Has Been Locked', 1, 'md')
      end
      end 
      if input:match("^[#!/]unlock arabic$") and is_sudo(msg) and groups then
       if not redis:get('arabictg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 Persian/Arabic is already Not Locked', 1, 'md')
       else
         redis:del('arabictg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nPersian/Arabic Has Been UnLocked', 1, 'md')
      end
      end
	 ---english
	 groups = redis:sismember('groups',chat_id)
	  if input:match("^[#!/]lock english$") and is_sudo(msg) and groups then
       if redis:get('engtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 English is already Locked', 1, 'md')
       else 
        redis:set('engtg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nEnglish Has Been Locked', 1, 'md')
      end
      end 
      if input:match("^[#!/]unlock english$") and is_sudo(msg) and groups then
       if not redis:get('engtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 English is already Not Locked', 1, 'md')
       else
         redis:del('engtg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nEnglish Has Been UnLocked', 1, 'md')
      end
      end
	  --lock foshtg
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^[#!/]lock fosh$") and is_sudo(msg) and groups then
       if redis:get('badwordtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 Fosh is already Locked', 1, 'md')
       else 
        redis:set('badwordtg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nFosh Has Been Locked', 1, 'md')
      end
      end 
      if input:match("^[#!/]unlock fosh$") and is_sudo(msg) and groups then
       if not redis:get('badwordtg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 Fosh is already Not Locked', 1, 'md')
       else
         redis:del('badwordtg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nFosh Has Been UnLocked', 1, 'md')
      end
      end
	  --lock edit
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^[#!/]lock edit$") and is_sudo(msg) and groups then
       if redis:get('edittg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 Edit is already Locked', 1, 'md')
       else 
        redis:set('edittg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nEdit Has Been Locked', 1, 'md')
      end
      end 
      if input:match("^[#!/]unlock edit$") and is_sudo(msg) and groups then
       if not redis:get('edittg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 Edit is already Not Locked', 1, 'md')
       else
         redis:del('edittg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nEdit Has Been UnLocked', 1, 'md')
      end
      end
	  --- lock Caption
	  if input:match("^[#!/]lock caption$") and is_sudo(msg) and groups then
       if redis:get('captg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 Caption is already Locked', 1, 'md')
       else 
        redis:set('captg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nCaption Has Been Locked', 1, 'md')
      end
      end 
      if input:match("^[#!/]unlock caption$") and is_sudo(msg) and groups then
       if not redis:get('captg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 Caption is already Not Locked', 1, 'md')
       else
         redis:del('captg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nCaption Has Been UnLocked', 1, 'md')
      end
      end
	  --lock emoji
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^[#!/]lock emoji") and is_sudo(msg) and groups then
       if redis:get('emojitg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 Emoji is already Locked', 1, 'md')
       else 
        redis:set('emojitg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nEmoji Has Been Locked', 1, 'md')
      end
      end 
      if input:match("^[#!/]unlock emoji$") and is_sudo(msg) and groups then
       if not redis:get('emojitg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 Emoji is already Not Locked', 1, 'md')
       else
         redis:del('emojitg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nEmoji Has Been UNLocked', 1, 'md')
      end
      end
	  --- lock inline
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^[#!/]lock inline") and is_sudo(msg) and groups then
       if redis:get('inlinetg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 Inline is already Locked', 1, 'md')
       else 
        redis:set('inlinetg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nInline Has Been Locked', 1, 'md')
      end
      end 
      if input:match("^[#!/]unlock inline$") and is_sudo(msg) and groups then
       if not redis:get('inlinetg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 Inline is already Not Locked', 1, 'md')
       else
         redis:del('inlinetg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nInline Has Been UNLocked', 1, 'md')
      end
      end
	  -- lock reply
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^[#!/]lock reply") and is_sudo(msg) and groups then
       if redis:get('replytg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 Reply is already Locked', 1, 'md')
       else 
        redis:set('replytg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nReply Has Been Locked', 1, 'md')
      end
      end 
      if input:match("^[#!/]unlock reply$") and is_sudo(msg) and groups then
       if not redis:get('replytg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 Reply is already Not Locked', 1, 'md')
       else
         redis:del('replytg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nReply Has Been UNLocked', 1, 'md')
      end
      end
	  --lock tgservice
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^[#!/][Ll]ock tgservice$") and is_sudo(msg) and groups then
       if redis:get('tgservice:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 TGservice is already Locked', 1, 'md')
       else 
        redis:set('tgservice:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nTGservice Has Been Locked', 1, 'md')
      end
      end 
      if input:match("^[#!/][Uu]nlock tgservice$") and is_sudo(msg) and groups then
       if not redis:get('tgservice:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '🚫 TGservice is already Not Locked', 1, 'md')
       else
         redis:del('tgservice:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '✅ #Done\nTGservice Has Been UnLocked', 1, 'md')
      end
      end
	  
	  -----------------------------------------------------------------------------------------------------------------
local link = 'lock_linkstg:'..chat_id
	 if redis:get(link) then
	  link = "`Enable`"
	  else 
	  link = "`Disable`"
	 end
	 
	 local username = 'usernametg:'..chat_id
	 if redis:get(username) then
	  username = "`Enable`"
	  else 
	  username = "`Disable`"
	 end
	 
	 local tag = 'tagtg:'..chat_id
	 if redis:get(tag) then
	  tag = "`Enable`"
	  else 
	  tag = "`Disable`"
	 end
	 
	 local forward = 'forwardtg:'..chat_id
	 if redis:get(forward) then
	  forward = "`Enable`"
	  else 
	  forward = "`Disable`"
	 end
	 
	 local arabic = 'arabictg:'..chat_id
	 if redis:get(arabic) then
	  arabic = "`Enable`"
	  else 
	  arabic = "`Disable`"
	 end
	 
	 local eng = 'engtg:'..chat_id
	 if redis:get(eng) then
	  eng = "`Enable`"
	  else 
	  eng = "`Disable`"
	 end
	 
	 local badword = 'badwordtg:'..chat_id
	 if redis:get(badword) then
	  badword = "`Enable`"
	  else 
	  badword = "`Disable`"
	 end
	 
	 local edit = 'edittg:'..chat_id
	 if redis:get(edit) then
	  edit = "`Enable`"
	  else 
	  edit = "`Disable`"
	 end
	 
	 local emoji = 'emojitg:'..chat_id
	 if redis:get(emoji) then
	  emoji = "`Enable`"
	  else 
	  emoji = "`Disable`"
	 end
	 
	 local caption = 'captg:'..chat_id
	 if redis:get(caption) then
	  caption = "`Enable`"
	  else 
	  caption = "`Disable`"
	 end
	 
	 local inline = 'inlinetg:'..chat_id
	 if redis:get(inline) then
	  inline = "`Enable`"
	  else 
	  inline = "`Disable`"
	 end
	 
	 local reply = 'replytg:'..chat_id
	 if redis:get(reply) then
	  reply = "`Enable`"
	  else 
	  reply = "`Disable`"
	 end
	 ----------------------------
		--muteall
		groups = redis:sismember('groups',chat_id)
            if input:match("^[#!/][Mm]ute all$") and is_sudo(msg) and groups then
       if redis:get('mute_alltg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute All is already on*', 1, 'md')
       else 
       redis:set('mute_alltg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute All has been enabled*', 1, 'md')
      end
      end
      if input:match("^[#!/][Uu]nmute all$") and is_sudo(msg) and groups then
       if not redis:get('mute_alltg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute All is already disabled*', 1, 'md')
       else 
         redis:del('mute_alltg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute All has been disabled*', 1, 'md')
      end
      end	 

--mute sticker
groups = redis:sismember('groups',chat_id)
if input:match("^[#!/][Mm]ute sticker$") and is_sudo(msg) and groups then
       if redis:get('mute_stickertg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute sticker is already on*', 1, 'md')
       else
        redis:set('mute_stickertg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute sticker has been enabled*', 1, 'md')
      end
      end
      if input:match("^[#!/][Uu]nmute sticker$") and is_sudo(msg) and groups then
       if not redis:get('mute_stickertg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute sticker is already disabled*', 1, 'md')
       else 
         redis:del('mute_stickertg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute sticker has been disabled*', 1, 'md')
      end
      end		  
	  --mute gift
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^[#!/][Mm]ute gift$") and is_sudo(msg) and groups then
       if redis:get('mute_contacttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute gift is already on*', 1, 'md')
       else 
        redis:set('mute_contacttg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute gift has been enabled*', 1, 'md')
      end
      end
      if input:match("^[#!/][Uu]nmute gift$") and is_sudo(msg) and groups then
       if not redis:get('mute_contacttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute gift is already disabled*', 1, 'md')
       else 
         redis:del('mute_contacttg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute gift has been disabled*', 1, 'md')
      end
      end
	  --mute contact
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^[#!/][Mm]ute contact$") and is_sudo(msg) and groups then
       if redis:get('mute_contacttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute contact is already on*', 1, 'md')
       else 
        redis:set('mute_contacttg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute contact has been enabled*', 1, 'md')
      end
      end
      if input:match("^[#!/][Uu]nmute contact$") and is_sudo(msg) and groups then
       if not redis:get('mute_contacttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute contact is already disabled*', 1, 'md')
       else 
         redis:del('mute_contacttg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute contact has been disabled*', 1, 'md')
      end
      end
	  --mute photo
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^[#!/][Mm]ute photo$") and is_sudo(msg) and groups then
       if redis:get('mute_phototg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute photo is already on*', 1, 'md')
       else 
        redis:set('mute_phototg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute photo has been enabled*', 1, 'md')
      end
      end
      if input:match("^[#!/][Uu]nmute photo$") and is_sudo(msg) and groups then
       if not redis:get('mute_phototg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute photo is already disabled*', 1, 'md')
       else 
         redis:del('mute_phototg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute photo has been disabled*', 1, 'md')
      end
      end
	  --mute audio
	  groups = redis:sismember('groups',chat_id)
	  if input:match("^[#!/][Mm]ute audio$") and is_sudo(msg) and groups then
       if redis:get('mute_audiotg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute audio is already on*', 1, 'md')
       else 
        redis:set('mute_audiotg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute audio has been enabled*', 1, 'md')
      end
      end
      if input:match("^[#!/][Uu]nmute audio$") and is_sudo(msg) and groups then
       if not redis:get('mute_audiotg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute audio is already disabled*', 1, 'md')
       else 
         redis:del('mute_audiotg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute audio has been disabled*', 1, 'md')
	  end
      end
		--mute voice
		groups = redis:sismember('groups',chat_id)
		if input:match("^[#!/][Mm]ute voice$") and is_sudo(msg) and groups then
       if redis:get('mute_voicetg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute voice is already on*', 1, 'md')
       else 
        redis:set('mute_voicetg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute voice has been enabled*', 1, 'md')
      end
      end
      if input:match("^[#!/][Uu]nmute voice$") and is_sudo(msg) and groups then
       if not redis:get('mute_voicetg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute voice is already disabled*', 1, 'md')
       else 
         redis:del('mute_videotg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute voice has been disabled*', 1, 'md')
		end
		end
		--mute video
		groups = redis:sismember('groups',chat_id)
		if input:match("^[#!/][Mm]ute video$") and is_sudo(msg) and groups then
       if redis:get('mute_videotg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute video is already on*', 1, 'md')
       else 
        redis:set('mute_videotg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute video has been enabled*', 1, 'md')
      end
      end
      if input:match("^[#!/][Uu]nmute video$") and is_sudo(msg) and groups then
       if not redis:get('mute_videotg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute video is already disabled*', 1, 'md')
       else 
         redis:del('mute_videotg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute video has been disabled*', 1, 'md')
		end
		end
		--mute document
		groups = redis:sismember('groups',chat_id)
		if input:match("^[#!/][Mm]ute document$") and is_sudo(msg) and groups then
       if redis:get('mute_documenttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute document is already on*', 1, 'md')
       else 
        redis:set('mute_documenttg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute document has been enabled*', 1, 'md')
      end
      end
      if input:match("^[#!/][Uu]nmute document$") and is_sudo(msg) and groups then
       if not redis:get('mute_documenttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute document is already disabled*', 1, 'md')
       else 
         redis:del('mute_documenttg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute document has been disabled*', 1, 'md')
		end
		end
		--mute  text
		groups = redis:sismember('groups',chat_id)
		if input:match("^[#!/][Mm]ute text$") and is_sudo(msg) and groups then
       if redis:get('mute_texttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute text is already on*', 1, 'md')
       else 
        redis:set('mute_texttg:'..chat_id, true)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute text has been enabled*', 1, 'md')
      end
      end
      if input:match("^[#!/][Uu]nmute text$") and is_sudo(msg) and groups then
       if not redis:get('mute_texttg:'..chat_id) then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute text is already disabled*', 1, 'md')
       else 
         redis:del('mute_texttg:'..chat_id)
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*Mute text has been disabled*', 1, 'md')
		end
		end
		--settings
		local all = 'mute_alltg:'..chat_id
	 if redis:get(all) then
	  All = "`Mute`"
	  else 
	  All = "`UnMute`"
	 end
	 
	 local sticker = 'mute_stickertg:'..chat_id
	 if redis:get(sticker) then
	  sticker = "`Mute`"
	  else 
	  sticker = "`UnMute`"
	 end
	 
	 local gift = 'mute_gifttg:'..chat_id
	 if redis:get(gift) then
	  gift = "`Mute`"
	  else 
	  gift = "`UnMute`"
	 end
	 
	 local contact = 'mute_contacttg:'..chat_id
	 if redis:get(contact) then
	  contact = "`Mute`"
	  else 
	  contact = "`UnMute`"
	 end
	 
	 local photo = 'mute_phototg:'..chat_id
	 if redis:get(photo) then
	  photo = "`Mute`"
	  else 
	  photo = "`UnMute`"
	 end
	 
	 local audio = 'mute_audiotg:'..chat_id
	 if redis:get(audio) then
	  audio = "`Mute`"
	  else 
	  audio = "`UnMute`"
	 end
	 
	 local voice = 'mute_voicetg:'..chat_id
	 if redis:get(voice) then
	  voice = "`Mute`"
	  else 
	  voice = "`UnMute`"
	 end
	 
	 local video = 'mute_videotg:'..chat_id
	 if redis:get(video) then
	  video = "`Mute`"
	  else 
	  video = "`UnMute`"
	 end
	 
	 local document = 'mute_documenttg:'..chat_id
	 if redis:get(document) then
	  document = "`Mute`"
	  else 
	  document = "`UnMute`"
	 end
	 
	 local text1 = 'mute_texttg:'..chat_id
	 if redis:get(text1) then
	  text1 = "`Mute`"
	  else 
	  text1 = "`UnMute`"
	 end
      if input:match("^[#!/][Ss]ettings$") and is_sudo(msg) then
		local text = "👥 SuperGroup Settings :".."\n"
		.."*Lock Link => *".."`"..link.."`".."\n"
		.."*Lock Tag => *".."`"..tag.."`".."\n"
		.."*Lock Username => *".."`"..username.."`".."\n"
		.."*Lock Forward => *".."`"..forward.."`".."\n"
		.."*Lock Arabic/Persian => *".."`"..arabic..'`'..'\n'
		.."*Lock English => *".."`"..eng..'`'..'\n'
		.."*Lock Reply => *".."`"..reply..'`'..'\n'
		.."*Lock Fosh => *".."`"..badword..'`'..'\n'
		.."*Lock Edit => *".."`"..edit..'`'..'\n'
		.."*Lock Caption => *".."`"..caption..'`'..'\n'
		.."*Lock Inline => *".."`"..inline..'`'..'\n'
		.."*Lock Emoji => *".."`"..emoji..'`'..'\n'
		.."*➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖*".."\n"
		.."🗣 Mute List :".."\n"
		.."*Mute All : *".."`"..All.."`".."\n"
		.."*Mute Sticker : *".."`"..sticker.."`".."\n"
		.."*Mute Gift : *".."`"..gift.."`".."\n"
		.."*Mute Contact : *".."`"..contact.."`".."\n"
		.."*Mute Photo : *".."`"..photo.."`".."\n"
		.."*Mute Audio : *".."`"..audio.."`".."\n"
		.."*Mute Voice : *".."`"..voice.."`".."\n"
		.."*Mute Video : *".."`"..video.."`".."\n"
		.."*Mute Document : *".."`"..document.."`".."\n"
		.."*Mute Text : *".."`"..text1.."`".."\n"
		.."*Mute Team* - @MuteTeam"
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, text, 1, 'md')
		end
      if input:match("^[#!/][Ff]wd$") then
        tdcli.forwardMessages(chat_id, chat_id,{[0] = reply_id}, 0)
      end
	  
      if input:match("^[#!/][Uu]sername") and is_sudo(msg) then
        tdcli.changeUsername(string.sub(input, 11))
		 tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>Username Changed To </b>@'..string.sub(input, 11), 1, 'html')
      end
	  
      if input:match("^[#!/][Ee]cho") then
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, string.sub(input, 7), 1, 'html')
      end

      if input:match("^[#!/][Ss]etname") then
        tdcli.changeChatTitle(chat_id, string.sub(input, 10), 1)
		 tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>SuperGroup Name Changed To </b><code>'..string.sub(input, 10)..'</code>', 1, 'html')
      end
	  if input:match("^[#!/][Cc]hangename") and is_sudo(msg) then
        tdcli.changeName(string.sub(input, 13), nil, 1)
		 tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>Bot Name Changed To </b><code>'..string.sub(input, 13)..'</code>', 1, 'html')
      end
	  if input:match("^[#!/][Cc]hangeuser") and is_sudo(msg) then
        tdcli.changeUsername(string.sub(input, 13), nil, 1)
		 tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>Bot UserName Changed To </b><code>'..string.sub(input, 13)..'</code>', 1, 'html')
      end
	  if input:match("^[#!/][Dd]eluser") and is_sudo(msg) then
        tdcli.changeUsername('')
		 tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '#Done\nUsername Has Been Deleted', 1, 'html')
      end
      if input:match("^[#!/][Ee]dit") then
        tdcli.editMessageText(chat_id, reply_id, nil, string.sub(input, 7), 'html')
      end

	  if input:match("^[#!/]delpro") then
        tdcli.DeleteProfilePhoto(chat_id, {[0] = msg.id_})
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>#done profile has been deleted</b>', 1, 'html')
      end
	  
      if input:match("^[#!/][Ii]nvite") and is_sudo(msg) then
        tdcli.addChatMember(chat_id, string.sub(input, 9), 20)
      end
      if input:match("^[#!/][Cc]reatesuper") and is_sudo(msg) then
        tdcli.createNewChannelChat(string.sub(input, 14), 1, 'My Supergroup, my rules')
		 tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>SuperGroup </b>'..string.sub(input, 14)..' <b>Created</b>', 1, 'html')
      end

      if input:match("^[#!/]view") then
        tdcli.viewMessages(chat_id, {[0] = msg.id_})
		tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>Messages Viewed</b>', 1, 'html')
      end
    end

   local input = msg.content_.text_
if redis:get('mute_alltg:'..chat_id) and msg and not is_sudo(msg) then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end

   if redis:get('mute_stickertg:'..chat_id) and msg.content_.sticker_ and not is_sudo(msg) then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end
   
   if redis:get('mute_contacttg:'..chat_id) and msg.content_.animation_ and not is_sudo(msg) then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end
   
   if redis:get('mute_contacttg:'..chat_id) and msg.content_.contact_ and not is_sudo(msg) then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end
   
   if redis:get('mute_phototg:'..chat_id) and msg.content_.photo_ and not is_sudo(msg) then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end
   
   if redis:get('mute_audiotg:'..chat_id) and msg.content_.audio_ and not is_sudo(msg) then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end
   
   if redis:get('mute_voicetg:'..chat_id) and msg.content_.voice_  and not is_sudo(msg) then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end
   
   if redis:get('mute_videotg:'..chat_id) and msg.content_.video_ and not is_sudo(msg) then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end
   
   if redis:get('mute_documenttg:'..chat_id) and msg.content_.document_ and not is_sudo(msg) then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end
   
   if redis:get('mute_texttg:'..chat_id) and msg.content_.text_ and not is_sudo(msg) then
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end
      	  if redis:get('forwardtg:'..chat_id) and msg.forward_info_ and not is_sudo(msg) then 
     tdcli.deleteMessages(chat_id, {[0] = msg.id_})
   end
   
   if redis:get('lock_linkstg:'..chat_id) and input:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") and not is_sudo(msg) then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
	  
	        if redis:get('tagtg:'..chat_id) and input:match("#") and not is_sudo(msg) then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
	  
	  if redis:get('usernametg:'..chat_id) and input:match("@") and not is_sudo(msg) then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
	  
	  if redis:get('arabictg:'..chat_id) and input:match("[\216-\219][\128-\191]") and not is_sudo(msg) then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
	  
	 local is_english_msg = input:match("[a-z]") or input:match("[A-Z]")
	  if redis:get('engtg:'..chat_id) and is_english_msg and not is_sudo(msg) then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
	  
	  local is_fosh_msg = input:match("کیر") or input:match("کس") or input:match("کون") or input:match("85") or input:match("جنده") or input:match("ننه") or input:match("ننت") or input:match("مادر") or input:match("قهبه") or input:match("گایی") or input:match("سکس") or input:match("kir") or input:match("kos") or input:match("kon") or input:match("nne") or input:match("nnt")
	  if redis:get('badwordtg:'..chat_id) and is_fosh_msg and not is_sudo(msg) then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
	  
	 local is_emoji_msg = input:match("😀") or input:match("😬") or input:match("😁") or input:match("😂") or  input:match("😃") or input:match("😄") or input:match("😅") or input:match("☺️") or input:match("🙃") or input:match("🙂") or input:match("😊") or input:match("😉") or input:match("😇") or input:match("😆") or input:match("😋") or input:match("😌") or input:match("😍") or input:match("😘") or input:match("😗") or input:match("😙") or input:match("😚") or input:match("🤗") or input:match("😎") or input:match("🤓") or input:match("🤑") or input:match("😛") or input:match("😏") or input:match("😶") or input:match("😐") or input:match("😑") or input:match("😒") or input:match("🙄") or input:match("🤔") or input:match("😕") or input:match("😔") or input:match("😡") or input:match("😠") or input:match("😟") or input:match("😞") or input:match("😳") or input:match("🙁") or input:match("☹️") or input:match("😣") or input:match("😖") or input:match("😫") or input:match("😩") or input:match("😤") or input:match("😲") or input:match("😵") or input:match("😭") or input:match("😓") or input:match("😪") or input:match("😥") or input:match("😢") or input:match("🤐") or input:match("😷") or input:match("🤒") or input:match("🤕") or input:match("😴") or input:match("💋") or input:match("❤️")
	  if redis:get('emojitg:'..chat_id) and is_emoji_msg and not is_sudo(msg)  then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
		end
		
	  if redis:get('captg:'..chat_id) and  msg.content_.caption_ then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
	  
	  if redis:get('locatg:'..chat_id) and  msg.content_.location_ then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
	  
	  if redis:get('inlinetg:'..chat_id) and  msg.via_bot_user_id_ ~= 0 then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
	  
	  if redis:get('replytg:'..chat_id) and  msg.reply_to_message_id_ ~= 0 then
        tdcli.deleteMessages(chat_id, {[0] = msg.id_})
      end
	  
	  if redis:get('edittg:'..chat_id) and  msg.new_content_.text_:lower() or nil then
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
