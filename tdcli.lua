-- Main Bot Framework
local M = {} 

local function dl_cb(arg, data)
end

local extra = nil

M.setFall = function(new_cb, new_extra)
  if type(new_cb) == 'function' then dl_cb = new_cb end
  if new_extra ~= nil then extra = new_extra end
end

-- There are chat_id, group_id, and channel_id
local function getChatId(id)
  local chat = {}
  local id = tostring(id)
  
  if id:match('^-100') then
    local channel_id = id:gsub('-100', '')
    chat = {ID = channel_id, type = 'channel'}
  else
    local group_id = id:gsub('-', '')
    chat = {ID = group_id, type = 'group'}
  end
  
  return chat
end

local function getInputMessageContent(file, filetype, caption)
  if file:match('/') then
    infile = {ID = "InputFileLocal", path_ = file}
  elseif file:match('^%d+$') then
    infile = {ID = "InputFileId", id_ = file}
  else
    infile = {ID = "InputFilePersistentId", persistent_id_ = file}
  end
  
  local inmsg = {}
  local filetype = filetype:lower()
  
  if filetype == 'animation' then
    inmsg = {ID = "InputMessageAnimation", animation_ = infile, caption_ = caption}
  elseif filetype == 'audio' then
    inmsg = {ID = "InputMessageAudio", audio_ = infile, caption_ = caption}
  elseif filetype == 'document' then
    inmsg = {ID = "InputMessageDocument", document_ = infile, caption_ = caption}
  elseif filetype == 'photo' then
    inmsg = {ID = "InputMessagePhoto", photo_ = infile, caption_ = caption}
  elseif filetype == 'sticker' then
    inmsg = {ID = "InputMessageSticker", sticker_ = infile, caption_ = caption}
  elseif filetype == 'video' then
    inmsg = {ID = "InputMessageVideo", video_ = infile, caption_ = caption}
  elseif filetype == 'voice' then
    inmsg = {ID = "InputMessageVoice", voice_ = infile, caption_ = caption}
  end
  
  return inmsg
end

-- User can send bold, italic, and monospace text uses HTML or Markdown format.
local function getParseMode(parse_mode)  
  if parse_mode then
    local mode = parse_mode:lower()
  
    if mode == 'markdown' or mode == 'md' then
      P = {ID = "TextParseModeMarkdown"}
    elseif mode == 'html' then
      P = {ID = "TextParseModeHTML"}
    end
  end
  
  return P
end

-- Returns current authorization state, offline request
local function getAuthState()
  tdcli_function ({
    ID = "GetAuthState",
  }, dl_cb, extra)
end

M.getAuthState = getAuthState

-- Sets user's phone number and sends authentication code to the user. Works only when authGetState returns authStateWaitPhoneNumber. If phone number is not recognized or another error has happened, returns an error. Otherwise returns authStateWaitCode
-- @phone_number User's phone number in any reasonable format @allow_flash_call Pass True, if code can be sent via flash call to the specified phone number @is_current_phone_number Pass true, if the phone number is used on the current device. Ignored if allow_flash_call is False
local function setAuthPhoneNumber(phone_number, allow_flash_call, is_current_phone_number)
  tdcli_function ({
    ID = "SetAuthPhoneNumber",
    phone_number_ = phone_number,
    allow_flash_call_ = allow_flash_call,
    is_current_phone_number_ = is_current_phone_number
  }, dl_cb, extra)
end

M.setAuthPhoneNumber = setAuthPhoneNumber

-- Resends authentication code to the user. Works only when authGetState returns authStateWaitCode and next_code_type of result is not null. Returns authStateWaitCode on success
local function resendAuthCode()
  tdcli_function ({
    ID = "ResendAuthCode",
  }, dl_cb, extra)
end

M.resendAuthCode = resendAuthCode

-- Checks authentication code. Works only when authGetState returns authStateWaitCode. Returns authStateWaitPassword or authStateOk on success @code Verification code from SMS, Telegram message, voice call or flash call
-- @first_name User first name, if user is yet not registered, 1-255 characters @last_name Optional user last name, if user is yet not registered, 0-255 characters
local function checkAuthCode(code, first_name, last_name)
  tdcli_function ({
    ID = "CheckAuthCode",
    code_ = code,
    first_name_ = first_name,
    last_name_ = last_name
  }, dl_cb, extra)
end

M.checkAuthCode = checkAuthCode

-- Checks password for correctness. Works only when authGetState returns authStateWaitPassword. Returns authStateOk on success @password Password to check
local function checkAuthPassword(password)
  tdcli_function ({
    ID = "CheckAuthPassword",
    password_ = password
  }, dl_cb, extra)
end

M.checkAuthPassword = checkAuthPassword

-- Requests to send password recovery code to email. Works only when authGetState returns authStateWaitPassword. Returns authStateWaitPassword on success
local function requestAuthPasswordRecovery()
  tdcli_function ({
    ID = "RequestAuthPasswordRecovery",
  }, dl_cb, extra)
end

M.requestAuthPasswordRecovery = requestAuthPasswordRecovery

-- Recovers password with recovery code sent to email. Works only when authGetState returns authStateWaitPassword. Returns authStateOk on success @recovery_code Recovery code to check
local function recoverAuthPassword(recovery_code)
  tdcli_function ({
    ID = "RecoverAuthPassword",
    recovery_code_ = recovery_code
  }, dl_cb, extra)
end

M.recoverAuthPassword = recoverAuthPassword

-- Logs out user. If force == false, begins to perform soft log out, returns authStateLoggingOut after completion. If force == true then succeeds almost immediately without cleaning anything at the server, but returns error with code 401 and description "Unauthorized"
-- @force If true, just delete all local data. Session will remain in list of active sessions
local function resetAuth(force)
  tdcli_function ({
    ID = "ResetAuth",
    force_ = force or nil
  }, dl_cb, extra)
end

M.resetAuth = resetAuth

-- Check bot's authentication token to log in as a bot. Works only when authGetState returns authStateWaitPhoneNumber. Can be used instead of setAuthPhoneNumber and checkAuthCode to log in. Returns authStateOk on success @token Bot token
local function checkAuthBotToken(token)
  tdcli_function ({
    ID = "CheckAuthBotToken",
    token_ = token
  }, dl_cb, extra)
end

M.checkAuthBotToken = checkAuthBotToken

-- Returns current state of two-step verification
local function getPasswordState()
  tdcli_function ({
    ID = "GetPasswordState",
  }, dl_cb, extra)
end

M.getPasswordState = getPasswordState

-- Changes user password. If new recovery email is specified, then error EMAIL_UNCONFIRMED is returned and password change will not be applied until email will be confirmed. Application should call getPasswordState from time to time to check if email is already confirmed
-- @old_password Old user password @new_password New user password, may be empty to remove the password @new_hint New password hint, can be empty @set_recovery_email Pass True, if recovery email should be changed @new_recovery_email New recovery email, may be empty
local function setPassword(old_password, new_password, new_hint, set_recovery_email, new_recovery_email)
  tdcli_function ({
    ID = "SetPassword",
    old_password_ = old_password,
    new_password_ = new_password,
    new_hint_ = new_hint,
    set_recovery_email_ = set_recovery_email,
    new_recovery_email_ = new_recovery_email
  }, dl_cb, extra)
end

M.setPassword = setPassword

-- Returns set up recovery email @password Current user password
local function getRecoveryEmail(password)
  tdcli_function ({
    ID = "GetRecoveryEmail",
    password_ = password
  }, dl_cb, extra)
end

M.getRecoveryEmail = getRecoveryEmail

-- Changes user recovery email @password Current user password @new_recovery_email New recovery email
local function setRecoveryEmail(password, new_recovery_email)
  tdcli_function ({
    ID = "SetRecoveryEmail",
    password_ = password,
    new_recovery_email_ = new_recovery_email
  }, dl_cb, extra)
end

M.setRecoveryEmail = setRecoveryEmail

-- Requests to send password recovery code to email
local function requestPasswordRecovery()
  tdcli_function ({
    ID = "RequestPasswordRecovery",
  }, dl_cb, extra)
end

M.requestPasswordRecovery = requestPasswordRecovery

-- Recovers password with recovery code sent to email @recovery_code Recovery code to check
local function recoverPassword(recovery_code)
  tdcli_function ({
    ID = "RecoverPassword",
    recovery_code_ = tostring(recovery_code)
  }, dl_cb, extra)
end

M.recoverPassword = recoverPassword

-- Returns current logged in user
local function getMe()
  tdcli_function ({
    ID = "GetMe",
  }, dl_cb, extra)
end

M.getMe = getMe

-- Returns information about a user by its identifier, offline request if current user is not a bot @user_id User identifier
local function getUser(user_id)
  tdcli_function ({
    ID = "GetUser",
    user_id_ = user_id
  }, dl_cb, extra)
