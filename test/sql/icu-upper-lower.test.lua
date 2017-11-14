test_run = require('test_run').new()

upper_lower_test = function (str) return box.sql.execute(string.format("select lower('%s'), upper('%s')", str, str)) end

-- Some pangrams
upper_lower_test("Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq.") -- Azerbaijanian
upper_lower_test("The quick brown fox jumps over the lazy dog.") -- English
upper_lower_test("Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք") -- Armenian
upper_lower_test("У Іўі худы жвавы чорт у зялёнай камізэльцы пабег пад’есці фаршу з юшкай") -- Belarussian
upper_lower_test("Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός") --  Greek
upper_lower_test("Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig") -- Irish
upper_lower_test("Quiere la boca exhausta vid, kiwi, piña y fugaz jamón") -- Spain
upper_lower_test("키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다") -- Korean
upper_lower_test("Glāžšķūņa rūķīši dzērumā čiepj Baha koncertflīģeļu vākus") -- Latvian
upper_lower_test("Zwölf große Boxkämpfer jagen Viktor quer über den Sylter Deich") -- German
upper_lower_test("Pchnąć w tę łódź jeża lub ośm skrzyń fig.") -- Polish
upper_lower_test("Чуєш їх, доцю, га? Кумедна ж ти, прощайся без ґольфів!") -- Ukrainian
upper_lower_test("Příliš žluťoučký kůň úpěl ďábelské ódy") -- Czech
upper_lower_test("Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj") -- Esperanto
upper_lower_test("いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす") -- Japanese
upper_lower_test("Pijamalı hasta yağız şoföre çabucak güvendi. EXTRA: İ") -- Turkish

-- Bad test cases
box.sql.execute("select upper('1', 2)")
box.sql.execute("select upper(\"1\")")
box.sql.execute("select upper()")

