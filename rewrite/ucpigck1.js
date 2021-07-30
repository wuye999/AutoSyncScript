const $ = new Env("UCPIG Cookie1");
let ucpigapp = $.getjson('ucpigapp', [])

  //++++++++++++++++++++++++++++++++++++
  !(async () => {
    if (typeof $request !== "undefined") {
      await GetCookie();
    }
  })()
  .catch((e) => {
    $.log('', `❌ ${$.name}, 失败! 原因: ${e}!`, '')
  })
  .finally(() => {
    $.done();
  })

//++++++++++++++++++++++++++++++++++++
async function GetCookie() {
 // 获取任务列表
  if ($request.url.match(/getTaskList/) && $request.url.indexOf("getTaskList") >= 0) {
    // const userbody = $request.body;
    const task_url = $request.url;
    const userId = $request.url.split("sn=")[1].split("&")[0];
    if (userId) {
      let status = 1;
      let no = ucpigapp.length;
      for (let i = 0, len = no; i < len; i++) {
        let ac = ucpigapp[i] || {};
        if (ac.uid) {
          if (ac.uid == userId) {
            no = i;
            status = 0;
            ucpigapp[no].task_url = task_url;
            break;
          }
        } else if (no == len) {
          no = i;
        }
      }
      let ucpigappck = ucpigapp[no];
      if (!ucpigappck) {
        ucpigapp[no] = {
          uid: userId,
          task_url,
        };
      }

      $.setdata(JSON.stringify(ucpigapp, null, 2), 'ucpigapp');
      $.log(`获取成功🎉: userkey: ${userkey}`)
      $.log(`获取成功🎉: userid: ${userId}`)
      $.log(`获取成功🎉: task_url: ${task_url}`)
      $.msg($.name, '', `UC小猪猪[账号${no+1}]获取任务列表成功！🎉`);
    } else {
      $.msg($.name, '', 'UC小猪猪获取任务列表失败⚠️');
    }

  }

  if ($request.url.match(/query/) && $request.url.indexOf("/query") >= 0) {
    // const userbody = $request.body;
    const query_url = $request.query_url;
    const userId = $request.url.split("sn=")[1].split("&")[0];
    if (userId) {
      let status = 1;
      let no = ucpigapp.length;
      for (let i = 0, len = no; i < len; i++) {
        let ac = ucpigapp[i] || {};
        if (ac.uid) {
          if (ac.uid == userId) {
            no = i;
            status = 0;
            ucpigapp[no].query_url = query_url;
            break;
          }
        } else if (no == len) {
          no = i;
        }
      }
      let ucpigappck = ucpigapp[no];
      if (!ucpigappck) {
        ucpigapp[no] = {
          uid: userId,
          query_url,
        };
      }

      $.setdata(JSON.stringify(ucpigapp, null, 2), 'ucpigapp');
      $.log(`获取成功🎉: userkey: ${userkey}`)
      $.log(`获取成功🎉: userid: ${userId}`)
      $.log(`获取成功🎉: query_url: ${query_url}`)
      $.msg($.name, '', `UC小猪猪[账号${no+1}]获取任务查询接口成功！🎉`);
    } else {
      $.msg($.name, '', 'UC小猪猪获取任务查询接口失败⚠️');
    }

  }



  //基础数据
  if ($request.url.match(/\/piggybank\/asset/) && $request.url.indexOf("getAssetInfo") >= 0) {
    // const userbody = $request.body;
    const userurl = $request.url;
    const userkey = JSON.stringify($request.headers);
    const userId = $request.url.split("sn=")[1].split("&")[0];
    if (userId) {
      let status = 1;
      let no = ucpigapp.length;
      for (let i = 0, len = no; i < len; i++) {
        let ac = ucpigapp[i] || {};
        if (ac.uid) {
          if (ac.uid == userId) {
            no = i;
            status = 0;
            ucpigapp[no].hd = userkey;
            ucpigapp[no].coinurl = userurl;
            break;
          }
        } else if (no == len) {
          no = i;
        }
      }
      let ucpigappck = ucpigapp[no]
      if (!ucpigappck) {
        ucpigapp[no] = {
          uid: userId,
          hd: userkey,
          coinurl: userurl
        };
      }

      $.setdata(JSON.stringify(ucpigapp, null, 2), 'ucpigapp');
      $.log(`获取成功🎉: userkey: ${userkey}`)
      $.log(`获取成功🎉: userid: ${userId}`)
      $.log(`获取成功🎉: coinurl: ${userurl}`)
      $.msg($.name, '', `UC小猪猪[账号${no+1}] ${status?'新增':'更新'}Cookie数据成功！🎉`);
    } else {
      $.msg($.name, '', 'UC小猪猪用户Cookie数据获取失败⚠️');
    }

  }
  //元宝兑换1元
  if ($request.url.match(/\/piggybank\/withdraw/) && $request.url.indexOf("exchange") >= 0) {
    const userbody = $request.body;
    const userkey = JSON.stringify($request.headers);
    const userId = $request.url.split("sn=")[1].split("&")[0];
    let len = ucpigapp.length;
    if (userId) {
      ucpigapp[calarrno(len, userId)].exchange = userbody;
      $.setdata(JSON.stringify(ucpigapp, null, 2), 'ucpigapp');
      $.log(`获取成功🎉: exchange: ${userbody}`)
      $.msg($.name, "", `UC小猪猪[账号${calarrno(len,userId)+1}] 获取[元宝兑换]数据成功！🎉`);
    } else {
      $.msg($.name, '', 'UC小猪猪用户Cookie数据获取失败⚠️');
    }

  }
  //提现支付宝1元
  if ($request.url.match(/\/exchange\/submitExchange/)) {
    const userbody = $request.body;
    const userkey = JSON.stringify($request.headers);
    const userId = $request.url.split("sn=")[1].split("&")[0];
    let len = ucpigapp.length;
    if (userId) {
      ucpigapp[calarrno(len, userId)].txmoney = userbody;
      $.setdata(JSON.stringify(ucpigapp, null, 2), 'ucpigapp');
      $.log(`获取成功🎉: txmoney: ${userbody}`)
      $.msg($.name, "", `UC小猪猪[账号${calarrno(len,userId)+1}] 获取[提现支付宝]数据成功！🎉`);
    } else {
      $.msg($.name, '', 'UC小猪猪用户Cookie数据获取失败⚠️');
    }

  }
  //收元宝
  if ($request.url.match(/\/piggybank\/common/) && $request.url.indexOf("receiveAward") >= 0) {
    const userurl = $request.url;
    const userbody = $request.body;
    const userkey = JSON.stringify($request.headers);
    const userId = $request.url.split("sn=")[1].split("&")[0];
    let len = ucpigapp.length;
    if (userId) {
      ucpigapp[calarrno(len, userId)].pigawardurl = userurl;
      ucpigapp[calarrno(len, userId)].pigawardbody = userbody;
      $.setdata(JSON.stringify(ucpigapp, null, 2), 'ucpigapp');
      $.log(`获取成功🎉: pigawardurl: ${userurl}`)
      $.log(`获取成功🎉: pigawardbody: ${userbody}`)
      $.msg($.name, "", `UC小猪猪[账号${calarrno(len,userId)+1}] 获取[收元宝]数据成功！🎉`);
    } else {
      $.msg($.name, '', 'UC小猪猪用户Cookie数据获取失败⚠️');
    }

  }

  //获取任务请求
  if ($request.url.match(/\/task\/trigger/) && $request.url.indexOf("complete") >= 0) {
    const userkey = JSON.stringify($request.headers);
    const userurl = $request.url;
    let uid = $request.url.split("sn=")[1].split("&")[0];
    let len = ucpigapp.length;
    if (uid) {
      const videoTid = $request.url.split("tid=")[1].split("&")[0];
      let videoTaskArr = ucpigapp[calarrno(len, uid)].videotask1 || [];

      if (videoTid) {
        let arrnum = videoTaskArr.length;
        console.log(`arrnum:${arrnum}`);
        for (let i = 0, len = arrnum; i < len; i++) {
          let videoBoxTid = videoTaskArr[i].split("tid=")[1].split("&")[0]
          if (videoBoxTid) {
            if (videoBoxTid == videoTid) {
              arrnum = i;
              break;
            }
          } else if (arrnum == len) {
            arrnum = i;
          }
        }

        let videoTaskArrCK = videoTaskArr[arrnum];
        if (!videoTaskArrCK) {
          videoTaskArr[arrnum] = userurl;
        };
      }

      ucpigapp[calarrno(len, uid)].videotask1 = videoTaskArr;
      $.setdata(JSON.stringify(ucpigapp, null, 2), 'ucpigapp');
      $.log(`获取成功🎉: videoTaskUrl: ${userurl}`)
      $.msg($.name, "", `UC小猪猪[账号${calarrno(len,uid)+1}] 获取第一天[任务${videoTid}]数据成功！🎉`);
    } else {
      $.msg($.name, "", 'UC小猪猪第一天[视频]数据获取失败⚠️');
    }
  }
  //领取任务奖励
  if ($request.url.match(/\/task\/trigger/) && $request.url.indexOf("award") >= 0) {
    const userkey = JSON.stringify($request.headers);
    const userurl = $request.url;
    let uid = $request.url.split("sn=")[1].split("&")[0];
    let len = ucpigapp.length;
    if (uid) {
      const videoTid = $request.url.split("tid=")[1].split("&")[0];
      let videoAwardArr = ucpigapp[calarrno(len, uid)].videoaward || [];

      if (videoTid) {
        let arrnum = videoAwardArr.length;
        console.log(`arrnum:${arrnum}`);
        for (let i = 0, len = arrnum; i < len; i++) {
          let videoBoxTid = videoAwardArr[i].split("tid=")[1].split("&")[0]
          if (videoBoxTid) {
            if (videoBoxTid == videoTid) {
              arrnum = i;
              break;
            }
          } else if (arrnum == len) {
            arrnum = i;
          }
        }

        let videoAwardArrCK = videoAwardArr[arrnum];
        if (!videoAwardArrCK) {
          videoAwardArr[arrnum] = userurl;
        };
      }

      ucpigapp[calarrno(len, uid)].videoaward = videoAwardArr;
      $.setdata(JSON.stringify(ucpigapp, null, 2), 'ucpigapp');
      $.log(`获取成功🎉: videoAwardUrl: ${userurl}`)
      $.msg($.name, "", `UC小猪猪[账号${calarrno(len,uid)+1}] 获取[奖励${videoTid}]数据成功！🎉`);
    } else {
      $.msg($.name, "", 'UC小猪猪第一天[奖励]数据获取失败⚠️');
    }
  }

}

