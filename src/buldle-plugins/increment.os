
#Использовать logos
#Использовать gitrunner

Перем ВерсияПлагина;
Перем Лог;
Перем КомандыПлагина;

Перем Обработчик;

Перем ИмяФайлаДампаКонфигурации;
Перем ПутьКФайлуВерсийМетаданных;
Перем ОчиститьКаталогРабочейКопии;
Перем ВыгрузкаИзмененийВозможна;

Функция Информация() Экспорт

	Возврат Новый Структура("Версия, Лог", ВерсияПлагина, Лог)

КонецФункции // Информация() Экспорт

Процедура ПриАктивизацииПлагина(СтандартныйОбработчик) Экспорт

	Обработчик = СтандартныйОбработчик;

КонецПроцедуры

Процедура ПриРегистрацииКомандыПриложения(ИмяКоманды, КлассРеализации, Парсер) Экспорт

	Лог.Отладка("Ищю команду <%1> в списке поддерживаемых", ИмяКоманды);
	Если КомандыПлагина.Найти(ИмяКоманды) = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Лог.Отладка("Устанавливаю дополнительные параметры для команды %1", ИмяКоманды);

КонецПроцедуры

Процедура ПередВыгрузкойКонфигурациюВИсходники(Конфигуратор, КаталогРабочейКопии, КаталогВыгрузки, ПутьКХранилищу, НомерВерсии, Формат) Экспорт

	Лог.Информация("Проверяб возможность инкрементальной выгрузки конфигурации");

	ТекущийФайлВерсийМетаданных = Новый Файл(ОбъединитьПути(КаталогРабочейКопии, ИмяФайлаДампаКонфигурации));

	ПутьКФайлуВерсийМетаданных = ТекущийФайлВерсийМетаданных.ПолноеИмя;

	Лог.Отладка("Проверяю существование файла <%1> в каталоге <%2>, файл <%3>", ИмяФайлаДампаКонфигурации, КаталогРабочейКопии, ?(ТекущийФайлВерсийМетаданных.Существует(), "существует", "отсутствует"));

	Лог.Отладка("Проверяю возможность обновление выгрузки для файла <%1>", ПутьКФайлуВерсийМетаданных);

	ВыгрузкаИзмененийВозможна = ТекущийФайлВерсийМетаданных.Существует()
		И ПроверитьВозможностьОбновленияФайловВыгрузки(Конфигуратор, КаталогВыгрузки, ПутьКФайлуВерсийМетаданных, Формат);

	Лог.Информация("Инкрементальная выгрузка конфигурации - %1", ?(ВыгрузкаИзмененийВозможна, "ВОЗМОЖНА","НЕВОЗМОЖНА"));

КонецПроцедуры

Процедура ПриВыгрузкеКонфигурациюВИсходники(Конфигуратор, КаталогВыгрузки, Формат, СтандартнаяОбработка) Экспорт

	Если ВыгрузкаИзмененийВозможна Тогда

		СтандартнаяОбработка = ложь;

		Параметры = Конфигуратор.ПолучитьПараметрыЗапуска();
		Параметры.Добавить(СтрШаблон("/DumpConfigToFiles %1", ОбернутьВКавычки(КаталогВыгрузки)));
		Параметры.Добавить(СтрШаблон("-format %1", Формат));

		Параметры.Добавить("-update");

		Параметры.Добавить(СтрШаблон("-configDumpInfoForChanges %1", ОбернутьВКавычки(ПутьКФайлуВерсийМетаданных)));

		Конфигуратор.ВыполнитьКоманду(Параметры);

	КонецЕсли;

КонецПроцедуры

Процедура ПриОчисткеКаталогаРабочейКопии(КаталогРабочейКопии, СоответствиеИменФайловДляПропуска, СтандартнаяОбработка) Экспорт

	Если ВыгрузкаИзмененийВозможна Тогда
		СтандартнаяОбработка = Ложь;
	КонецЕсли;

КонецПроцедуры


// Функция проверяет возможность обновления файлов выгрузки, для каталога или конкретного файла версий
//
Функция ПроверитьВозможностьОбновленияФайловВыгрузки(Конфигуратор, Знач КаталогВыгрузки, Знач ПутьКФайлуВерсийДляСравнения = "", Знач ФорматВыгрузки = "")

	ПутьКФайлуИзменений = ВременныеФайлы.НовоеИмяФайла();
	ОбновлениеВозможно = Ложь;

	ТекущийФайлВерсийМетаданных = Новый Файл(ОбъединитьПути(КаталогВыгрузки,"ConfigDumpInfo.xml"));
	ФайлВерсийДляСравнения = Новый Файл(ПутьКФайлуВерсийДляСравнения);

	Если НЕ ТекущийФайлВерсийМетаданных.Существует() И ПустаяСтрока(ПутьКФайлуВерсийДляСравнения) Тогда
	 	Возврат ОбновлениеВозможно;
	КонецЕсли;

	Параметры = Конфигуратор.ПолучитьПараметрыЗапуска();
	Параметры.Добавить(СтрШаблон("/DumpConfigToFiles %1", ОбернутьВКавычки(КаталогВыгрузки)));
	Параметры.Добавить(СтрШаблон("-getChanges %1", ОбернутьВКавычки(ПутьКФайлуИзменений)));

	Если ЗначениеЗаполнено(ПутьКФайлуВерсийДляСравнения) Тогда

		Параметры.Добавить(СтрШаблон("-configDumpInfoForChanges %1", ОбернутьВКавычки(ПутьКФайлуВерсийДляСравнения)));

	КонецЕсли;

	Конфигуратор.ВыполнитьКоманду(Параметры);

	ФайлИзменений = Новый Файл(ПутьКФайлуИзменений);

	Если ФайлИзменений.Существует() Тогда
		СтрокаПолныйДамп = ВРег("FullDump");
		чтениеФайла = Новый ЧтениеТекста(ПутьКФайлуИзменений);
		СтрокаВыгрузки = ВРег(чтениеФайла.ПрочитатьСтроку());

		Если Не ПустаяСтрока(СокрЛП(СтрокаВыгрузки)) Тогда

			Лог.Отладка("Строка проверки на возможность выгрузки конфигурации: <%1> = <%2> ", СтрокаПолныйДамп, СтрокаВыгрузки);
			ОбновлениеВозможно = НЕ (СтрокаВыгрузки = СтрокаПолныйДамп);

		КонецЕсли;
		чтениеФайла.Закрыть();

	КонецЕсли;

	Возврат ОбновлениеВозможно;

КонецФункции

Функция ОбернутьВКавычки(Знач Строка)
	Возврат """" + Строка + """";
КонецФункции

Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт

	Возврат СтрШаблон("%2 - %3 [PLUGIN %1]", ИмяПлагина(), УровниЛога.НаименованиеУровня(Уровень), Сообщение);

КонецФункции

Функция ИмяПлагина()
	возврат "increment";
КонецФункции // ИмяПлагина()

Процедура Инициализация()

	ВерсияПлагина = "1.0.0";
	Лог = Логирование.ПолучитьЛог("oscript.app.gitsync.plugins."+ ИмяПлагина());
	КомандыПлагина = Новый Массив;
	КомандыПлагина.Добавить("sync");
	КомандыПлагина.Добавить("export");
	ПутьКФайлуВерсийМетаданных = "";
	ИмяФайлаДампаКонфигурации = "ConfigDumpInfo.xml";
	ВыгрузкаИзмененийВозможна = Ложь;
	Лог.УстановитьРаскладку(ЭтотОбъект);

КонецПроцедуры

Инициализация();
