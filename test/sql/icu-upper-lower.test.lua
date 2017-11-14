test_run = require('test_run').new()

-- Some test cases
box.sql.execute("select lower('ЯяяяЙЮывфыв ыфвsda sa dasd 213  dw', NULL)")
box.sql.execute("select lower('ЯяяяЙЮывфыв  STRASSE sa dasd 213  dw', 'de_DE')")
box.sql.execute("select upper('ЫВывывы ывф', NULL)")
box.sql.execute("select upper('iiiii i ЫВывывы ывф Straße', 'de_DE')")
box.sql.execute("select upper('iiii i ЫВывывы ывф Straße', 'tr_TR')")
box.sql.execute("select upper('iiii i ЫВывывы ывф Straße', 'tr_TasdasdR')")
box.sql.execute("select upper(1, 'tr_TasdasdR')")
box.sql.execute("select upper('iiii i ЫВывывы ывф Straße')")