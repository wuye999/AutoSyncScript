import requests

headers = {
    'Host': 'coral-task.uc.cn',
    'f-refer': 'wv_h5',
    'Accept': '*/*',
    'Device-ID': 'KA4cQnijwVQ9mGpUNZggTeiMihgs7e-JpUGxPYyFI87NO9m91stMQtPXdPUoGamy',
    'Accept-Language': 'en-gb',
    'Origin': 'https://pages.tmall.com',
    'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 AliApp(TB/10.2.10) WindVane/8.7.2 1242x2688 WK',
    'Referer': 'https://pages.tmall.com/wow/z/wt/rax/daily-earn-sheep?disableNav=YES&subSource=ucjy&taskToken=AAOURJQhWuSPPHPgJR9JVpMRMH4hQr7al4aA5D3eGdZugnm2yHnf%2FVPS2C%2FxK62M8aalq%2BgExZpNhLzPPUvBYs8e&slk_gid=bayes_auto_ios_14_ucbrowser_13_scheme_alink&async=false&idfa=00000000-0000-0000-0000-000000000000&surge_ssr=false&afcflow=unkown&bxsign=hai%2FXxbZmA0i36oaXPS5d6W6RTTvGVWltmzo6lVJRbUJAFZXHjaMX6qBOWkP0W9yWZjEVHptLcIesnv6MOTSriyhnbtsd0mlw129lkDpYOGYe0%3D&_afc_link=1&utparamcnt=%7B%22_afc_link%22%3A%221%22%7D',
}

data = {
  'accessCode': 'AAOURJQhWuSPPHPgJR9JVpMRMH4hQr7al4aA5D3eGdZugnm2yHnf/VPS2C/xK62M8aalq gExZpNhLzPPUvBYs8e'
}

response = requests.post('https://coral-task.uc.cn/task/v3/completeByAccessCode', headers=headers, data=data)


import requests

headers = {
    'Host': 'coral-task.uc.cn',
    'Origin': 'https://pages.tmall.com',
    'f-refer': 'wv_h5',
    'Accept': '*/*',
    'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 AliApp(TM/10.10.0) WindVane/8.7.2 T-UA=iPhone_10.10.0_1242x2688_201200 TMIOS/201200@tmall_iphone_10.10.0 UT4Aplus/0.0.6 1242x2688 WK',
    'Referer': 'https://pages.tmall.com/wow/an/tmall/user-growth/play4?disableNav=YES&taskToken=AAMegCQ1%2B6WR3LUaiJug0XInYcwocPuZOzaKMvSQhTYV8ljsnEdUhAIj5Wrk2X3fFfEGyEpnI0LtUQj4FjX7zAr2&afcflow=com.ucweb.iphone.lowversion&bxsign=haieW2B7I9JoZRtcCsfmzxOk2ZyYmsUHSNtrWnjLZoVr4eoJe%2F09EPiFJyl1sl6qIeyRykmk7yvYhVajtUVhWUbgo2Kqg4DG9GX8IcklrcjQCo%3D&ttid=201200%40tmall_iphone_10.10.0&deviceId=651AA52B-56A1-46AE-9422-6EF8A2DB11A1',
    'Accept-Language': 'en-gb',
}

data = {
  'accessCode': 'AAMegCQ1+6WR3LUaiJug0XInYcwocPuZOzaKMvSQhTYV8ljsnEdUhAIj5Wrk2X3fFfEGyEpnI0LtUQj4FjX7zAr2'
}

response = requests.post('https://coral-task.uc.cn/task/v3/completeByAccessCode', headers=headers, data=data)
