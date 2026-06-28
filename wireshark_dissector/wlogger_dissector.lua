local dissector_version = "0.3"
local proto_name = "wLogger"
local proto_description = "wLogger Protocol"

local logger_protocol = Proto(proto_name, proto_description)

-- General Proto Fields
local gen_stream_id = ProtoField.new("Stream ID", proto_name .. ".gen.stream_id", ftypes.STRING)
local gen_file_name = ProtoField.new("File Name and Line", proto_name .. ".gen.file_name_n_line", ftypes.STRING)
local gen_func_name = ProtoField.new("Function Name", proto_name .. ".gen.func_name", ftypes.STRING)
local gen_message = ProtoField.new("Message", proto_name .. ".gen.message", ftypes.STRING)

logger_protocol.fields = { gen_stream_id, gen_file_name, gen_func_name, gen_message }

function split (inputstr)
	local t={}
	for str in string.gmatch(inputstr, "([^||]+)") do
		table.insert(t, str)
	end
	return t
end

function logger_protocol.dissector(buffer, pinfo, tree)
  length = buffer:len()
  if length == 0 then return end

  local subtree = tree:add(logger_protocol, buffer(), "wLogger")
  local stringbuf = buffer(0, length):string(ENC_UTF_8)

  parts = split(stringbuf)
  if #parts >= 1 then subtree:add(gen_stream_id, parts[1]) end
  if #parts >= 2 then subtree:add(gen_file_name, parts[2]) end
  if #parts >= 3 then subtree:add(gen_func_name, parts[3]) end
  if #parts >= 4 then subtree:add(gen_message, parts[4]) end
  
  pinfo.cols.protocol = parts[1]
  pinfo.cols.info = parts[4]

end

local raw_ip = DissectorTable.get("wtap_encap")
raw_ip:add(7, logger_protocol)