end

M.getUser = getUser

-- Returns full information about a user by its identifier @user_id User identifier
local function getUserFull(user_id)
  tdcli_function ({
    ID = "GetUserFull",
    user_id_ = user_id
  }, dl_cb, extra)
end

M.getUserFull = getUserFull

-- Returns information about a group by its identifier, offline request if current user is not a bot @group_id Group identifier
local function getGroup(group_id)
  tdcli_function ({
    ID = "GetGroup",
    group_id_ = getChatId(group_id).ID
  }, dl_cb, extra)
end

M.getGroup = getGroup

-- Returns full information about a group by its identifier @group_id Group identifier
local function getGroupFull(group_id)
  tdcli_function ({
    ID = "GetGroupFull",
    group_id_ = getChatId(group_id).ID
  }, dl_cb, extra)
end

M.getGroupFull = getGroupFull

-- Returns information about a channel by its identifier, offline request if current user is not a bot @channel_id Channel identifier
local function getChannel(channel_id)
  tdcli_function ({
    ID = "GetChannel",
    channel_id_ = getChatId(channel_id).ID
  }, dl_cb, extra)
end

M.getChannel = getChannel

-- Returns full information about a channel by its identifier, cached for at most 1 minute @channel_id Channel identifier
local function getChannelFull(channel_id)
  tdcli_function ({
    ID = "GetChannelFull",
    channel_id_ = getChatId(channel_id).ID
  }, dl_cb, extra)
end

M.getChannelFull = getChannelFull

-- Returns information about a chat by its identifier, offline request if current user is not a bot @chat_id Chat identifier
local function getChat(chat_id)
  tdcli_function ({
    ID = "GetChat",
    chat_id_ = chat_id
  }, dl_cb, extra)
end

M.getChat = getChat

-- Returns information about a message @chat_id Identifier of the chat, message belongs to @message_id Identifier of the message to get
local function getMessage(chat_id, message_id)
  tdcli_function ({
    ID = "GetMessage",
    chat_id_ = chat_id,
    message_id_ = message_id
  }, dl_cb, extra)
end

M.getMessage = getMessage

-- Returns information about messages. If message is not found, returns null on the corresponding position of the result @chat_id Identifier of the chat, messages belongs to @message_ids Identifiers of the messages to get
local function getMessages(chat_id, message_ids)
  tdcli_function ({
    ID = "GetMessages",
    chat_id_ = chat_id,
    message_ids_ = message_ids -- vector
  }, dl_cb, extra)
end

M.getMessages = getMessages

-- Returns information about a file, offline request @file_id Identifier of the file to get
local function getFile(file_id)
  tdcli_function ({
    ID = "GetFile",
    file_id_ = file_id
  }, dl_cb, extra)
end

M.getFile = getFile

-- Returns information about a file by its persistent id, offline request @persistent_file_id Persistent identifier of the file to get
local function getFilePersistent(persistent_file_id)
  tdcli_function ({
    ID = "GetFilePersistent",
    persistent_file_id_ = persistent_file_id
  }, dl_cb, extra)
end

M.getFilePersistent = getFilePersistent

-- BAD RESULT
-- Returns list of chats in the right order, chats are sorted by (order, chat_id) in decreasing order. For example, to get list of chats from the beginning, the offset_order should be equal 2^63 - 1 @offset_order Chat order to return chats from @offset_chat_id Chat identifier to return chats from @limit Maximum number of chats to be returned
local function getChats(offset_order, offset_chat_id, limit)
  tdcli_function ({
    ID = "GetChats",
    offset_order_ = offset_order or 9223372036854775807,
    offset_chat_id_ = offset_chat_id or 0,
    limit_ = limit or 20
  }, dl_cb, extra)
end

M.getChats = getChats

-- Searches public chat by its username. Currently only private and channel chats can be public. Returns chat if found, otherwise some error is returned @username Username to be resolved
local function searchPublicChat(username)
  tdcli_function ({
    ID = "SearchPublicChat",
    username_ = username
  }, dl_cb, extra)
end

M.searchPublicChat = searchPublicChat

-- Searches public chats by prefix of their username. Currently only private and channel (including supergroup) chats can be public. Returns meaningful number of results. Returns nothing if length of the searched username prefix is less than 5. Excludes private chats with contacts from the results @username_prefix Prefix of the username to search
local function searchPublicChats(username_prefix)
  tdcli_function ({
    ID = "SearchPublicChats",
    username_prefix_ = username_prefix
  }, dl_cb, extra)
end

M.searchPublicChats = searchPublicChats

-- Searches for specified query in the title and username of known chats, offline request. Returns chats in the order of them in the chat list @query Query to search for, if query is empty, returns up to 20 recently found chats @limit Maximum number of chats to be returned
local function searchChats(query, limit)
  tdcli_function ({
    ID = "SearchChats",
    query_ = query,
    limit_ = limit    
  }, dl_cb, extra)
end

M.searchChats = searchChats

-- Adds chat to the list of recently found chats. The chat is added to the beginning of the list. If the chat is already in the list, at first it is removed from the list @chat_id Identifier of the chat to add
local function addRecentlyFoundChat(chat_id)
  tdcli_function ({
    ID = "AddRecentlyFoundChat",
    chat_id_ = chat_id
  }, dl_cb, extra)
end

M.addRecentlyFoundChat = addRecentlyFoundChat

-- Deletes chat from the list of recently found chats @chat_id Identifier of the chat to delete
local function deleteRecentlyFoundChat(chat_id)
  tdcli_function ({
    ID = "DeleteRecentlyFoundChat",
    chat_id_ = chat_id
  }, dl_cb, extra)
end

M.deleteRecentlyFoundChat = deleteRecentlyFoundChat

-- Clears list of recently found chats
local function deleteRecentlyFoundChats()
  tdcli_function ({
    ID = "DeleteRecentlyFoundChats",
  }, dl_cb, extra)
end

M.deleteRecentlyFoundChats = deleteRecentlyFoundChats

-- Returns list of common chats with an other given user. Chats are sorted by their type and creation date @user_id User identifier @offset_chat_id Chat identifier to return chats from, use 0 for the first request @limit Maximum number of chats to be returned, up to 100
local function getCommonChats(user_id, offset_chat_id, limit)
  tdcli_function ({
    ID = "GetCommonChats",
    user_id_ = user_id,
    offset_chat_id_ = offset_chat_id or 0,
    limit_ = limit or 100
  }, dl_cb, extra)
end

M.getCommonChats = getCommonChats

-- Returns messages in a chat. Automatically calls openChat. Returns result in reverse chronological order, i.e. in order of decreasing message.message_id @chat_id Chat identifier
-- @from_message_id Identifier of the message near which we need a history, you can use 0 to get results from the beginning, i.e. from oldest to newest
-- @offset Specify 0 to get results exactly from from_message_id or negative offset to get specified message and some newer messages
-- @limit Maximum number of messages to be returned, should be positive and can't be greater than 100. If offset is negative, limit must be greater than -offset. There may be less than limit messages returned even the end of the history is not reached
local function getChatHistory(chat_id, from_message_id, offset, limit)
  tdcli_function ({
    ID = "GetChatHistory",
    chat_id_ = chat_id,
    from_message_id_ = from_message_id,
    offset_ = offset,
    limit_ = limit
  }, dl_cb, extra)
end

M.getChatHistory = getChatHistory

-- Deletes all messages in the chat. Can't be used for channel chats @chat_id Chat identifier @remove_from_chat_list Pass true, if chat should be removed from the chat list
local function deleteChatHistory(chat_id, remove_from_chat_list)
  tdcli_function ({
    ID = "DeleteChatHistory",
    chat_id_ = chat_id,
    remove_from_chat_list_ = remove_from_chat_list
  }, dl_cb, extra)
end

M.deleteChatHistory = deleteChatHistory

-- Searches for messages with given words in the chat. Returns result in reverse chronological order, i. e. in order of decreasimg message_id. Doesn't work in secret chats @chat_id Chat identifier to search in
-- @query Query to search for @from_message_id Identifier of the message from which we need a history, you can use 0 to get results from beginning @limit Maximum number of messages to be returned, can't be greater than 100
-- @filter Filter for content of searched messages
-- filter = Empty|Animation|Audio|Document|Photo|Video|Voice|PhotoAndVideo|Url|ChatPhoto
local function searchChatMessages(chat_id, query, from_message_id, limit, filter)
  tdcli_function ({
    ID = "SearchChatMessages",
    chat_id_ = chat_id,
    query_ = query,
    from_message_id_ = from_message_id,
    limit_ = limit,
    filter_ = {
      ID = 'SearchMessagesFilter' .. filter
    },
  }, dl_cb, extra)
end

