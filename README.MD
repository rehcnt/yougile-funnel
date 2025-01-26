Это готовый докер, который позволяет развернуть [коробку Yougile](https://ru.yougile.com/self-hosted) на Linux-хосте с доступом в интернет 
при помощи [Tailsclale funnel](https://tailscale.com/kb/1223/funnel) при минимальной настройке. Конфигурация позволяет получить доступ с готовыми доменом и 
TLS-сертификатом через черый ip-адрес. 

1. Для начала вам надо зайти на [Tailscale](https://tailscale.com/) и зарегистрировать аккаунт:
![alt text](image.png)

2. Выбираем план для персонального использования:
![alt text](image-2.png)

3. Пропускаем шаг настройки , в нем нет необходимости:


4. В Access controls нужно вставить этот шаблон (он лишь добавляет tag для более простого управления):

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

5.Внутри раздела DNS нужно:
5.1. Добавить любой nameserver (без этого не будет работать DNS):

5.2. Включить HTTPS для выдачи сертификата:

5.3. Включить более благозвучное название для нашего поддомена:

6. На этом базовая настройка Tailscale закончена и нам осталось лишь OAuth ключ:

Внутри осталось нажать Generate Oauth client → выбрать Auth Keys, поставить галочку на Write → добавить tag:internet и нажать на Generate client, после чего сохранить ключ:

7. Теперь на Linux-хосте нужно выбрать папку и сделать в нее git clone:

```bash
git clone https://github.com/rehcnt/yougile-funnel
```

8. Зайти в папку и открыть файл .env. В нем надо только вставить ключ из Tailscale:

9. После сохранения остается лишь выполнить внутри папки 
```bash
sudo docker-compose up -d
```

10. После сборки и запуска контейнера в панели Tailscale появится новое устройство с меткой Funnel, по полному адресу которого можно перейти. Первая настройка сертификата займет несколько минут, однако после этого сложностей быть не должно:

11. В папке yougile-data будут находиться все необходимые файлы: база данных (database), база вложений (user-data) и файлы machine.key, license.key и conf.json.
В conf.json и остается внести последнее изменение — ваш новый домен в mainPaigeUrl (без / в конце!), так превью картинок буду отображаться корректно:

License.key остается пустым, пока его не заполнить. Тогда ключ передается в контейнер, а до этого момента может быть активна та тестовая лицензия, что вы активируете. 
Machine.key же, напротив, заполняется на хосте из контейнера, обратно никак не передается. 
Conf.json синхронизирован с контейнером в реальном времени. 

Для перезапуска Yougile используется команда (если в sudo docker ps не определено другое имя):

```bash
sudo docker restart yougile-app-1
```

Для обновления на последнюю версию нужно сделать:
```bash
sudo docker-compose build --no-cache && sudo docker compose up -d
```