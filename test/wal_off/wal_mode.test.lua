box.cfg.wal_mode
space = box.schema.space.create('tweedledum')
index = space:create_index('primary', { type = 'hash' })
space:insert{1}
space:insert{2}
space:insert{3}
space.index['primary']:get(1)
space.index['primary']:get(2)
space.index['primary']:get(3)
space.index['primary']:get(4)
box.snapshot()
box.snapshot()
box.error.last().errno
space:truncate()
box.snapshot()
space:drop()