M.searchChatMessages = searchChatMessages
--searchChatMessages chat_id:long query:string from_message_id:int limit:int filter:SearchMessagesFilter = Messages;

-- Searches for messages in all chats except secret. Returns result in reverse chronological order, i. e. in order of decreasing (date, chat_id, message_id) @query Query to search for
-- @offset_date Date of the message to search from, you can use 0 or any date in the future to get results from the beginning
-- @offset_chat_id Chat identifier of the last found message or 0 for the first request
-- @offset_message_id Message identifier of the last found message or 0 for the first request
-- @limit Maximum number of messages to be returned, can't be greater than 100
local function searchMessages(query, offset_date, offset_chat_id, offset_message_id, limit)
  tdcli_function ({
    ID = "SearchMessages",
    query_ = query,
    offset_date_ = offset_date,
    offset_chat_id_ = offset_chat_id,
    offset_message_id_ = offset_message_id,
    limit_ = limit
  }, dl_cb, extra)
end

M.searchMessages = searchMessages

-- Sends a message. Returns sent message. UpdateChatTopMessage will not be sent, so returned message should be used to update chat top message @chat_id Chat to send message @reply_to_message_id Identifier of a message to reply to or 0
-- @disable_notification Pass true, to disable notification about the message @from_background Pass true, if the message is sent from background
-- @reply_markup Bots only. Markup for replying to message @input_message_content Content of a message to send
local function sendMessage(chat_id, reply_to_message_id, disable_notification, text, disable_web_page_preview, parse_mode)
  local TextParseMode = getParseMode(parse_mode)
  
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = 1,
    reply_markup_ = nil,
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = {},
      parse_mode_ = TextParseMode,
    },
  }, dl_cb, extra)
end

M.sendMessage = sendMessage
--sendMessage chat_id:long reply_to_message_id:int disable_notification:Bool from_background:Bool reply_markup:ReplyMarkup input_message_content:InputMessageContent = Message;

-- Invites bot to a chat (if it is not in the chat) and send /start to it. Bot can't be invited to a private chat other than chat with the bot. Bots can't be invited to broadcast channel chats. Returns sent message. UpdateChatTopMessage will not be sent, so returned message should be used to update chat top message
-- @bot_user_id Identifier of the bot @chat_id Identifier of the chat @parameter Hidden parameter sent to bot for deep linking (https://api.telegram.org/bots#deep-linking)
-- parameter=start|startgroup or custom as defined by bot creator
local function sendBotStartMessage(bot_user_id, chat_id, parameter)
  tdcli_function ({
    ID = "SendBotStartMessage",
    bot_user_id_ = bot_user_id,
    chat_id_ = chat_id,
    parameter_ = parameter
  }, dl_cb, extra)
end

M.sendBotStartMessage = sendBotStartMessage

-- Sends result of the inline query as a message. Returns sent message. UpdateChatTopMessage will not be sent, so returned message should be used to update chat top message. Always clears chat draft message @chat_id Chat to send message @reply_to_message_id Identifier of a message to reply to or 0
-- @disable_notification Pass true, to disable notification about the message @from_background Pass true, if the message is sent from background
-- @query_id Identifier of the inline query @result_id Identifier of the inline result
local function sendInlineQueryResultMessage(chat_id, reply_to_message_id, disable_notification, from_background, query_id, result_id)
  tdcli_function ({
    ID = "SendInlineQueryResultMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = from_background,
    query_id_ = query_id,
    result_id_ = result_id
  }, dl_cb, extra)
end

M.sendInlineQueryResultMessage = sendInlineQueryResultMessage

-- Forwards previously sent messages. Returns forwarded messages in the same order as message identifiers passed in message_ids. If message can't be forwarded, null will be returned instead of the message. UpdateChatTopMessage will not be sent, so returned messages should be used to update chat top message
-- @chat_id Identifier of a chat to forward messages @from_chat_id Identifier of a chat to forward from @message_ids Identifiers of messages to forward
-- @disable_notification Pass true, to disable notification about the message @from_background Pass true, if the message is sent from background
local function forwardMessages(chat_id, from_chat_id, message_ids, disable_notification)
  tdcli_function ({
    ID = "ForwardMessages",
    chat_id_ = chat_id,
    from_chat_id_ = from_chat_id,
    message_ids_ = message_ids, -- vector
    disable_notification_ = disable_notification,
    from_background_ = 1
  }, dl_cb, extra)
end

M.forwardMessages = forwardMessages

-- Deletes messages. UpdateDeleteMessages will not be sent for messages deleted through that function @chat_id Chat identifier @message_ids Identifiers of messages to delete
local function deleteMessages(chat_id, message_ids)
  tdcli_function ({
    ID = "DeleteMessages",
    chat_id_ = chat_id,
    message_ids_ = message_ids -- vector {[0] = id} or {id1, id2, id3, [0] = id}
  }, dl_cb, extra)
end

M.deleteMessages = deleteMessages

-- Edits text of text or game message. Non-bots can edit message in a limited period of time. Returns edited message after edit is complete server side
-- @chat_id Chat the message belongs to @message_id Identifier of the message @reply_markup Bots only. New message reply markup @input_message_content New text content of the message. Should be of type InputMessageText
local function editMessageText(chat_id, message_id, reply_markup, text, disable_web_page_preview)
  tdcli_function ({
    ID = "EditMessageText",
    chat_id_ = chat_id,
    message_id_ = message_id,
    reply_markup_ = reply_markup, -- reply_markup:ReplyMarkup
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = {}
    },
  }, dl_cb, extra)
end

M.editMessageText = editMessageText

-- Edits message content caption. Non-bots can edit message in a limited period of time. Returns edited message after edit is complete server side
-- @chat_id Chat the message belongs to @message_id Identifier of the message @reply_markup Bots only. New message reply markup @caption New message content caption, 0-200 characters
local function editMessageCaption(chat_id, message_id, reply_markup, caption)
  tdcli_function ({
    ID = "EditMessageCaption",
    chat_id_ = chat_id,
    message_id_ = message_id,
    reply_markup_ = reply_markup, -- reply_markup:ReplyMarkup
    caption_ = caption
  }, dl_cb, extra)
end

M.editMessageCaption = editMessageCaption

-- Bots only. Edits message reply markup. Returns edited message after edit is complete server side
-- @chat_id Chat the message belongs to @message_id Identifier of the message @reply_markup New message reply markup
local function editMessageReplyMarkup(inline_message_id, reply_markup, caption)
  tdcli_function ({
    ID = "EditInlineMessageCaption",
    inline_message_id_ = inline_message_id,
    reply_markup_ = reply_markup, -- reply_markup:ReplyMarkup
    caption_ = caption
  }, dl_cb, extra)
end

M.editMessageReplyMarkup = editMessageReplyMarkup

-- Bots only. Edits text of an inline text or game message sent via bot @inline_message_id Inline message identifier @reply_markup New message reply markup @input_message_content New text content of the message. Should be of type InputMessageText
local function editInlineMessageText(inline_message_id, reply_markup, text, disable_web_page_preview)
  tdcli_function ({
    ID = "EditInlineMessageText",
    inline_message_id_ = inline_message_id,
    reply_markup_ = reply_markup, -- reply_markup:ReplyMarkup
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = {}
    },
  }, dl_cb, extra)
end

M.editInlineMessageText = editInlineMessageText

-- Bots only. Edits caption of an inline message content sent via bot @inline_message_id Inline message identifier @reply_markup New message reply markup @caption New message content caption, 0-200 characters
local function editInlineMessageCaption(inline_message_id, reply_markup, caption)
  tdcli_function ({
    ID = "EditInlineMessageCaption",
    inline_message_id_ = inline_message_id,
    reply_markup_ = reply_markup, -- reply_markup:ReplyMarkup
    caption_ = caption
  }, dl_cb, extra)
end

M.editInlineMessageCaption = editInlineMessageCaption

-- Bots only. Edits reply markup of an inline message sent via bot @inline_message_id Inline message identifier @reply_markup New message reply markup
local function editInlineMessageReplyMarkup(inline_message_id, reply_markup)
  tdcli_function ({
    ID = "EditInlineMessageReplyMarkup",
    inline_message_id_ = inline_message_id,
    reply_markup_ = reply_markup -- reply_markup:ReplyMarkup
  }, dl_cb, extra)
end

M.editInlineMessageReplyMarkup = editInlineMessageReplyMarkup


-- Sends inline query to a bot and returns its results. Unavailable for bots @bot_user_id Identifier of the bot send query to @chat_id Identifier of the chat, where the query is sent @user_location User location, only if needed @query Text of the query @offset Offset of the first entry to return
local function getInlineQueryResults(bot_user_id, chat_id, latitude, longitude, query, offset)
  tdcli_function ({
    ID = "GetInlineQueryResults",
    bot_user_id_ = bot_user_id,
    chat_id_ = chat_id,
    user_location_ = {
      ID = "Location",
      latitude_ = latitude,
      longitude_ = longitude
    },
    query_ = query,
    offset_ = offset
  }, dl_cb, extra)
