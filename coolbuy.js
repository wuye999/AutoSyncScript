let cbuys = process.env.coolBuyStr2
// console.log(cbuys)
let result = ""
let lotterycs = 0
const axios = require("axios")
if (cbuys) {
    cbuy = JSON.parse(cbuys)
    headers = {
        "content-type": "application/json;charset=UTF-8",
        "origion": "https://coolbuy.com",
        "host": "coolbuy.com",
        "user-agent": "Mozilla/5.0 (Linux; Android 10; Redmi K30) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.105 Mobile Safari/537.36",
        "referer": "https://coolbuy.com/article/994/?tabbar=hidden&task_finished_modal_show",
        "cookie": cbuy.cookie
    }
    if (cbuy.type == "wx") {
        headers["x-csrftoken"] = null
        headers["x-pepe-merchant-id"] = 1
        headers["x-requested-with"] = "com.tencent.mm"
        headers["authorization"] =cbuy.authorization.replace("Bearer","Bearer ")
    } else {
        headers["x-csrftoken"] = cbuy.cookie.match(/csrftoken=(.+?);/)[1]
        headers["sec-ch-ua-mobile"] = "?1"
    }
    coolbuy()
} else {
    console.log("你啥都没填,跑个鬼")
}


function interact(id) {
    return new Promise(async (resolve) => {
        try {
            let url = "https://coolbuy.com/api/v1.4/page/point/"
            let data = {
                "page_id": id
            }
            let res = await axios.post(url, data, {
                headers
            })
            console.log(res.data)
            if (res.data.status == "valid") {
                console.log("阅读奖励领取成功")
            } else {
                console.log(res.data)
            }

        } catch (err) {
            console.log(err.response.data);

        }
        resolve();
    });
}

function sign() {
    return new Promise(async (resolve) => {
        try {
            let url = "https://coolbuy.com/api/v1.4/member/checkin/"
            let res = await axios.post(url, {}, {
                headers
            })
            if (res.data.checked_in_today) {
                console.log("签到成功")
            }
        } catch (err) {
            console.log(err.response.statusText);

        }
        resolve();
    });
}

function lottery() {
    return new Promise(async (resolve) => {
        try {
            let url = "https://coolbuy.com/api/v1.4/member-lottery/"

            let data = {
                "lottery_id": 3
            }
            //  await axios.get(`https://coolbuy.com/api/v1.4/page/${id}`,{headers})
            let res = await axios.post(url, data, {
                headers
            })
            if (res.data.name) {
                console.log("抽奖结果：" + res.data.name)
            } else {
                console.log(res.data)
            }
        } catch (err) {
            console.log(err.response.statusText);

        }
        resolve();
    });
}

function getinfo() {
    return new Promise(async (resolve) => {
        try {
            let url = "https://coolbuy.com/api/v1.4/member/"
            let res = await axios.get(url, {
                headers
            })
            info = `${res.data.nickname} || 可用玩币：${res.data.available_point} || ${res.data.checked_in_today==1?"今日已签":"今日未签"} || 连签${res.data.continuous_check_in_days}天`
            lotterycs = res.data.lottery_ticket_count
            console.log(info)
            result = "【玩物志好物商店】：" + info
        } catch (err) {
            console.log(err)
            console.log(err.response.statusText);
            result = "【玩物志好物商店】：" + err.response.statusText
        }
        resolve();
    });
}
async function coolbuy() {
    await getinfo()
    ids = [1060, 1063, 1061, 1062, 1048, 1049, 1047, 1056, 1054, 1064]
    for (id of ids) {
        await interact(id)
    }
    await sign()
    for (i = 0; i < lotterycs - 5; i++) {
        await lottery()
    }
    await getinfo()
    //   return result
}