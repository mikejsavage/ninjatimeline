#! /usr/bin/lua

local log = io.open( ".ninja_log", "r" ):read( "*all" )

local edges = { }

for line in log:gmatch( "([^\n]+)" ) do
	local start, finish, target = line:match( "^(%d+)%s+(%d+)%s+%d+%s+(%S+)" )
	if start then
		table.insert( edges, {
			start = tonumber( start ),
			dt = tonumber( finish ) - tonumber( start ),
			target = target:match( "[^/]+$" ),
		} )
	end
end

table.sort( edges, function( a, b )
	return a.start < b.start
end )

local function term_width()
	local p = io.popen( "tput cols", "r" )
	if not p then
		return
	end

	local c = p:read( "*all" )
	p:close()

	return tonumber( c )
end

local notches = term_width()
if notches then
	notches = notches - 33
else
	notches = 200
end

local total_duration = edges[ #edges ].start + edges[ #edges ].dt
local c = 0
for _, e in ipairs( edges ) do
	local pre = math.floor( notches * e.start / total_duration )
	local width = math.max( 0, math.floor( notches * e.dt / total_duration - 2 ) )

	local color = ( "\027[0;%dm" ):format( c + 31 )
	c = ( c + 1 ) % 7

	print( ( "%s%25s: %s[%s] %.2fs" ):format( color, e.target, string.rep( " ", pre ), string.rep( ">", width ), e.dt / 1000 ) )
end
