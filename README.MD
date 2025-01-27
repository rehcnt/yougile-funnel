Это контейнер, который позволяет развернуть [коробку Yougile](https://ru.yougile.com/self-hosted) на Linux-хосте с доступом в интернет 
при помощи [Tailsclale funnel](https://tailscale.com/kb/1223/funnel) при минимальной настройке. Конфигурация позволяет получить доступ с готовыми доменом и 
TLS-сертификатом через серый ip-адрес. 

Для начала вам надо зайти на [Tailscale](https://tailscale.com/) и зарегистрировать аккаунт:
![](https://github.com/rehcnt/yougile-funnel/blob/main/screenshots/image-1.png?raw=true)

Выбираем план для персонального использования:
![](https://github.com/rehcnt/yougile-funnel/blob/main/screenshots/image-2.png?raw=true)

Пропускаем шаг настройки внизу страницы, в нем нет необходимости:
![](https://github.com/rehcnt/yougile-funnel/blob/main/screenshots/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202025-01-27%2002-20-26%20(%D0%9A%D0%BE%D0%BF%D0%B8%D1%8F).png?raw=true)

В Access controls нужно вставить этот шаблон (он лишь добавляет tag для более простого управления):
![](https://github.com/rehcnt/yougile-funnel/blob/main/screenshots/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202025-01-27%2002-21-14.png?raw=true)

```json
// Example/default ACLs for unrestricted connections.
{
	// Declare static groups of users. Use autogroups for all users or users with a specific role.
	// "groups": {
	//  	"group:example": ["alice@example.com", "bob@example.com"],
	// },

	// Define the tags which can be applied to devices and by which users.
	"tagOwners": {
		"tag:ssh":      ["autogroup:admin"],
		"tag:internet": ["autogroup:admin"],
	},

	// Define access control lists for users, groups, autogroups, tags,
	// Tailscale IP addresses, and subnet ranges.
	"acls": [
		// Allow all connections.
		// Comment this section out if you want to define specific restrictions.
		{"action": "accept", "src": ["*"], "dst": ["*:*"]},
	],

	// Define users and devices that can use Tailscale SSH.
	"ssh": [
		// Allow all users to SSH into their own devices in check mode.
		// Comment this section out if you want to define specific restrictions.
		{
			"action": "accept",
			"src":    ["autogroup:admin"],
			"dst":    ["autogroup:self"],
			"users":  ["root", "autogroup:nonroot"],
		},
	],
	"nodeAttrs": [
		{
			// Funnel policy, which lets tailnet members control Funnel
			// for their own devices.
			// Learn more at https://tailscale.com/kb/1223/tailscale-funnel/
			"target": ["autogroup:member", "tag:internet"],
			"attr":   ["funnel"],
		},
	],

	// Test access rules every time they're saved.
	// "tests": [
	//  	{
	//  		"src": "alice@example.com",
	//  		"accept": ["tag:example"],
	//  		"deny": ["100.101.102.103:443"],
	//  	},
	// ],
}

```

### Внутри раздела DNS нужно

Добавить любой nameserver (без этого не будет работать DNS):
![](https://github.com/rehcnt/yougile-funnel/blob/main/screenshots/2025-01-27_01-44.jpg?raw=true)

Включить HTTPS для выдачи сертификата:
![](https://github.com/rehcnt/yougile-funnel/blob/main/screenshots/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202025-01-27%2003-12-13.png?raw=true)

Включить более благозвучное название для нашего поддомена:
![](https://github.com/rehcnt/yougile-funnel/blob/main/screenshots/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202025-01-27%2002-37-57.png?raw=true)

На этом базовая настройка Tailscale закончена и нам остался лишь OAuth ключ:
![](https://github.com/rehcnt/yougile-funnel/blob/main/screenshots/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202025-01-27%2003-56-06.png?raw=true)

Внутри осталось нажать Generate Oauth client → выбрать Auth Keys, поставить галочку на Write → добавить tag:internet и нажать на Generate client, после чего сохранить ключ:
![](https://github.com/rehcnt/yougile-funnel/blob/main/screenshots/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202025-01-27%2002-25-32.png?raw=true)

Теперь на Linux-хосте нужно выбрать папку и сделать в нее git clone:

```bash
git clone https://github.com/rehcnt/yougile-funnel
```

Зайти в папку и открыть файл .env. В нем надо только вставить ключ из Tailscale:
![](https://github.com/rehcnt/yougile-funnel/blob/main/screenshots/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202025-01-27%2002-31-13.png?raw=true)

После сохранения остается лишь выполнить внутри папки 
```bash
sudo docker-compose up -d
```

После сборки и запуска контейнера в панели Tailscale появится новое устройство с меткой Funnel и тэгом internet, по полному адресу которого можно перейти. Первая настройка сертификата может занять несколько минут, однако после этого сложностей быть не должно:
![](https://github.com/rehcnt/yougile-funnel/blob/main/screenshots/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202025-01-27%2003-18-15.png?raw=true)

В папке yougile-data будут находиться все необходимые файлы: база данных (database), база вложений (user-data) и файлы machine.key, license.key и conf.json.
В conf.json и остается внести последнее изменение — ваш новый домен в mainPaigeUrl (без / в конце!), так превью картинок будут отображаться корректно:
![](https://github.com/rehcnt/yougile-funnel/blob/main/screenshots/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%20%D0%BE%D1%82%202025-01-27%2002-58-35.png)

> [!NOTE]
> License.key остается пустым, пока его не заполнить. Тогда ключ передается в контейнер, а до этого момента может быть активна та тестовая лицензия, что вы активируете. 
>
>Machine.key же, напротив, заполняется на хосте из контейнера, обратно никак не передается. 
>
>Conf.json синхронизирован с контейнером в реальном времени. 

> [!TIP]
> Для перезапуска Yougile используется команда (если в sudo docker ps не определено другое имя):
>
>```bash
>sudo docker restart yougile-app
>```
>
> Для обновления на последнюю версию нужно сделать:
>```bash
>sudo docker-compose up --build --force-recreate
>```