# Задание:
Разработка идемпотентного API для управления арендой автомобилей.

# Цель задания:
Разработать идемпотентные RESTful API-методы на Ruby on Rails, которые позволят начинать и завершать аренду автомобиля.

Аренда должна инициироваться и заканчиваться безопасно, даже если в процессе возникают повторные запросы (из-за сетевых ошибок, повторных нажатий пользователя и т.д.).

# Требования к заданию

* Проектирование методов API:  API должен содержать два метода: один для начала аренды (start_rental) и другой для её завершения (end_rental).

* Идентификация и обработка идемпотентных запросов: Реализовать механизм, который позволит идентифицировать повторные запросы. Например, использовать токен идемпотентности, передаваемый клиентом. Если система обнаруживает повторный запрос с тем же токеном, она должна возвращать результат предыдущего запроса, не выполняя операцию заново.

* Обеспечение консистентности данных: Разработать решение, которое гарантирует, что даже в случае повторных запросов состояние системы остается консистентным. Например, аренда не может быть начата заново, если она уже активна.

* Логирование и отладка: Включить механизмы логирования для отслеживания идемпотентных запросов и действий, выполняемых API.

# Дополнительные задания:

* Предложить гипотетические способы оптимизации и масштабирования системы для обработки высокой нагрузки, например, при массовом начале и завершении аренд в пиковые периоды.

* Рассмотреть варианты обработки исключительных ситуаций, например, когда состояние автомобиля не позволяет начать или завершить аренду (автомобиль заблокирован, неисправен и т.п.).

# Критерии оценки

* Корректность реализации идемпотентности.

* Эффективность обработки повторных запросов.

* Чистота и читаемость кода.

* Покрытие тестами.

* Учет возможных ошибок и исключительных ситуаций.

* Подходы к обеспечению масштабируемости и устойчивости к высоким нагрузкам.