end

M.getInlineQueryResults = getInlineQueryResults

-- Bots only. Sets result of the inline query @inline_query_id Identifier of the inline query @is_personal Does result of the query can be cached only for specified user
-- @results Results of the query @cache_time Allowed time to cache results of the query in seconds @next_offset Offset for the next inline query, pass empty string if there is no more results
-- @switch_pm_text If non-empty, this text should be shown on the button, which opens private chat with the bot and sends bot start message with parameter switch_pm_parameter @switch_pm_parameter Parameter for the bot start message
local function answerInlineQuery(inline_query_id, is_personal, cache_time, next_offset, switch_pm_text, switch_pm_parameter)
  tdcli_function ({
    ID = "AnswerInlineQuery",
    inline_query_id_ = inline_query_id,
    is_personal_ = is_personal,
    results_ = results, --vector<InputInlineQueryResult>,
    cache_time_ = cache_time,
    next_offset_ = next_offset,
    switch_pm_text_ = switch_pm_text,
    switch_pm_parameter_ = switch_pm_parameter
  }, dl_cb, extra)
end

M.answerInlineQuery = answerInlineQuery

-- Sends callback query to a bot and returns answer to it. Unavailable for bots @chat_id Identifier of the chat with a message @message_id Identifier of the message, from which the query is originated @payload Query payload
local function getCallbackQueryAnswer(chat_id, message_id, text, show_alert, url)
  tdcli_function ({
    ID = "GetCallbackQueryAnswer",
    chat_id_ = chat_id,
    message_id_ = message_id,
    payload_ = {
      ID = "CallbackQueryAnswer",
      text_ = text,
      show_alert_ = show_alert,
      url_ = url
    },
  }, dl_cb, extra)
end

M.getCallbackQueryAnswer = getCallbackQueryAnswer

-- Bots only. Sets result of the callback query @callback_query_id Identifier of the callback query @text Text of the answer @show_alert If true, an alert should be shown to the user instead of a toast @url Url to be opened @cache_time Allowed time to cache result of the query in seconds
local function answerCallbackQuery(callback_query_id, text, show_alert, url, cache_time)
  tdcli_function ({
    ID = "AnswerCallbackQuery",
    callback_query_id_ = callback_query_id,
    text_ = text,
    show_alert_ = show_alert,
    url_ = url,
    cache_time_ = cache_time
  }, dl_cb, extra)
end

M.answerCallbackQuery = answerCallbackQuery

-- Bots only. Updates game score of the specified user in the game @chat_id Chat a message with the game belongs to @message_id Identifier of the message @edit_message True, if message should be edited @user_id User identifier @score New score
-- @force Pass True to update the score even if it decreases. If score is 0, user will be deleted from the high scores table
local function setGameScore(chat_id, message_id, edit_message, user_id, score, force)
  tdcli_function ({
    ID = "SetGameScore",
    chat_id_ = chat_id,
    message_id_ = message_id,
    edit_message_ = edit_message,
    user_id_ = user_id,
    score_ = score,
    force_ = force
  }, dl_cb, extra)
end

M.setGameScore = setGameScore

-- Bots only. Updates game score of the specified user in the game @inline_message_id Inline message identifier @edit_message True, if message should be edited @user_id User identifier @score New score
-- @force Pass True to update the score even if it decreases. If score is 0, user will be deleted from the high scores table
local function setInlineGameScore(inline_message_id, edit_message, user_id, score, force)
  tdcli_function ({
    ID = "SetInlineGameScore",
    inline_message_id_ = inline_message_id,
    edit_message_ = edit_message,
    user_id_ = user_id,
    score_ = score,
    force_ = force
  }, dl_cb, extra)
end

M.setInlineGameScore = setInlineGameScore

-- Bots only. Returns game high scores and some part of the score table around of the specified user in the game @chat_id Chat a message with the game belongs to @message_id Identifier of the message @user_id User identifie
local function getGameHighScores(chat_id, message_id, user_id)
  tdcli_function ({
    ID = "GetGameHighScores",
    chat_id_ = chat_id,
    message_id_ = message_id,
    user_id_ = user_id
  }, dl_cb, extra)
end

M.getGameHighScores = getGameHighScores

-- Bots only. Returns game high scores and some part of the score table around of the specified user in the game @inline_message_id Inline message identifier @user_id User identifier
local function getInlineGameHighScores(inline_message_id, user_id)
  tdcli_function ({
    ID = "GetInlineGameHighScores",
    inline_message_id_ = inline_message_id,
    user_id_ = user_id
  }, dl_cb, extra)
end

M.getInlineGameHighScores = getInlineGameHighScores

-- Deletes default reply markup from chat. This method needs to be called after one-time keyboard or ForceReply reply markup has been used. UpdateChatReplyMarkup will be send if reply markup will be changed @chat_id Chat identifier
-- @message_id Message identifier of used keyboard
local function deleteChatReplyMarkup(chat_id, message_id)
  tdcli_function ({
    ID = "DeleteChatReplyMarkup",
    chat_id_ = chat_id,
    message_id_ = message_id
  }, dl_cb, extra)
end

M.deleteChatReplyMarkup = deleteChatReplyMarkup

-- Sends notification about user activity in a chat @chat_id Chat identifier @action Action description
-- action = Typing|Cancel|RecordVideo|UploadVideo|RecordVoice|UploadVoice|UploadPhoto|UploadDocument|GeoLocation|ChooseContact|StartPlayGame
local function sendChatAction(chat_id, action, progress)
  tdcli_function ({
    ID = "SendChatAction",
    chat_id_ = chat_id,
    action_ = {
      ID = "SendMessage" .. action .. "Action",
      progress_ = progress or nil
    }
  }, dl_cb, extra)
end

M.sendChatAction = sendChatAction

-- Chat is opened by the user. Many useful activities depends on chat being opened or closed. For example, in channels all updates are received only for opened chats @chat_id Chat identifier
local function openChat(chat_id)
  tdcli_function ({
    ID = "OpenChat",
    chat_id_ = chat_id
  }, dl_cb, extra)
end

M.openChat = openChat

-- Chat is closed by the user. Many useful activities depends on chat being opened or closed. @chat_id Chat identifier
local function closeChat(chat_id)
  tdcli_function ({
    ID = "CloseChat",
    chat_id_ = chat_id
  }, dl_cb, extra)
end

M.closeChat = closeChat

-- Messages are viewed by the user. Many useful activities depends on message being viewed. For example, marking messages as read, incrementing of view counter, updating of view counter, removing of deleted messages in channels @chat_id Chat identifier @message_ids Identifiers of viewed messages
local function viewMessages(chat_id, message_ids)
  tdcli_function ({
    ID = "ViewMessages",
    chat_id_ = chat_id,
    message_ids_ = message_ids -- vector
  }, dl_cb, extra)
end

M.viewMessages = viewMessages

-- Message content is opened, for example the user has opened a photo, a video, a document, a location or a venue or have listened to an audio or a voice message @chat_id Chat identifier of the message @message_id Identifier of the message with opened content
local function openMessageContent(chat_id, message_id)
  tdcli_function ({
    ID = "OpenMessageContent",
    chat_id_ = chat_id,
    message_id_ = message_id
  }, dl_cb, extra)
end

M.openMessageContent = openMessageContent

-- Returns existing chat corresponding to the given user @user_id User identifier
local function createPrivateChat(user_id)
  tdcli_function ({
    ID = "CreatePrivateChat",
    user_id_ = user_id
  }, dl_cb, extra)
end

M.createPrivateChat = createPrivateChat

-- Returns existing chat corresponding to the known group @group_id Group identifier
local function createGroupChat(group_id)
  tdcli_function ({
    ID = "CreateGroupChat",
    group_id_ = getChatId(group_id).ID
  }, dl_cb, extra)
end

M.createGroupChat = createGroupChat

-- Returns existing chat corresponding to the known channel @channel_id Channel identifier
local function createChannelChat(channel_id)
  tdcli_function ({
    ID = "CreateChannelChat",
    channel_id_ = getChatId(channel_id).ID
  }, dl_cb, extra)
end

M.createChannelChat = createChannelChat

-- Returns existing chat corresponding to the known secret chat @secret_chat_id SecretChat identifier
local function createSecretChat(secret_chat_id)
  tdcli_function ({
    ID = "CreateSecretChat",
    secret_chat_id_ = secret_chat_id
  }, dl_cb, extra)
end

M.createSecretChat = createSecretChat

