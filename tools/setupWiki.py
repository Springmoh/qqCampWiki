"""Demo data for the wiki's screenshots, through the console's own API on the
throwaway server (port 19443): four stations on the CLG map with the quiz on,
a game master running two of them, campers at stations, and teams placed in
every stage of the danger sequence (countdown, restricted, waiting, in hall),
with the hall full so the queue has someone waiting.

Usage: setupWiki.py <systemHealth.json>

@author Springmoh
"""
import http.cookiejar
import json
import sys
import urllib.request

ADMIN = 'http://127.0.0.1:19443'
STATIONS = [('神秘宝箱', 3, (300, 330)), ('智力大挑战', 4, (640, 420)),
            ('团队接力', 4, (420, 700)), ('音乐猜猜猜', 3, (700, 860))]
EXTRA = ['小狮子', '火箭队', '彩虹组', '闪电侠', '海豚队', '星星组', '飞鹰队', '熊猫组', '旋风队', '橙子组']
EXTRA_PASSWORD = 'camp1234'
GM = ('gm-ali', 'gm123456')


def main():
    """Sign in as the console and lay the demo out. @author Springmoh"""
    admin = json.load(open(sys.argv[1]))['admin']
    opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
    state = {'csrf': ''}

    def call(path, body=None):
        """POST (with body) or GET one console route. @author Springmoh"""
        request = urllib.request.Request(ADMIN + path, data=None if body is None else json.dumps(body).encode(),
                                         headers={'Content-Type': 'application/json', 'X-CSRF-Token': state['csrf']})
        answer = json.loads(opener.open(request).read())
        state['csrf'] = answer.get('csrf') or state['csrf']
        return answer

    call('/api/admin/login', {'username': admin['admin_user'], 'password': admin['admin_password']})
    ids = []
    for name, capacity, (x, y) in STATIONS:
        station = call('/api/admin/checkpoints/create', {'name': name, 'capacity': capacity})['checkpoint']
        call('/api/admin/checkpoints/position', {'checkpointId': station['id'], 'mapId': 'convention-lg', 'x': x, 'y': y})
        call('/api/admin/checkpoints/quiz', {'checkpointId': station['id'], 'enabled': True})
        call('/api/admin/checkpoints/page', {'checkpointId': station['id'], 'enabled': True})
        ids.append(station['id'])
    for name in EXTRA:
        call('/api/admin/players/create', {'username': name, 'password': EXTRA_PASSWORD, 'startingBalance': '100'})
    call('/api/admin/gamemasters/create', {'username': GM[0], 'password': GM[1], 'checkpointIds': ids[:2]})
    teams = {row['username']: row['id'] for row in call('/api/admin/players')['roster']}
    # at stations: jiaxin and aeron at the game master's 智力大挑战, sarah at 团队接力
    call('/api/admin/checkpoints/occupy', {'checkpointId': ids[1], 'playerId': teams['jiaxin']})
    call('/api/admin/checkpoints/occupy', {'checkpointId': ids[1], 'playerId': teams['aeron']})
    call('/api/admin/checkpoints/occupy', {'checkpointId': ids[2], 'playerId': teams['sarah']})
    # the danger sequence: a countdown, a restriction, a full hall and one waiting
    call('/api/admin/sequence/move', {'playerId': teams['nicholas'], 'stage': 'notified'})
    call('/api/admin/sequence/move', {'playerId': teams['weiming'], 'stage': 'restricted'})
    for name in EXTRA[:8]:
        call('/api/admin/sequence/move', {'playerId': teams[name], 'stage': 'inhall'})
    call('/api/admin/sequence/move', {'playerId': teams[EXTRA[8]], 'stage': 'rejected'})
    call('/api/admin/notifications/send', {'playerIds': [teams['aeron']], 'kind': 'welcome', 'message': ''})


if __name__ == '__main__':
    main()
