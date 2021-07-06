import json
import os
import threading
from requests.exceptions import ProxyError

CAN_NOTIFY = True
import datetime
import random
import time

try:
    from notify import send
except Exception as e:
    CAN_NOTIFY = False
import requests

if CAN_NOTIFY:
    print('启用通知成功', flush=True)
else:
    print('启用通知失败，缺少notify.py', flush=True)


class Fhxz:
    headers = {
        'Host': 'sunnytown.hyskgame.com',
        'accept': '*/*',
        'content-type': 'application/octet-stream',
        'x-unity-version': '2019.2.9f1',
        'user-agent': 'fuhaoxiaozhen/23 CFNetwork/1237 Darwin/20.4.0',
        'accept-language': 'zh-cn',
    }

    def __init__(self, token):
        self.env_token = token
        self.token = token
        token = self.get_token()
        self.token = token if token else self.token
        self.frame_list = []
        self.lottery_times = 10
        self.gold = 0
        self.daily_tasks = []
        self.user_info = {}
        self.have_tixian_times = 2
        self.have_steal = False
        self.have_check_in = False
        self.t = None
        self.t2 = None
        self.t3 = None
        self.t4 = None
        self.speed_times = 15
        self.lottery_reword_map = {}
        self.success_time = 0
        self._exit = False
        self._finish = False

    def request(self, method="get", **kw):
        try:
            if method == 'get':
                return requests.get(**kw)
            else:
                return requests.post(**kw)
        except Exception as e:
            print("网络异常", e, flush=True)

    def init(self):
        self.get_token()

        self.enter_game()
        self.gcfun()
        self.pet_house()
        self.invitation()
        self.daily()
        self.user_ads_info()
        self._exit = False

        if not self.t:
            t = threading.Thread(target=self.sub_thread)
            t.start()
            self.t = t
        if not self.t2:
            t2 = threading.Thread(target=self.sub_thread2)
            t2.start()
            self.t2 = t2
        if not self.t3:
            t3 = threading.Thread(target=self.sub_thread3)
            t3.start()
            self.t3 = t3
        if not self.t4:
            t4 = threading.Thread(target=self.sub_thread4)
            t4.start()
            self.t4 = t4

    def exit(self):
        self._exit = True

    def random_wait(self, a, b):
        r = random.randint(a, b)
        if r > 30:
            self._exit = True
        time.sleep(r)
        if r > 30:
            self._exit = False
        return r

    def look_adv(self, t=30):
        self.random_wait(t - 10, t + 10)

    def get_token(self):
        if os.path.exists('.富豪小镇.token'):
            fp = open('.富豪小镇.token', 'r')
            tokens = json.loads(fp)
            return tokens.get(self.env_token, self.env_token)

    def save_token(self, data):
        if os.path.exists('.富豪小镇.token'):
            fp = open('.富豪小镇.token', 'r')
            tokens = json.load(fp)
            tokens[self.token] = data
        else:
            tokens = {self.env_token: data}

        fp = open('.富豪小镇.token', 'w')
        json.dump(tokens, fp)

    @staticmethod
    def get_data(res, type=None):
        try:
            if res.status_code == 200:
                if not type:
                    data = res.json()[0]
                    return data['data']
                else:
                    for item in res.json():
                        if item['type'] == type:
                            return item

        except Exception as e:
            print(res.text, e)

    def get_token(self):
        params = (
            ('accessToken', ''),
            ('msgtype', 'account_signInAccessToken'),
        )
        data = '[{"type":"account_signInAccessToken","data":{"accessToken":"' + self.token + '"}}]'
        response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                 data=data)
        data = self.get_data(response)
        token = data['accessToken']
        self.token = token
        self.save_token(token)

    def sub_thread(self):
        while not self._finish:
            if not self._exit:
                self.gpv()
                time.sleep(60)

    def sub_thread2(self):
        time.sleep(30)
        while not self._finish:
            if not self._exit:
                self.heartbeat()
                time.sleep(60)

    def sub_thread3(self):
        time.sleep(30)
        while not self._finish:
            if not self._exit:
                self.keep_alive()
                time.sleep(60)

    def sub_thread4(self):
        time.sleep(30)
        while not self._finish:
            if not self._exit:
                self.user_ads_info()
                time.sleep(300)

    def keep_alive(self):

        params = (
            ('accessToken', self.token),
            ('msgtype', 'system_keep_alive'),
        )

        data = '[{"type":"system_keep_alive","data":{"clientTimeMillis":"' + str(
            int(time.time())) + '","pingTimeMillis":"100"}}]'

        response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                 data=data)
        # print('keep_alive:', flush=True)

    def heartbeat(self):

        params = (
            ('accessToken', self.token),
            ('msgtype', 'stealingVege_checkHeartBeat'),
        )

        data = '[{"type":"stealingVege_checkHeartBeat","data":{}}]'

        response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                 data=data)
        # print('heartbeat:', flush=True)

    def gpv(self):
        params = (
            ('accessToken', self.token),
            ('msgtype', 'system_getGpvGameOptions'),
        )

        data = '[{"type":"system_getGpvGameOptions","data":{"gameId":"sunnytown-cn","runtimePlatform":"ios","versionName":"1.0.9"}}]'
        response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                 data=data)
        # print('gpv:', flush=True)

    def enter_game(self):

        params = (
            ('accessToken', self.token),
            ('msgtype', 'user_enterGame'),
        )

        data = '[{"type":"user_enterGame","data":{}}]'

        response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                 data=data)
        data = response.json()
        for item in data:
            if item['type'] == 'farmland_getFarmlandList':
                frame_list = item['data']['farmlandList']
                self.frame_list = frame_list

            if item['type'] == 'user_getUserInfo':
                user_info = item['data']['userInfo']
                self.user_info = user_info
                self.gold = self.user_info['coin']
        # print('enter_game: ', data)

    def gcfun(self):

        params = (
            ('accessToken', self.token),
            ('msgtype', 'gfunc_getGfuncInfo'),
        )

        data = '[{"type":"gfunc_getGfuncInfo","data":{}}]'

        response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                 data=data)
        # print('gcfun: ', response.text)

    def invitation(self):

        params = (
            ('accessToken', self.token),
            ('msgtype', 'invitation_getInvitationBag'),
        )

        data = '[{"type":"invitation_getInvitationBag","data":{}}]'

        response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                 data=data)
        data = self.get_data(response)
        # print('invitation', data)

    # def pet_house(self):
    #
    #     params = (
    #         ('accessToken', self.token),
    #         ('msgtype', 'pet_getPetHouse'),
    #     )
    #
    #     data = '[{"type":"pet_getPetHouse","data":{}}]'
    #
    #     response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
    #                              data=data)
    #     data = self.get_data(response)
    #     # print('pet_house', data)

    def daily(self):

        params = (
            ('accessToken', self.token),
            ('msgtype', 'dailyQuest_getQuestList'),
        )

        data = '[{"type":"dailyQuest_getQuestList","data":{"questType":1}}]'

        response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                 data=data)
        for item in response.json():
            if item.get('type') == 'dailyQuest_getQuestList':
                data = item['data']
                self.daily_tasks = data['questList']

    def user_ads_info(self):

        params = (
            ('accessToken', self.token),
            ('msgtype', 'userAdsInfo_getAdsInfo'),
        )

        data = '[{"type":"userAdsInfo_getAdsInfo","data":{}}]'

        response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                 data=data)
        data = self.get_data(response)
        # print('user_ads_info', data)
        time.sleep(5)

    def repair(self, frame_id):
        rate = random.randint(1, 100)
        if rate > 80:
            print(f'开始修理地块{frame_id}', flush=True)
            self.look_adv(50)

            params = (
                ('accessToken', self.token),
                ('msgtype', 'farmland_repair'),
            )

            data = '[{"type":"farmland_repair","data":{"farmlandDefId":' + str(frame_id) + '}}]'

            response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                     data=data)
            for item in response.json():
                if item.get('type') == 'farmland_repair':
                    data = item['data']

            print(f'地块{frame_id}修理成功', flush=True)

    def collect(self, frame_id):

        params = (
            ('accessToken', self.token),
            ('msgtype', 'farmland_harvest'),
        )

        data = '[{"type":"farmland_harvest","data":{"farmlandDefId":' + str(frame_id) + '}}]'

        response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                 data=data)
        for item in response.json():
            if item.get('type') == 'farmland_harvest':
                data = item['data']

        print(f'地块{frame_id}收获成功', flush=True)

    def plant(self, frame_id):

        params = (
            ('accessToken', self.token),
            ('msgtype', 'farmland_plant'),
        )

        data = '[{"type":"farmland_plant","data":{"farmlandDefId": ' + str(frame_id) + ',"priceType":2001}}]'

        response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                 data=data)

        for item in response.json():
            if item.get('type') == 'farmland_plant':
                data = item['data']

        print(f'地块{frame_id}种植成功', flush=True)
        self.random_wait(2, 5)

    def get_frame_list(self):

        params = (
            ('accessToken', self.token),
            ('msgtype', 'farmland_getFarmlandList'),
        )

        data = '[{"type":"farmland_getFarmlandList","data":{}}]'

        response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                 data=data)
        data = response.json()
        for item in data:
            if item['type'] == 'farmland_getFarmlandList':
                frame_list = item['data']['farmlandList']
                random.shuffle(frame_list)
                self.frame_list = frame_list

    def check_market(self):

        params = (
            ('accessToken', self.token),
            ('msgtype', 'market_getItemList'),
        )

        data = '[{"type":"market_getItemList","data":{}}]'

        response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                 data=data)
        data = response.json()
        for item in data:
            if item['type'] == 'market_getItemList':
                data = item['data']
                for market_item in data['marketItemList']:
                    item_id = market_item['itemDefId']
                    title = market_item['title']
                    amount = market_item['cashAmount']
                    if market_item['progress'] >= market_item['targetNumber']:
                        print(f'{item_id} {title} 可提现{amount}元', flush=True)
                        if amount < 1:
                            self.tixian(item_id)

    def tixian(self, item_id):
        if not self.have_tixian_times:
            print('今日已提现过', flush=True)
            return
        self.random_wait(1, 3)
        params = (
            ('accessToken', self.token),
            ('msgtype', 'market_exchange'),
        )

        data = '[{"type":"market_exchange","data":{"itemDefId":' + str(item_id) + '}}]'

        response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                 data=data)

        data = response.json()
        for item in data:
            if item['type'] == 'market_exchange':
                data = item['data']['marketItem']
                status = data['stateCode']
                amount = data['cashAmount']
                no_audit = data['noAudit']
                notify_str = f'{amount}元提现成功'
                send(f"富豪小镇\t账号{self.user_info['nickname']}", notify_str)
                self.have_tixian_times = self.have_tixian_times - 1 if self.have_tixian_times > 0 else 0
                self.gcfun()
            elif item['type'] == 'system_error':
                message = item['data']['message']
                notify_str = f'提现失败 {message}'
                send(f"富豪小镇\t账号{self.user_info['nickname']}", notify_str)
                self.have_tixian_times = 0

    def unlock(self, land_id):
        self.random_wait(1, 2)
        params = (
            ('accessToken', self.token),
            ('msgtype', 'farmland_unlock'),
        )

        data = '[{"type":"farmland_unlock","data":{"farmlandDefId":' + str(land_id) + '}}]'

        response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                 data=data)

    def handle_frame(self):
        for item in self.frame_list:
            status_code = item.get('stateCode')
            frame_id = item.get('farmlandDefId')
            if status_code == 1:
                # todo 建造
                price = item['unlockPriceCoin']
                if int(price) <= self.gold:
                    self.unlock(frame_id)
                    print(f'解锁地块{frame_id}')
                else:
                    print(f'解锁地块{frame_id}金币不足，{self.gold}/{price}')

        for item in self.frame_list:
            status_code = item.get('stateCode')
            frame_id = item.get('farmlandDefId')
            if status_code == 2:
                self.plant(frame_id)
            elif status_code == 5:
                self.repair(frame_id)
            elif status_code == 6:
                self.collect(frame_id)
                self.plant(frame_id)

    def finish_daily_task(self):
        for task in self.daily_tasks:
            if task['stateCode'] == 2:
                self.random_wait(1, 3)
                params = (
                    ('accessToken', self.token),
                    ('msgtype', 'dailyQuest_receiveReward'),
                )

                task_id = task['questDefId']
                data = '[{"type":"dailyQuest_receiveReward","data":{"questDefId":' + str(task_id) + ',"questType":1}}]'

                response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers,
                                         params=params,
                                         data=data)
                data = self.get_data(response, type='dailyQuest_receiveReward')
                print(f"完成任务{data['data']['questInfo']['title']}", flush=True)

    def speed_up_all(self):
        if self.speed_times <= 0:
            print('今日加速次数已用完', flush=True)
            return
        self.look_adv()
        params = (
            ('accessToken', self.token),
            ('msgtype', 'farmland_speedUpAll'),
        )

        data = '[{"type":"farmland_speedUpAll","data":{"farmlandDefId":0}}]'

        response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                 data=data)
        # data = self.get_data(response, 'farmland_speedUpAll')

        info = self.get_data(response, 'farmland_getSpeedUp')
        if info:
            self.speed_times = info.get('data', {}).get('speedUpInfo', {}).get('remainingAllTimes', 0)
            print(f"全体加速剩余次数：{self.speed_times}", flush=True)
        else:
            system_error = self.get_data(response, 'system_error')
            if system_error["data"]["message"] == '今日次数已用完':
                print(f'{system_error["data"]["message"]}')
                self.speed_times = 0
            else:
                print(f'看广告太频繁{system_error["data"]["message"]}')

    def get_lottery_info(self):

        params = (
            ('accessToken', self.token),
            ('msgtype', 'lottery_getLotteryInfo'),
        )

        data = '[{"type":"lottery_getLotteryInfo","data":{}}]'

        response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                 data=data)
        data = self.get_data(response, 'lottery_getLotteryInfo')
        self.lottery_times = data['data']['lotteryInfo']['remainingTimes']
        print(f'抽奖次数剩余：{self.lottery_times}', flush=True)

    def lottery(self):
        if self.lottery_times == 0:
            print('今日抽奖次数已用完', flush=True)
            return
        try_times_max = 5 if self.lottery_times > 5 else self.lottery_times
        times = random.randint(1, try_times_max)
        for _ in range(times):
            print("开始抽奖一次", flush=True)
            self.look_adv()
            params = (
                ('accessToken', self.token),
                ('msgtype', 'lottery_draw'),
            )

            data = '[{"type":"lottery_draw","data":{"priceType":3001}}]'

            response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                     data=data)
            data = self.get_data(response, 'lottery_draw')
            reward_id = data['data']['selectSlot']['rewardPropDefId']
            reward_num = data['data']['selectSlot']['rewardNumber']

            items_info = data['data']['lotteryInfo']['items']
            in_list = False
            for item_info in items_info:
                if item_info['propDefId'] == reward_id:
                    in_list = True
                    print(f"抽中:{reward_id} 数量:{reward_num}\t进度: {item_info['number']}/{item_info['totalProgress']}\t"
                          f"{'可领取' if item_info['stateCode'] == 2 else ''}", flush=True)
            if not in_list:
                print(f"抽中:{reward_id} 数量:{reward_num}\t", flush=True)

    def get_checkin_info(self):

        params = (
            ('accessToken', self.token),
            ('msgtype', 'farmCheckIn_getCheckInInfo'),
        )

        data = '[{"type":"farmCheckIn_getCheckInInfo","data":{}}]'

        response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                 data=data)

        data = self.get_data(response, 'farmCheckIn_getCheckInInfo')
        entries = data['data']['checkInInfo']['entries']
        day_number = data['data']['checkInInfo']['dayNumber']
        for entry in entries:
            cur_day_number = entry['dayNumber']
            if entry['stateCode'] == 2:
                if int(day_number) >= int(cur_day_number):
                    if entry.get('noAudit', 0) == 1:
                        data = '[{"type":"farmCheckIn_receiveReward","data":{"dayNumber":' + str(cur_day_number) + '}}]'

                        response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers,
                                                 params=params,
                                                 data=data)
                        data = self.get_data(response, 'farmCheckIn_getCheckInInfo')
                        entries = data['data']['checkInInfo']['entries']
                        for entry in entries:
                            if entry['dayNumber'] == cur_day_number and entry['stateCode'] == 3:
                                notify_str = f'签到{cur_day_number}天奖励{entry["displayCashAmount"]}，提现成功'
                                print(notify_str, flush=True)
                                send(f"富豪小镇\t账号{self.user_info['nickname']}", notify_str)
                    else:
                        print(f"签到{day_number}天奖励:" + entry.get('exchangeRequireText', ''), flush=True)

    def get_stealing_vege(self):
        for item in self.frame_list:
            if item['stateCode'] in [0, 1]:
                return
        print('开始偷取', flush=True)
        params = (
            ('accessToken', self.token),
            ('msgt ype', 'stealingVege_getStealingVege'),
        )

        data = '[{"type":"stealingVege_getStealingVege","data":{}}]'

        response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                 data=data)

        data = self.get_data(response, 'stealingVege_getStealingVege')
        for item in data['data']['stealingVege']['targetUsers']:
            self.random_wait(1, 3)
            params = (
                ('accessToken', self.token),
                ('msgtype', 'stealingVege_attackTarget'),
            )
            if item['state'] == 0:
                data = '[{"type":"stealingVege_attackTarget","data":{"recordId":' + str(item['id']) + '}}]'

                response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers,
                                         params=params,
                                         data=data)
                raw = response.json()
                data = self.get_data(response, 'stealingVege_attackTarget')
                print(f'偷取{data["data"]["attackTarget"]["nickname"]}一次',
                      flush=True)

    def pet_house(self):
        for item in self.frame_list:
            if item['stateCode'] in [0, 1]:
                return

        print(f'检查守护', end=':')
        self.random_wait(1, 3)
        params = (
            ('accessToken', self.token),
            ('msgtype', 'pet_getPetHouse'),
        )

        data = '[{"type":"pet_getPetHouse","data":{}}]'

        response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                 data=data)
        data = self.get_data(response)
        data = data['petHouse']
        if data['defenseEndTime'] == '0000-00-00 00:00:00':
            params = (
                ('accessToken', self.token),
                ('msgtype', 'pet_buyPet'),
            )

            data = '[{"type":"pet_buyPet","data":{}}]'

            response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers, params=params,
                                     data=data)

        else:
            end_time = datetime.datetime.strptime(data['defenseEndTime'], '%Y-%m-%d %H:%M:%S')
            detail_day = end_time.day - datetime.datetime.now().day
            detail_hour = end_time.hour - datetime.datetime.now().hour
            if detail_hour + detail_day * 24 < 3:
                if data['remainingFeedTimes'] > 0:
                    self.random_wait(30, 50)
                    params = (
                        ('accessToken', self.token),
                        ('msgtype', 'pet_feedPetFood'),
                    )

                    data = '[{"type":"pet_feedPetFood","data":{}}]'

                    response = requests.post('https://sunnytown.hyskgame.com/api/messages', headers=self.headers,
                                             params=params,
                                             data=data)
                    data = self.get_data(response)
                    data = data['petHouse']
                    print(f'守护结束时间：{data["defenseEndTime"]}', flush=True)
                else:
                    print('次数已用完！', flush=True)
            else:
                print('成功！', flush=True)

    def step1(self):
        self.finish_daily_task()

    def step2(self):
        self.handle_frame()
        self.random_wait(1, 10)
        self.get_frame_list()
        self.handle_frame()
        self.random_wait(1, 10)
        if self.have_tixian_times:
            self.check_market()
        self.speed_up_all()
        self.random_wait(1, 10)
        self.get_frame_list()
        self.handle_frame()
        self.random_wait(1, 10)
        if self.have_tixian_times:
            self.check_market()

    def step3(self):
        # todo 抽奖
        if self.lottery_times:
            self.get_lottery_info()
            self.lottery()

    def run(self):
        self.step2()
        self.step3()
        self.step1()
        if not self.have_check_in and self.speed_times == 0:
            self.get_checkin_info()
            # self.have_tixian_times = True
        self.pet_house()
        if not self.have_steal:
            self.get_stealing_vege()
            self.have_steal = True