-- Creates new group chat and send corresponding messageGroupChatCreate, returns created chat @user_ids Identifiers of users to add to the group @title Title of new group chat, 0-255 characters
local function createNewGroupChat(user_ids, title)
  tdcli_function ({
    ID = "CreateNewGroupChat",
    user_ids_ = user_ids, -- vector
    title_ = title
  }, dl_cb, extra)
end

M.createNewGroupChat = createNewGroupChat

-- Creates new channel chat and send corresponding messageChannelChatCreate, returns created chat @title Title of new channel chat, 0-255 characters @is_supergroup True, if supergroup chat should be created @about Information about the channel, 0-255 characters
local function createNewChannelChat(title, is_supergroup, about)
  tdcli_function ({
    ID = "CreateNewChannelChat",
    title_ = title,
    is_supergroup_ = is_supergroup,
    about_ = about
  }, dl_cb, extra)
end

M.createNewChannelChat = createNewChannelChat

-- CRASHED
-- Creates new secret chat, returns created chat @user_id Identifier of a user to create secret chat with
local function createNewSecretChat(user_id)
  tdcli_function ({
    ID = "CreateNewSecretChat",
    user_id_ = user_id
  }, dl_cb, extra)
end

M.createNewSecretChat = createNewSecretChat

-- Creates new channel supergroup chat from existing group chat and send corresponding messageChatMigrateTo and messageChatMigrateFrom. Deactivates group @chat_id Group chat identifier
local function migrateGroupChatToChannelChat(chat_id)
  tdcli_function ({
    ID = "MigrateGroupChatToChannelChat",
    chat_id_ = chat_id
  }, dl_cb, extra)
end

M.migrateGroupChatToChannelChat = migrateGroupChatToChannelChat

-- Changes chat title. Title can't be changed for private chats. Title will not change until change will be synchronized with the server. Title will not be changed if application is killed before it can send request to the server.
-- - There will be update about change of the title on success. Otherwise error will be returned
-- @chat_id Chat identifier @title New title of a chat, 0-255 characters
local function changeChatTitle(chat_id, title)
  tdcli_function ({
    ID = "ChangeChatTitle",
    chat_id_ = chat_id,
    title_ = title
  }, dl_cb, extra)
end

M.changeChatTitle = changeChatTitle

-- Changes chat photo. Photo can't be changed for private chats. Photo will not change until change will be synchronized with the server. Photo will not be changed if application is killed before it can send request to the server.
-- - There will be update about change of the photo on success. Otherwise error will be returned @chat_id Chat identifier @photo New chat photo. You can use zero InputFileId to delete photo. Files accessible only by HTTP URL are not acceptable
local function changeChatPhoto(chat_id, file)
  tdcli_function ({
    ID = "ChangeChatPhoto",
    chat_id_ = chat_id,
    photo_ = {
      ID = "InputFileLocal",
      path_ = file
    }
  }, dl_cb, extra)
end

M.changeChatPhoto = changeChatPhoto

-- Changes chat draft message @chat_id Chat identifier @draft_message New draft message, nullable
local function changeChatDraftMessage(chat_id, reply_to_message_id, text, disable_web_page_preview, clear_draft, parse_mode)
  local TextParseMode = getParseMode(parse_mode)
  
  tdcli_function ({
    ID = "ChangeChatDraftMessage",
    chat_id_ = chat_id,
    draft_message_ = {
      ID = "DraftMessage",
      reply_to_message_id_ = reply_to_message_id,
      input_message_text_ = {
        ID = "InputMessageText",
        text_ = text,
        disable_web_page_preview_ = disable_web_page_preview,
        clear_draft_ = clear_draft,
        entities_ = {},
        parse_mode_ = TextParseMode,
      },
    },
  }, dl_cb, extra)
end

M.changeChatDraftMessage = changeChatDraftMessage

-- Adds new member to chat. Members can't be added to private or secret chats. Member will not be added until chat state will be synchronized with the server. Member will not be added if application is killed before it can send request to the server
-- @chat_id Chat identifier @user_id Identifier of the user to add @forward_limit Number of previous messages from chat to forward to new member, ignored for channel chats
local function addChatMember(chat_id, user_id, forward_limit)
  tdcli_function ({
    ID = "AddChatMember",
    chat_id_ = chat_id,
    user_id_ = user_id,
    forward_limit_ = forward_limit
  }, dl_cb, extra)
end

M.addChatMember = addChatMember

-- Adds many new members to the chat. Currently, available only for channels. Can't be used to join the channel. Member will not be added until chat state will be synchronized with the server. Member will not be added if application is killed before it can send request to the server
-- @chat_id Chat identifier @user_ids Identifiers of the users to add
local function addChatMembers(chat_id, user_ids)
  tdcli_function ({
    ID = "AddChatMembers",
    chat_id_ = chat_id,
    user_ids_ = user_ids -- vector
  }, dl_cb, extra)
end

M.addChatMembers = addChatMembers

-- Changes status of the chat member, need appropriate privileges. In channel chats, user will be added to chat members if he is yet not a member and there is less than 200 members in the channel.
-- Status will not be changed until chat state will be synchronized with the server. Status will not be changed if application is killed before it can send request to the server
-- @chat_id Chat identifier @user_id Identifier of the user to edit status, bots can be editors in the channel chats @status New status of the member in the chat
-- status = Creator|Editor|Moderator|Member|Left|Kicked
local function changeChatMemberStatus(chat_id, user_id, status)
  tdcli_function ({
    ID = "ChangeChatMemberStatus",
    chat_id_ = chat_id,
    user_id_ = user_id,
    status_ = {
      ID = "ChatMemberStatus" .. status
    },
  }, dl_cb, extra)
end

M.changeChatMemberStatus = changeChatMemberStatus

-- Returns information about one participant of the chat @chat_id Chat identifier @user_id User identifier
local function getChatMember(chat_id, user_id)
  tdcli_function ({
    ID = "GetChatMember",
    chat_id_ = chat_id,
    user_id_ = user_id
  }, dl_cb, extra)
end

M.getChatMember = getChatMember

-- Asynchronously downloads file from cloud. Updates updateFileProgress will notify about download progress. Update updateFile will notify about successful download @file_id Identifier of file to download
local function downloadFile(file_id)
  tdcli_function ({
    ID = "DownloadFile",
    file_id_ = file_id
  }, dl_cb, extra)
end

M.downloadFile = downloadFile

-- Stops file downloading. If file already downloaded do nothing. @file_id Identifier of file to cancel download
local function cancelDownloadFile(file_id)
  tdcli_function ({
    ID = "CancelDownloadFile",
    file_id_ = file_id
  }, dl_cb, extra)
end

M.cancelDownloadFile = cancelDownloadFile

-- Generates new chat invite link, previously generated link is revoked. Available for group and channel chats. Only creator of the chat can export chat invite link @chat_id Chat identifier
local function exportChatInviteLink(chat_id)
  tdcli_function ({
    ID = "ExportChatInviteLink",
    chat_id_ = chat_id
  }, dl_cb, extra)
end

M.exportChatInviteLink = exportChatInviteLink

-- Checks chat invite link for validness and returns information about the corresponding chat @invite_link Invite link to check. Should begin with "https:-- telegram.me/joinchat/"
local function checkChatInviteLink(link)
  tdcli_function ({
    ID = "CheckChatInviteLink",
    invite_link_ = link
  }, dl_cb, extra)
end

M.checkChatInviteLink = checkChatInviteLink

-- Imports chat invite link, adds current user to a chat if possible. Member will not be added until chat state will be synchronized with the server. Member will not be added if application is killed before it can send request to the server
-- @invite_link Invite link to import. Should begin with "https:-- telegram.me/joinchat/"
local function importChatInviteLink(invite_link)
  tdcli_function ({
    ID = "ImportChatInviteLink",
    invite_link_ = invite_link
  }, dl_cb, extra)
end

M.importChatInviteLink = importChatInviteLink

-- Adds user to black list @user_id User identifier
local function blockUser(user_id)
  tdcli_function ({
    ID = "BlockUser",
    user_id_ = user_id
  }, dl_cb, extra)
end

M.blockUser = blockUser

-- Removes user from black list @user_id User identifier
local function unblockUser(user_id)
  tdcli_function ({
    ID = "UnblockUser",
    user_id_ = user_id
  }, dl_cb, extra)
end

M.unblockUser = unblockUser

-- Returns users blocked by the current user @offset Number of users to skip in result, must be non-negative @limit Maximum number of users to return, can't be greater than 100
local function getBlockedUsers(offset, limit)
  tdcli_function ({
    ID = "GetBlockedUsers",
    offset_ = offset,
    limit_ = limit
  }, dl_cb, extra)
end

M.getBlockedUsers = getBlockedUsers