//++++++++++++++++++++++++++++++++++++
function safeGet(data) {
  try {
    if (typeof JSON.parse(data) == "object") {
      return true;
    }
  } catch (e) {
    console.log(e);
    console.log(`⛔️服务器访问数据为空，请检查自身设备网络情况`);
    return false;
  }
}

function calarrno(l, n) {
  let no = l;
  for (let i = 0, len2 = no; i < len2; i++) {
    let ac = ucpigapp[i] || {};
    if (ac.uid) {
      if (ac.uid == n) {
        no = i;
        break;
      }
    } else if (no == len2) {
      no = i;
    }
  }
  return no
}

function Env(name, opts) {
  class Http {
    constructor(env) {
      this.env = env
    }

    send(opts, method = 'GET') {
      opts = typeof opts === 'string' ? {
        url: opts
      } : opts
      let sender = this.get
      if (method === 'POST') {
        sender = this.post
      }
      return new Promise((resolve, reject) => {
        sender.call(this, opts, (err, resp, body) => {
          if (err) reject(err)
          else resolve(resp)
        })
      })
    }

    get(opts) {
      return this.send.call(this.env, opts)
    }

    post(opts) {
      return this.send.call(this.env, opts, 'POST')
    }
  }

  return new(class {
    constructor(name, opts) {
      this.name = name
      this.http = new Http(this)
      this.data = null
      this.dataFile = 'box.dat'
      this.logs = []
      this.isMute = false
      this.isNeedRewrite = false
      this.logSeparator = '\n'
      this.startTime = new Date().getTime()
      Object.assign(this, opts)
      this.log('', `🔔${this.name}, 开始!`)
    }

    isNode() {
      return 'undefined' !== typeof module && !!module.exports
    }

    isQuanX() {
      return 'undefined' !== typeof $task
    }

    isSurge() {
      return 'undefined' !== typeof $httpClient && 'undefined' === typeof $loon
    }

    isLoon() {
      return 'undefined' !== typeof $loon
    }

    isShadowrocket() {
      return 'undefined' !== typeof $rocket
    }

    toObj(str, defaultValue = null) {
      try {
        return JSON.parse(str)
      } catch {
        return defaultValue
      }
    }

    toStr(obj, defaultValue = null) {
      try {
        return JSON.stringify(obj)
      } catch {
        return defaultValue
      }
    }

    getjson(key, defaultValue) {
      let json = defaultValue
      const val = this.getdata(key)
      if (val) {
        try {
          json = JSON.parse(this.getdata(key))
        } catch {}
      }
      return json
    }

    setjson(val, key) {
      try {
        return this.setdata(JSON.stringify(val), key)
      } catch {
        return false
      }
    }

    getScript(url) {
      return new Promise((resolve) => {
        this.get({
          url
        }, (err, resp, body) => resolve(body))
      })
    }

    runScript(script, runOpts) {
      return new Promise((resolve) => {
        let httpapi = this.getdata('@chavy_boxjs_userCfgs.httpapi')
        httpapi = httpapi ? httpapi.replace(/\n/g, '').trim() : httpapi
        let httpapi_timeout = this.getdata('@chavy_boxjs_userCfgs.httpapi_timeout')
        httpapi_timeout = httpapi_timeout ? httpapi_timeout * 1 : 20
        httpapi_timeout = runOpts && runOpts.timeout ? runOpts.timeout : httpapi_timeout
        const [key, addr] = httpapi.split('@')
        const opts = {
          url: `http://${addr}/v1/scripting/evaluate`,
          body: {
            script_text: script,
            mock_type: 'cron',
            timeout: httpapi_timeout
          },
          headers: {
            'X-Key': key,
            'Accept': '*/*'
          }
        }
        this.post(opts, (err, resp, body) => resolve(body))
      }).catch((e) => this.logErr(e))
    }

    loaddata() {
      if (this.isNode()) {
        this.fs = this.fs ? this.fs : require('fs')
        this.path = this.path ? this.path : require('path')
        const curDirDataFilePath = this.path.resolve(this.dataFile)
        const rootDirDataFilePath = this.path.resolve(process.cwd(), this.dataFile)
        const isCurDirDataFile = this.fs.existsSync(curDirDataFilePath)
        const isRootDirDataFile = !isCurDirDataFile && this.fs.existsSync(rootDirDataFilePath)
        if (isCurDirDataFile || isRootDirDataFile) {
          const datPath = isCurDirDataFile ? curDirDataFilePath : rootDirDataFilePath
          try {
            return JSON.parse(this.fs.readFileSync(datPath))
          } catch (e) {
            return {}
          }
        } else return {}
      } else return {}
    }

    writedata() {
      if (this.isNode()) {
        this.fs = this.fs ? this.fs : require('fs')
        this.path = this.path ? this.path : require('path')
        const curDirDataFilePath = this.path.resolve(this.dataFile)
        const rootDirDataFilePath = this.path.resolve(process.cwd(), this.dataFile)
        const isCurDirDataFile = this.fs.existsSync(curDirDataFilePath)
        const isRootDirDataFile = !isCurDirDataFile && this.fs.existsSync(rootDirDataFilePath)
        const jsondata = JSON.stringify(this.data)
        if (isCurDirDataFile) {
          this.fs.writeFileSync(curDirDataFilePath, jsondata)
        } else if (isRootDirDataFile) {
          this.fs.writeFileSync(rootDirDataFilePath, jsondata)
        } else {
          this.fs.writeFileSync(curDirDataFilePath, jsondata)
        }
      }
    }

    lodash_get(source, path, defaultValue = undefined) {
      const paths = path.replace(/\[(\d+)\]/g, '.$1').split('.')
      let result = source
      for (const p of paths) {
        result = Object(result)[p]
        if (result === undefined) {
          return defaultValue
        }
      }
      return result
    }

    lodash_set(obj, path, value) {
      if (Object(obj) !== obj) return obj
      if (!Array.isArray(path)) path = path.toString().match(/[^.[\]]+/g) || []
      path
        .slice(0, -1)
        .reduce((a, c, i) => (Object(a[c]) === a[c] ? a[c] : (a[c] = Math.abs(path[i + 1]) >> 0 === +path[i + 1] ? [] : {})), obj)[
          path[path.length - 1]
        ] = value
      return obj
    }

    getdata(key) {
      let val = this.getval(key)
      // 如果以 @
      if (/^@/.test(key)) {
        const [, objkey, paths] = /^@(.*?)\.(.*?)$/.exec(key)
        const objval = objkey ? this.getval(objkey) : ''
        if (objval) {
          try {
            const objedval = JSON.parse(objval)
            val = objedval ? this.lodash_get(objedval, paths, '') : val
          } catch (e) {
            val = ''
          }
        }
      }
      return val
    }

    setdata(val, key) {
      let issuc = false
      if (/^@/.test(key)) {
        const [, objkey, paths] = /^@(.*?)\.(.*?)$/.exec(key)
        const objdat = this.getval(objkey)
        const objval = objkey ? (objdat === 'null' ? null : objdat || '{}') : '{}'
        try {
          const objedval = JSON.parse(objval)
          this.lodash_set(objedval, paths, val)
          issuc = this.setval(JSON.stringify(objedval), objkey)
        } catch (e) {
          const objedval = {}
          this.lodash_set(objedval, paths, val)
          issuc = this.setval(JSON.stringify(objedval), objkey)
        }
      } else {
        issuc = this.setval(val, key)
      }
      return issuc
    }

    getval(key) {
      if (this.isSurge() || this.isLoon()) {
        return $persistentStore.read(key)
      } else if (this.isQuanX()) {
        return $prefs.valueForKey(key)
      } else if (this.isNode()) {
        this.data = this.loaddata()
        return this.data[key]
      } else {
        return (this.data && this.data[key]) || null
      }
    }

    setval(val, key) {
      if (this.isSurge() || this.isLoon()) {
        return $persistentStore.write(val, key)
      } else if (this.isQuanX()) {
        return $prefs.setValueForKey(val, key)
      } else if (this.isNode()) {
        this.data = this.loaddata()
        this.data[key] = val
        this.writedata()
        return true
      } else {
        return (this.data && this.data[key]) || null
      }
    }

    initGotEnv(opts) {
      this.got = this.got ? this.got : require('got')
      this.cktough = this.cktough ? this.cktough : require('tough-cookie')
      this.ckjar = this.ckjar ? this.ckjar : new this.cktough.CookieJar()
      if (opts) {
        opts.headers = opts.headers ? opts.headers : {}
        if (undefined === opts.headers.Cookie && undefined === opts.cookieJar) {
          opts.cookieJar = this.ckjar
        }
      }
    }

    get(opts, callback = () => {}) {
      if (opts.headers) {
        delete opts.headers['Content-Type']
        delete opts.headers['Content-Length']
      }
      if (this.isSurge() || this.isLoon()) {
        if (this.isSurge() && this.isNeedRewrite) {
          opts.headers = opts.headers || {}
          Object.assign(opts.headers, {
            'X-Surge-Skip-Scripting': false
          })
        }
        $httpClient.get(opts, (err, resp, body) => {
          if (!err && resp) {
            resp.body = body
            resp.statusCode = resp.status
          }
          callback(err, resp, body)
        })
      } else if (this.isQuanX()) {
        if (this.isNeedRewrite) {
          opts.opts = opts.opts || {}
          Object.assign(opts.opts, {
            hints: false
          })
        }
        $task.fetch(opts).then(
          (resp) => {
            const {
              statusCode: status,
              statusCode,
              headers,
              body
            } = resp
            callback(null, {
              status,
              statusCode,
              headers,
              body
            }, body)
          },
          (err) => callback(err)
        )
      } else if (this.isNode()) {
        this.initGotEnv(opts)
        this.got(opts)
          .on('redirect', (resp, nextOpts) => {
            try {
              if (resp.headers['set-cookie']) {
                const ck = resp.headers['set-cookie'].map(this.cktough.Cookie.parse).toString()
                if (ck) {
                  this.ckjar.setCookieSync(ck, null)
                }
                nextOpts.cookieJar = this.ckjar
              }
            } catch (e) {
              this.logErr(e)
            }
            // this.ckjar.setCookieSync(resp.headers['set-cookie'].map(Cookie.parse).toString())
          })
          .then(
            (resp) => {
              const {
                statusCode: status,
                statusCode,
                headers,
                body
              } = resp
              callback(null, {
                status,
                statusCode,
                headers,
                body
              }, body)
            },
            (err) => {
              const {
                message: error,
                response: resp
              } = err
              callback(error, resp, resp && resp.body)
            }
          )
      }
    }

    post(opts, callback = () => {}) {
      const method = opts.method ? opts.method.toLocaleLowerCase() : 'post'
      // 如果指定了请求体, 但没指定`Content-Type`, 则自动生成
      if (opts.body && opts.headers && !opts.headers['Content-Type']) {
        opts.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      }
      if (opts.headers) delete opts.headers['Content-Length']
      if (this.isSurge() || this.isLoon()) {
        if (this.isSurge() && this.isNeedRewrite) {
          opts.headers = opts.headers || {}
          Object.assign(opts.headers, {
            'X-Surge-Skip-Scripting': false
          })
        }
        $httpClient[method](opts, (err, resp, body) => {
          if (!err && resp) {
            resp.body = body
            resp.statusCode = resp.status
          }
          callback(err, resp, body)
        })
      } else if (this.isQuanX()) {
        opts.method = method
        if (this.isNeedRewrite) {
          opts.opts = opts.opts || {}
          Object.assign(opts.opts, {
            hints: false
          })
        }
        $task.fetch(opts).then(
          (resp) => {
            const {
              statusCode: status,
              statusCode,
              headers,
              body
            } = resp
            callback(null, {
              status,
              statusCode,
              headers,
              body
            }, body)
          },
          (err) => callback(err)
        )
      } else if (this.isNode()) {
        this.initGotEnv(opts)
        const {
          url,
          ..._opts
        } = opts
        this.got[method](url, _opts).then(
          (resp) => {
            const {
              statusCode: status,
              statusCode,
              headers,
              body
            } = resp
            callback(null, {
              status,
              statusCode,
              headers,
              body
            }, body)
          },
          (err) => {
            const {
              message: error,
              response: resp
            } = err
            callback(error, resp, resp && resp.body)
          }
        )
      }
    }
    /**
     *
     * 示例:$.time('yyyy-MM-dd qq HH:mm:ss.S')
     *    :$.time('yyyyMMddHHmmssS')
     *    y:年 M:月 d:日 q:季 H:时 m:分 s:秒 S:毫秒
     *    其中y可选0-4位占位符、S可选0-1位占位符，其余可选0-2位占位符
     * @param {string} fmt 格式化参数
     * @param {number} 可选: 根据指定时间戳返回格式化日期
     *
     */
    time(fmt, ts = null) {
      const date = ts ? new Date(ts) : new Date()
      let o = {
        'M+': date.getMonth() + 1,
        'd+': date.getDate(),
        'H+': date.getHours(),
        'm+': date.getMinutes(),
        's+': date.getSeconds(),
        'q+': Math.floor((date.getMonth() + 3) / 3),
        'S': date.getMilliseconds()
      }
      if (/(y+)/.test(fmt)) fmt = fmt.replace(RegExp.$1, (date.getFullYear() + '').substr(4 - RegExp.$1.length))
      for (let k in o)
        if (new RegExp('(' + k + ')').test(fmt))
          fmt = fmt.replace(RegExp.$1, RegExp.$1.length == 1 ? o[k] : ('00' + o[k]).substr(('' + o[k]).length))
      return fmt
    }

    /**
     * 系统通知
     *
     * > 通知参数: 同时支持 QuanX 和 Loon 两种格式, EnvJs根据运行环境自动转换, Surge 环境不支持多媒体通知
     *
     * 示例:
     * $.msg(title, subt, desc, 'twitter://')
     * $.msg(title, subt, desc, { 'open-url': 'twitter://', 'media-url': 'https://github.githubassets.com/images/modules/open_graph/github-mark.png' })
     * $.msg(title, subt, desc, { 'open-url': 'https://bing.com', 'media-url': 'https://github.githubassets.com/images/modules/open_graph/github-mark.png' })
     *
     * @param {*} title 标题
     * @param {*} subt 副标题
     * @param {*} desc 通知详情
     * @param {*} opts 通知参数
     *
     */
    msg(title = name, subt = '', desc = '', opts) {
      const toEnvOpts = (rawopts) => {
        if (!rawopts) return rawopts
        if (typeof rawopts === 'string') {
          if (this.isLoon()) return rawopts
          else if (this.isQuanX()) return {
            'open-url': rawopts
          }
          else if (this.isSurge()) return {
            url: rawopts
          }
          else return undefined
        } else if (typeof rawopts === 'object') {
          if (this.isLoon()) {
            let openUrl = rawopts.openUrl || rawopts.url || rawopts['open-url']
            let mediaUrl = rawopts.mediaUrl || rawopts['media-url']
            return {
              openUrl,
              mediaUrl
            }
          } else if (this.isQuanX()) {
            let openUrl = rawopts['open-url'] || rawopts.url || rawopts.openUrl
            let mediaUrl = rawopts['media-url'] || rawopts.mediaUrl
            return {
              'open-url': openUrl,
              'media-url': mediaUrl
            }
          } else if (this.isSurge()) {
            let openUrl = rawopts.url || rawopts.openUrl || rawopts['open-url']
            return {
              url: openUrl
            }
          }
        } else {
          return undefined
        }
      }
      if (!this.isMute) {
        if (this.isSurge() || this.isLoon()) {
          $notification.post(title, subt, desc, toEnvOpts(opts))
        } else if (this.isQuanX()) {
          $notify(title, subt, desc, toEnvOpts(opts))
        }
      }
      if (!this.isMuteLog) {
        let logs = ['', '==============📣系统通知📣==============']
        logs.push(title)
        subt ? logs.push(subt) : ''
        desc ? logs.push(desc) : ''
        console.log(logs.join('\n'))
        this.logs = this.logs.concat(logs)
      }
    }

    log(...logs) {
      if (logs.length > 0) {
        this.logs = [...this.logs, ...logs]
      }
      console.log(logs.join(this.logSeparator))
    }

    logErr(err, msg) {
      const isPrintSack = !this.isSurge() && !this.isQuanX() && !this.isLoon()
      if (!isPrintSack) {
        this.log('', `❗️${this.name}, 错误!`, err)
      } else {
        this.log('', `❗️${this.name}, 错误!`, err.stack)
      }
    }

    wait(time) {
      return new Promise((resolve) => setTimeout(resolve, time))
    }

    done(val = {}) {
      const endTime = new Date().getTime()
      const costTime = (endTime - this.startTime) / 1000
      this.log('', `🔔${this.name}, 结束! 🕛 ${costTime} 秒`)
      this.log()
      if (this.isSurge() || this.isQuanX() || this.isLoon()) {
        $done(val)
      }
    }
  })(name, opts)
}
