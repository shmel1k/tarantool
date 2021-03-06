test_run = require('test_run').new()

-- Upon start the test server creates a space and populates it with
-- more tuples than can be stored in memory, which results in dumping
-- some of them to disk. If on restart, during recovery from WAL,
-- it replayed the dumped statements, it would exceed memory quota.
-- Check that it does not.

test_run:cmd('create server test with script = "vinyl/low_quota.lua"')
test_run:cmd('start server test with args="2097152"')

test_run:cmd('switch test')
-- Create a vinyl space and trigger dump by exceeding memory quota.
s = box.schema.space.create('test', {engine = 'vinyl'})
_ = s:create_index('pk', {run_count_per_level = 10})
pad_size = 1000
pad = string.rep('x', pad_size)
for i = 1, 2 * box.cfg.vinyl_memory / pad_size do s:insert{i, pad} end
-- Save the total number of committed and dumped statements.
-- Make sure no task is completed after we saved stats.
box.error.injection.set('ERRINJ_VY_TASK_COMPLETE', true)
var = box.schema.space.create('var')
_ = var:create_index('pk', {parts = {1, 'string'}})
stat = box.space.test.index.pk:info()
_ = var:insert{'put', stat.put.rows}
_ = var:insert{'dump', stat.disk.dump.out.rows}
test_run:cmd('restart server test with args="2097152"')
-- Check that we do not exceed quota.
stat = box.info.vinyl()
stat.quota.used <= stat.quota.limit or {stat.quota.used, stat.quota.limit}
-- Check that we did not replay statements dumped before restart.
stat = box.space.test.index.pk:info()
var = box.space.var
dump_before = var:get('dump')[2]
dump_after = stat.disk.dump.out.rows
put_before = var:get('put')[2]
put_after = stat.put.rows
dump_after == 0 or dump_after
put_before - dump_before == put_after or {dump_before, dump_after, put_before, put_after}
-- Disable dump and use all memory up to the limit.
box.error.injection.set('ERRINJ_VY_RUN_WRITE', true)
box.cfg{vinyl_timeout=0.001}
pad_size = 1000
pad = string.rep('x', pad_size)
for i = 1, box.cfg.vinyl_memory / pad_size do box.space.test:replace{i, pad} end
box.info.vinyl().quota.used > 1024 * 1024
-- Check that tarantool can recover with a smaller memory limit.
test_run:cmd('restart server test with args="1048576"')
fiber = require 'fiber'
-- All memory above the limit must be dumped after recovery.
while box.space.test.index.pk:info().disk.dump.count == 0 do fiber.sleep(0.001) end
stat = box.info.vinyl()
stat.quota.used <= stat.quota.limit or {stat.quota.used, stat.quota.limit}
_ = test_run:cmd('switch default')

test_run:cmd('stop server test')
test_run:cmd('cleanup server test')