-- Adds new contacts/edits existing contacts, contacts user identifiers are ignored. Returns list of corresponding users in the same order as input contacts. If contact doesn't registered in Telegram, user with id == 0 will be returned @contacts List of contacts to import/edit
local function importContacts(phone_number, first_name, last_name, user_id)
  tdcli_function ({
    ID = "ImportContacts",
    contacts_ = {[0] = {
      phone_number_ = tostring(phone_number), 
      first_name_ = tostring(first_name), 
      last_name_ = tostring(last_name), 
      user_id_ = user_id
      },
    },
  }, dl_cb, extra)
end

M.importContacts = importContacts

-- Searches for specified query in the first name, last name and username of the known user contacts @query Query to search for, can be empty to return all contacts @limit Maximum number of users to be returned
local function searchContacts(query, limit)
  tdcli_function ({
    ID = "SearchContacts",
    query_ = query,
    limit_ = limit
  }, dl_cb, extra)
end

M.searchContacts = searchContacts

-- Deletes users from contacts list @user_ids Identifiers of users to be deleted
local function deleteContacts(user_ids)
  tdcli_function ({
    ID = "DeleteContacts",
    user_ids_ = user_ids -- vector
  }, dl_cb, extra)
end

M.deleteContacts = deleteContacts

-- Returns profile photos of the user. Result of this query can't be invalidated, so it must be used with care @user_id User identifier @offset Photos to skip, must be non-negative @limit Maximum number of photos to be returned, can't be greater than 100
local function getUserProfilePhotos(user_id, offset, limit)
  tdcli_function ({
    ID = "GetUserProfilePhotos",
    user_id_ = user_id,
    offset_ = offset,
    limit_ = limit
  }, dl_cb, extra)
end

M.getUserProfilePhotos = getUserProfilePhotos

-- Returns stickers corresponding to given emoji @emoji String representation of emoji. If empty, returns all known stickers
local function getStickers(emoji)
  tdcli_function ({
    ID = "GetStickers",
    emoji_ = emoji
  }, dl_cb, extra)
end

M.getStickers = getStickers

-- Returns list of installed sticker sets @only_enabled If true, returns only enabled sticker sets
local function getStickerSets(only_enabled)
  tdcli_function ({
    ID = "GetStickerSets",
    only_enabled_ = only_enabled
  }, dl_cb, extra)
end

M.getStickerSets = getStickerSets

-- Returns information about sticker set by its identifier @set_id Identifier of the sticker set
local function getStickerSet(set_id)
  tdcli_function ({
    ID = "GetStickerSet",
    set_id_ = set_id
  }, dl_cb, extra)
end

M.getStickerSet = getStickerSet

-- Searches sticker set by its short name @name Name of the sticker set
local function searchStickerSet(name)
  tdcli_function ({
    ID = "SearchStickerSet",
    name_ = name
  }, dl_cb, extra)
end

M.searchStickerSet = searchStickerSet

-- Installs/uninstalls or enables/archives sticker set. Official sticker set can't be uninstalled, but it can be archived @set_id Identifier of the sticker set @is_installed New value of is_installed @is_enabled New value of is_enabled
local function updateStickerSet(set_id, is_installed, is_enabled)
  tdcli_function ({
    ID = "UpdateStickerSet",
    set_id_ = set_id,
    is_installed_ = is_installed,
    is_enabled_ = is_enabled
  }, dl_cb, extra)
end

M.updateStickerSet = updateStickerSet

-- Returns saved animations
local function getSavedAnimations()
  tdcli_function ({
    ID = "GetSavedAnimations",
  }, dl_cb, extra)
end

M.getSavedAnimations = getSavedAnimations

-- Manually adds new animation to the list of saved animations. New animation is added to the beginning of the list. If the animation is already in the list, at first it is removed from the list. Only video animations with MIME type "video/mp4" can be added to the list
-- @animation Animation file to add. Only known to server animations (i. e. successfully sent via message) can be added to the list
local function addSavedAnimation(id)
  tdcli_function ({
    ID = "AddSavedAnimation",
    animation_ = {
      ID = "InputFileId",
      id_ = id
    },
  }, dl_cb, extra)
end

M.addSavedAnimation = addSavedAnimation

-- Removes animation from the list of saved animations @animation Animation file to delete
local function deleteSavedAnimation(id)
  tdcli_function ({
    ID = "DeleteSavedAnimation",
    animation_ = {
      ID = "InputFileId",
      id_ = id
    },
  }, dl_cb, extra)
end

M.deleteSavedAnimation = deleteSavedAnimation

-- Returns up to 20 recently used inline bots in the order of the last usage
local function getRecentInlineBots()
  tdcli_function ({
    ID = "GetRecentInlineBots",
  }, dl_cb, extra)
end

M.getRecentInlineBots = getRecentInlineBots

-- Get web page preview by text of the message. Do not call this function to often @message_text Message text
local function getWebPagePreview(message_text)
  tdcli_function ({
    ID = "GetWebPagePreview",
    message_text_ = message_text
  }, dl_cb, extra)
end

M.getWebPagePreview = getWebPagePreview

-- Returns notification settings for given scope @scope Scope to return information about notification settings
-- scope = Chat(chat_id)|PrivateChats|GroupChats|AllChats|
local function getNotificationSettings(scope, chat_id)
  tdcli_function ({
    ID = "GetNotificationSettings",
    scope_ = {
      ID = 'NotificationSettingsFor' .. scope,
      chat_id_ = chat_id or nil
    },
  }, dl_cb, extra)
end

M.getNotificationSettings = getNotificationSettings

-- Changes notification settings for given scope @scope Scope to change notification settings
-- @notification_settings New notification settings for given scope
-- scope = Chat(chat_id)|PrivateChats|GroupChats|AllChats|
local function setNotificationSettings(scope, chat_id, mute_for, show_preview)
  tdcli_function ({
    ID = "SetNotificationSettings",
    scope_ = {
      ID = 'NotificationSettingsFor' .. scope,
      chat_id_ = chat_id or nil
    },
    notification_settings_ = {
      ID = "NotificationSettings",
      mute_for_ = mute_for,
      sound_ = "default",
      show_preview_ = show_preview
    }
  }, dl_cb, extra)
end

M.setNotificationSettings = setNotificationSettings

-- Uploads new profile photo for logged in user. Photo will not change until change will be synchronized with the server. Photo will not be changed if application is killed before it can send request to the server. If something changes, updateUser will be sent @photo_path Path to new profile photo
local function setProfilePhoto(photo_path)
  tdcli_function ({
    ID = "SetProfilePhoto",
    photo_path_ = photo_path
  }, dl_cb, extra)
end

M.setProfilePhoto = setProfilePhoto

-- Deletes profile photo. If something changes, updateUser will be sent @profile_photo_id Identifier of profile photo to delete
local function deleteProfilePhoto(profile_photo_id)
  tdcli_function ({
    ID = "DeleteProfilePhoto",
    profile_photo_id_ = profile_photo_id
  }, dl_cb, extra)
end

M.deleteProfilePhoto = deleteProfilePhoto

-- Changes first and last names of logged in user. If something changes, updateUser will be sent @first_name New value of user first name, 1-255 characters @last_name New value of optional user last name, 0-255 characters
local function changeName(first_name, last_name)
  tdcli_function ({
    ID = "ChangeName",
    first_name_ = first_name,
    last_name_ = last_name
  }, dl_cb, extra)
end

M.changeName = changeName

-- Changes about information of logged in user @about New value of userFull.about, 0-255 characters
local function changeAbout(about)
  tdcli_function ({
    ID = "ChangeAbout",
    about_ = about
  }, dl_cb, extra)
end

M.changeAbout = changeAbout

-- Changes username of logged in user. If something changes, updateUser will be sent @username New value of username. Use empty string to remove username
local function changeUsername(username)
  tdcli_function ({
    ID = "ChangeUsername",
    username_ = username
  }, dl_cb, extra)
end

M.changeUsername = changeUsername

-- Changes user's phone number and sends authentication code to the new user's phone number. Returns authStateWaitCode with information about sent code on success
-- @phone_number New user's phone number in any reasonable format @allow_flash_call Pass True, if code can be sent via flash call to the specified phone number @is_current_phone_number Pass true, if the phone number is used on the current device. Ignored if allow_flash_call is False
local function changePhoneNumber(phone_number, allow_flash_call, is_current_phone_number)
  tdcli_function ({
    ID = "ChangePhoneNumber",
    phone_number_ = phone_number,
    allow_flash_call_ = allow_flash_call,
    is_current_phone_number_ = is_current_phone_number
  }, dl_cb, extra)
end

M.changePhoneNumber = changePhoneNumber

-- Resends authentication code sent to change user's phone number. Wotks only if in previously received authStateWaitCode next_code_type was not null. Returns authStateWaitCode on success
local function resendChangePhoneNumberCode()
  tdcli_function ({
    ID = "ResendChangePhoneNumberCode",
  }, dl_cb, extra)