if __name__ == '__main__':
    target_times = random.randint(15, 30)


    def parse(account):
        params = account.split(';')
        data = {}
        for param in params:
            if '=' in param:
                k, v = param.split('=')
                data[k] = v
        return data


    # 多号 accounts = "token=xxx;&token=xxx" 单号 acount="token=xxx"
    accounts = os.getenv('FHXZ_AUTH')
    if not accounts:
        print('请设置环境变量FHXZ_AUTH', flush=True)

    accounts = [parse(account) for account in accounts.split('&') if account]
    accounts = [Fhxz(**account) for account in accounts]

    print(f'总计{len(accounts)}个账号', flush=True)

    while True:
        all_finish = True
        for fhxz in accounts:
            if fhxz.success_time <= target_times or fhxz.speed_times > 0:
                try:
                    fhxz.init()
                    print('-------------------------------')
                    print(f'当前账号{fhxz.user_info.get("nickname")},执行第{fhxz.success_time + 1}次', flush=True)
                    fhxz.run()
                    fhxz.success_time += 1
                except ProxyError as e:
                    print('网络异常' + str(e), flush=True)
                except Exception as e:
                    print('未知错误' + str(e), flush=True)

                fhxz.exit()
                print('-----------------------------\n\n')
                if not (8 <= datetime.datetime.now().hour < 25):
                    break

                all_finish = False
            else:
                fhxz._finish = True

        if all_finish:
            break

        random_sleep = random.randint(120, 450)
        print(f'休息{random_sleep}秒', flush=True)
        time.sleep(random_sleep)

    print('任务结束', flush=True)
