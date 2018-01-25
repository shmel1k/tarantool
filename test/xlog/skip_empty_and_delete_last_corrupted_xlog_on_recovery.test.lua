#!/usr/bin/env tarantool

env = require('test_run')
test_run = env.new()

box.cfg{}

test_run:cmd('create server test with script = "xlog/force_recovery.lua"')

test_run:cmd("start server test")
test_run:cmd("switch test")
box.space._schema:replace({'test'})
test_run:cmd("switch default")
test_run:cmd("stop server test")

test_run:cmd("start server test")
test_run:cmd("switch test")
box.space._schema:replace({'lost'})
test_run:cmd("switch default")
test_run:cmd("stop server test")

test_run:cmd("start server test")
test_run:cmd("switch test")
box.space._schema:replace({'tost'})
test_run:cmd("switch default")
test_run:cmd("stop server test")

os.execute("rm force_recovery/00000000000000000001.xlog")
os.execute("touch force_recovery/00000000000000000001.xlog")

test_run:cmd("start server test")
test_run:cmd("switch test")
box.space._schema:replace({'last'})
test_run:cmd("switch default")
test_run:cmd("stop server test")

os.execute("rm force_recovery/00000000000000000003.xlog")
os.execute("touch force_recovery/00000000000000000003.xlog")

test_run:cmd("start server test")
test_run:cmd("switch test")
box.space._schema:replace({'list'})