end

M.resendChangePhoneNumberCode = resendChangePhoneNumberCode

-- Checks authentication code sent to change user's phone number. Returns authStateOk on success @code Verification code from SMS, voice call or flash call
local function checkChangePhoneNumberCode(code)
  tdcli_function ({
    ID = "CheckChangePhoneNumberCode",
    code_ = code
  }, dl_cb, extra)
end

M.checkChangePhoneNumberCode = checkChangePhoneNumberCode

-- Returns all active sessions of logged in user
local function getActiveSessions()
  tdcli_function ({
    ID = "GetActiveSessions",
  }, dl_cb, extra)
end

M.getActiveSessions = getActiveSessions

-- Terminates another session of logged in user @session_id Session identifier
local function terminateSession(session_id)
  tdcli_function ({
    ID = "TerminateSession",
    session_id_ = session_id
  }, dl_cb, extra)
end

M.terminateSession = terminateSession

-- Terminates all other sessions of logged in user
local function terminateAllOtherSessions()
  tdcli_function ({
    ID = "TerminateAllOtherSessions",
  }, dl_cb, extra)
end

M.terminateAllOtherSessions = terminateAllOtherSessions

-- Gives or revokes all members of the group editor rights. Needs creator privileges in the group @group_id Identifier of the group @anyone_can_edit New value of anyone_can_edit
local function toggleGroupEditors(group_id, anyone_can_edit)
  tdcli_function ({
    ID = "ToggleGroupEditors",
    group_id_ = getChatId(group_id).ID,
    anyone_can_edit_ = anyone_can_edit
  }, dl_cb, extra)
end

M.toggleGroupEditors = toggleGroupEditors

-- Changes username of the channel. Needs creator privileges in the channel @channel_id Identifier of the channel @username New value of username. Use empty string to remove username
local function changeChannelUsername(channel_id, username)
  tdcli_function ({
    ID = "ChangeChannelUsername",
    channel_id_ = getChatId(channel_id).ID,
    username_ = username
  }, dl_cb, extra)
end

M.changeChannelUsername = changeChannelUsername

-- Gives or revokes right to invite new members to all current members of the channel. Needs creator privileges in the channel. Available only for supergroups @channel_id Identifier of the channel @anyone_can_invite New value of anyone_can_invite
local function toggleChannelInvites(channel_id, anyone_can_invite)
  tdcli_function ({
    ID = "ToggleChannelInvites",
    channel_id_ = getChatId(channel_id).ID,
    anyone_can_invite_ = anyone_can_invite
  }, dl_cb, extra)
end

M.toggleChannelInvites = toggleChannelInvites

-- Enables or disables sender signature on sent messages in the channel. Needs creator privileges in the channel. Not available for supergroups @channel_id Identifier of the channel @sign_messages New value of sign_messages
local function toggleChannelSignMessages(channel_id, sign_messages)
  tdcli_function ({
    ID = "ToggleChannelSignMessages",
    channel_id_ = getChatId(channel_id).ID,
    sign_messages_ = sign_messages
  }, dl_cb, extra)
end

M.toggleChannelSignMessages = toggleChannelSignMessages

-- Changes information about the channel. Needs creator privileges in the broadcast channel or editor privileges in the supergroup channel @channel_id Identifier of the channel @about New value of about, 0-255 characters
local function changeChannelAbout(channel_id, about)
  tdcli_function ({
    ID = "ChangeChannelAbout",
    channel_id_ = getChatId(channel_id).ID,
    about_ = about
  }, dl_cb, extra)
end

M.changeChannelAbout = changeChannelAbout

-- Pins a message in a supergroup channel chat. Needs editor privileges in the channel @channel_id Identifier of the channel @message_id Identifier of the new pinned message @disable_notification True, if there should be no notification about the pinned message
local function pinChannelMessage(channel_id, message_id, disable_notification)
  tdcli_function ({
    ID = "PinChannelMessage",
    channel_id_ = getChatId(channel_id).ID,
    message_id_ = message_id,
    disable_notification_ = disable_notification
  }, dl_cb, extra)
end

M.pinChannelMessage = pinChannelMessage

-- Removes pinned message in the supergroup channel. Needs editor privileges in the channel @channel_id Identifier of the channel
local function unpinChannelMessage(channel_id)
  tdcli_function ({
    ID = "UnpinChannelMessage",
    channel_id_ = getChatId(channel_id).ID
  }, dl_cb, extra)
end

M.unpinChannelMessage = unpinChannelMessage

-- Reports some supergroup channel messages from a user as spam messages @channel_id Channel identifier @user_id User identifier @message_ids Identifiers of messages sent in the supergroup by the user, the list should be non-empty
local function reportChannelSpam(channel_id, user_id, message_ids)
  tdcli_function ({
    ID = "ReportChannelSpam",
    channel_id_ = getChatId(channel_id).ID, 
    user_id_ = user_id, 
    message_ids_ = message_ids -- vector
  }, dl_cb, extra)
end

M.reportChannelSpam = reportChannelSpam

-- Returns information about channel members or kicked from channel users. Can be used only if channel_full->can_get_members == true @channel_id Identifier of the channel
-- @filter Kind of channel users to return, defaults to channelMembersRecent @offset Number of channel users to skip @limit Maximum number of users be returned, can't be greater than 200
-- filter = Recent|Administrators|Kicked|Bots
local function getChannelMembers(channel_id, offset, filter, limit)
  tdcli_function ({
    ID = "GetChannelMembers",
    channel_id_ = getChatId(channel_id).ID,
    filter_ = {
      ID = "ChannelMembers" .. filter
    },
    offset_ = offset,
    limit_ = limit
  }, dl_cb, extra)
end

M.getChannelMembers = getChannelMembers

-- Deletes channel along with all messages in corresponding chat. Releases channel username and removes all members. Needs creator privileges in the channel. Channels with more than 1000 members can't be deleted @channel_id Identifier of the channel
local function deleteChannel(channel_id)
  tdcli_function ({
    ID = "DeleteChannel",
    channel_id_ = getChatId(channel_id).ID
  }, dl_cb, extra)
end

M.deleteChannel = deleteChannel

-- Returns user that can be contacted to get support
local function getSupportUser()
  tdcli_function ({
    ID = "GetSupportUser",
  }, dl_cb, extra)
end

M.getSupportUser = getSupportUser

-- Returns background wallpapers
local function getWallpapers()
  tdcli_function ({
    ID = "GetWallpapers",
  }, dl_cb, extra)
end

M.getWallpapers = getWallpapers

local function registerDevice()
  tdcli_function ({
    ID = "RegisterDevice",
  }, dl_cb, extra)
end

M.registerDevice = registerDevice
--registerDevice device_token:DeviceToken = Ok;

local function getDeviceTokens()
  tdcli_function ({
    ID = "GetDeviceTokens",
  }, dl_cb, extra)
end

M.getDeviceTokens = getDeviceTokens

-- CRASHED
-- Changes privacy settings @key Privacy key @rules New privacy rules
-- key = UserStatus|ChatInvite
-- rules = AllowAll|AllowContacts|AllowUsers(user_ids)|DisallowAll|DisallowContacts|DisallowUsers(user_ids)
local function setPrivacy(key, rules, user_ids)  
  if user_ids and rules:match('Allow') then
    rule = 'AllowUsers'
  elseif user_ids and rules:match('Disallow') then
    rule = 'DisallowUsers'
  end
  
  tdcli_function ({
    ID = "SetPrivacy",
    key_ = {
      ID = 'PrivacyKey' .. key,
    },
    rules_ = {
      ID = 'PrivacyRules',
      rules_ = {
        [0] = {
          ID = 'PrivacyRule' .. rules,
        },
        {
          ID = 'PrivacyRule' .. rule,
          user_ids_ = user_ids
        },
      },
    },
  }, dl_cb, extra)
end

M.setPrivacy = setPrivacy

-- Returns current privacy settings @key Privacy key
-- key = UserStatus|ChatInvite
local function getPrivacy(key)
  tdcli_function ({
    ID = "GetPrivacy",
    key_ = {
      ID = "PrivacyKey" .. key
    },
  }, dl_cb, extra)
end

M.getPrivacy = getPrivacy

-- Returns value of an option by its name. See list of available options on https://core.telegram.org/tdlib/options
-- @name Name of the option
local function getOption(name)
  tdcli_function ({
    ID = "GetOption",
    name_ = name
  }, dl_cb, extra)
end

M.getOption = getOption

-- CRASHED
-- Sets value of an option. See list of available options on https://core.telegram.org/tdlib/options. Only writable options can be set
-- @name Name of the option @value New value of the option
local function setOption(name, option, value)
  tdcli_function ({
    ID = "SetOption",
    name_ = name,
    value_ = {
      ID = 'Option' .. option,
      value_ = value
    },
  }, dl_cb, extra)
