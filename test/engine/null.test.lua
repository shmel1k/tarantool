env = require('test_run')
test_run = env.new()
engine = test_run:get_cfg('engine')
NULL = require('msgpack').NULL

--
-- gh-1557: NULL in indexes.
--

format = {}
format[1] = { name = 'field1', type = 'unsigned' }
format[2] = { name = 'field2', type = 'unsigned', is_nullable = true }
s = box.schema.space.create('test', { engine = engine, format = format })

-- Bad nullable value.
format[2].is_nullable = 100
s:format(format) -- Fail.

-- Primary can not be nullable.
parts = {}
parts[1] = {field = 2, type = 'unsigned', is_nullable = true}
pk = s:create_index('pk', { parts = parts }) -- Fail.

pk = s:create_index('pk')

-- Not TREE nullable.
-- Do not print errmsg, because Vinyl's one is different - it does
-- not support HASH.
ok = pcall(s.create_index, s, 'sk', { parts = parts, type = 'hash' }) -- Fail.
ok

-- Conflict of is_nullable in format and in parts.
parts[1].is_nullable = nil
sk = s:create_index('sk', { parts = parts }) -- Fail.

-- Try skip nullable in format and specify in part.
parts[1].is_nullable = true
sk = s:create_index('sk', { parts = parts }) -- Ok.
format[2].is_nullable = nil
s:format(format) -- Fail.
sk:drop()

-- Try to set nullable in part with no format.
s:format({})
sk = s:create_index('sk', { parts = parts })
-- And then set format with no nullable.
s:format(format) -- Fail.
format[2].is_nullable = true
s:format(format) -- Ok.

s:drop()