end

M.setOption = setOption

-- Changes period of inactivity, after which the account of currently logged in user will be automatically deleted @ttl New account TTL
local function changeAccountTtl(days)
  tdcli_function ({
    ID = "ChangeAccountTtl",
    ttl_ = {
      ID = "AccountTtl",
      days_ = days
    },
  }, dl_cb, extra)
end

M.changeAccountTtl = changeAccountTtl

-- Returns period of inactivity, after which the account of currently logged in user will be automatically deleted
local function getAccountTtl()
  tdcli_function ({
    ID = "GetAccountTtl",
  }, dl_cb, extra)
end

M.getAccountTtl = getAccountTtl

-- Deletes the account of currently logged in user, deleting from the server all information associated with it. Account's phone number can be used to create new account, but only once in two weeks @reason Optional reason of account deletion
local function deleteAccount(reason)
  tdcli_function ({
    ID = "DeleteAccount",
    reason_ = reason
  }, dl_cb, extra)
end

M.deleteAccount = deleteAccount

-- Returns current chat report spam state @chat_id Chat identifier
local function getChatReportSpamState(chat_id)
  tdcli_function ({
    ID = "GetChatReportSpamState",
    chat_id_ = chat_id
  }, dl_cb, extra)
end

M.getChatReportSpamState = getChatReportSpamState

-- Reports chat as a spam chat or as not a spam chat. Can be used only if ChatReportSpamState.can_report_spam is true. After this request ChatReportSpamState.can_report_spam became false forever @chat_id Chat identifier @is_spam_chat If true, chat will be reported as a spam chat, otherwise it will be marked as not a spam chat
local function changeChatReportSpamState(chat_id, is_spam_chat)
  tdcli_function ({
    ID = "ChangeChatReportSpamState",
    chat_id_ = chat_id,
    is_spam_chat_ = is_spam_chat
  }, dl_cb, extra)
end

M.changeChatReportSpamState = changeChatReportSpamState

-- Bots only. Informs server about number of pending bot updates if they aren't processed for a long time @pending_update_count Number of pending updates @error_message Last error's message
local function setBotUpdatesStatus(pending_update_count, error_message)
  tdcli_function ({
    ID = "SetBotUpdatesStatus",
    pending_update_count_ = pending_update_count,
    error_message_ = error_message
  }, dl_cb, extra)
end

M.setBotUpdatesStatus = setBotUpdatesStatus

-- Returns Ok after specified amount of the time passed @seconds Number of seconds before that function returns
local function setAlarm(seconds)
  tdcli_function ({
    ID = "SetAlarm",
    seconds_ = seconds
  }, dl_cb, extra)
end

M.setAlarm = setAlarm


-- These functions below are an effort to mimic telegram-cli console commands --

-- Tries to add user to contact list
local function add_contact(phone, first_name, last_name, user_id)
  tdcli.importContacts(phone, first_name, last_name, user_id)
end

M.add_contact = add_contact

-- Gets channel admins
local function channel_get_admins(channel, limit, offset)
  tdcli.getChannelMembers(channel, offset, 'Administrators', limit)
end

M.channel_get_admins = channel_get_admins

-- Gets channel tdcli.
local function channel_get_bots(channel, limit, offset)
  tdcli.getChannelMembers(channel, offset, 'Bots', limit)
end

M.channel_get_bots = channel_get_bots

-- Gets channel kicked members
local function channel_get_kicked(channel, limit, offset)
  tdcli.getChannelMembers(channel, offset, 'Kicked', limit)
end

M.channel_get_kicked = channel_get_kicked

-- changes value of basic channel parameters.
-- param=sign|invites
local function channel_edit(channel_id, param, enabled)
  local channel_id = getChatId(channel_id).ID
  
  if param:lower() == 'sign' then
    tdcli.toggleChannelSignMessages(channel_id, enabled)
  elseif param:lower() == 'invites' then
    tdcli.toggleChannelInvites(channel_id, enabled)
  end
end
M.channel_edit = channel_edit

-- changes user's role in chat.
-- role=Creator|Editor|Moderator|Member|Left|Kicked
local function chat_change_role(chat_id, user_id, role)
  tdcli.changeChatMemberStatus(chat_id, user_id, role)
end

M.chat_change_role = chat_change_role

-- Deletes user from chat
local function chat_del_user(chat_id, user_id)
  tdcli.changeChatMemberStatus(chat_id, user_id, 'Editor')
end

M.chat_del_user = chat_del_user

-- Prints info about chat
local function chat_info(chat_id)
  tdcli.getChat(chat_id)
end

M.chat_info = chat_info

-- Joins to chat (by invite link)
local function chat_join(chat_id)
  tdcli.importChatInviteLink(chat_id)
end

M.chat_join = chat_join

-- Leaves chat
local function chat_leave(chat_id, user_id)
  tdcli.changeChatMemberStatus(chat_id, user_id, "Left")
end

M.chat_leave = chat_leave

-- Creates broadcast channel
local function chat_create_broadcast(title, about)
  tdcli.createNewChannelChat(title, 0, about)
end

M.chat_create_broadcast = chat_create_broadcast

-- Creates group chat
local function chat_create_group(title, user_ids)
  tdcli.createNewGroupChat(title, user_ids)
end

M.chat_create_group = chat_create_group

-- Creates supergroup channel
local function chat_create_supergroup(title, about)
  tdcli.createNewChannelChat(title, 1, about)
end

M.chat_create_supergroup = chat_create_supergroup

-- Prints contact list
local function contact_list(limit)
  tdcli.searchContacts("", limit)
end

M.contact_list = contact_list

-- List of last conversations
local function dialog_list(limit)
  tdcli.searchChats("", limit)
end

M.dialog_list = dialog_list

-- Upgrades group to supergroup
local function group_upgrade(chat_id)
  tdcli.migrateGroupChatToChannelChat(chat_id)
end

M.group_upgrade = group_upgrade

-- Marks messages with peer as read
local function mark_read(chat_id, message_ids)
  tdcli.viewMessages(chat_id, message_ids)
end

M.mark_read = mark_read

-- mutes chat for specified number of seconds (default 60)
local function mute(chat_id, mute_for)
  tdcli.setNotificationSettings(chat_id, mute_for or 60, 0)
end

M.mute = mute

-- Tries to push inline button
local function push_button(message, button_id)
end

M.push_button = push_button

-- Find chat by username
local function resolve_username(username)
  tdcli_function ({
    ID = "SearchChats",
    query_ = username,
    limit_ = 5
  }, dl_cb, extra)
end

M.resolve_username = resolve_username

-- Replies to peer with file
local function reply_file(chat_id, msg_id, type, file, caption)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = msg_id,
    disable_notification_ = 0,
    from_background_ = 1,
    reply_markup_ = nil,
    input_message_content_ = getInputMessageContent(file, type, caption),
  }, dl_cb, extra)
end

M.reply_file = reply_file

-- Forwards message to peer. Forward to secret chats is forbidden
local function reply_fwd(msg_id, fwd_id)
end

M.reply_fwd = reply_fwd

-- Sends geo location
local function reply_location(chat_id, msg_id, latitude, longitude)
  tdcli_function ({
    ID="SendMessage",
    chat_id_=chat_id,
    reply_to_message_id_=msg_id,
    disable_notification_=0,
    from_background_=1,
    reply_markup_=nil,
    input_message_content_={
      ID="InputMessageLocation",
      location_={
        ID = "Location",
        latitude_ = latitude,
        longitude_ = longitude
      },
    },
  }, dl_cb, extra)
end

M.reply_location = reply_location

-- Sends file to peer
local function send_file(chat_id, type, file, caption)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = 0,
    disable_notification_ = 0,
    from_background_ = 1,
    reply_markup_ = nil,
    input_message_content_ = getInputMessageContent(file, type, caption),
  }, dl_cb, extra)
end

M.send_file = send_file

-- Sends geo location
local function send_location(chat_id, latitude, longitude)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = 0,
    disable_notification_ = 0,
    from_background_ = 1,
    reply_markup_ = nil,
    input_message_content_ = {
      ID = "InputMessageLocation",
      location_ = {
        ID = "Location",
        latitude_ = latitude,
        longitude_ = longitude
      },
    },
  }, dl_cb, extra)
end

M.send_location = send_location

-- Adds bot to chat
local function start_bot(user_id, chat_id, data)
  tdcli.sendBotStartMessage(user_id, chat_id, 'start')
end

M.start_bot = start_bot

-- sets timer (in seconds)
local function timer(timeout)
  tdcli.setAlarm(timeout)
end

M.timer = timer

-- unmutes chat
local function unmute(chat_id)
  tdcli.setNotificationSettings(chat_id, 0, 1)
end

M.unmute = unmute


return M
