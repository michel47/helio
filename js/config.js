/* $Id: config.js 1.7.2 2019/10/28 19:57:07 iggy Exp $

   $Revision: v1.7.2 $

   this js script fetch a config file or a DNS TXT record 
   and use the returned json as a map to substitute keywords ...

 usage :

<script src=https://cdn.jsdelivr.net/gh/iglake/js@1.6/dist/config.js ></script>
<script> CFG.File('config.json', callback('body')) </script>
<script> CFG.DNS(domain,callback('body')) </script>

*/

CFG = { File: getfile, DNS: getdnsjson }

var hostname = document.location.hostname
var domain = hostname.replace(/www./,'')
var loc = document.location.toString()
    loc = loc.replace(/#.*/,'')
var fragment = window.location.hash.substring(1)


function getfile(name,callback){ // load config.json file
  var domain = document.location.hostname.replace(/www./,'');
  var subdomain = domain.substring(0,domain.lastIndexOf('.'))
  name = name.replace(/%subdomain%/,subdomain);
  name = name.replace(/%domain%/,domain);
  console.log('filename:'+name)
  let config = new XMLHttpRequest();
  let s = loc.lastIndexOf('/') + 1;
  let dir = loc.substring(0,s);
  config.open('GET', dir + name);
  config.send();
  config.onload = function () {
     if (config.status == 200) {
        var json = JSON.parse(config.response)
        console.log('status: '+config.status)
        return callback(json);
     } else {
       console.log('status: '+config.status)
       return callback({ "name": "website", "description":"generic website "+domain });
     }

  }
}
function getdnsjson(domain, callback) {
   let apisvr = 'http://127.0.0.1:8088/repositories/helio';
   if (document.location.hostname != '127.0.0.1') {
      apisvr = 'https://iph.heliohost.org';
   }
   var url = apisvr+'/cgi-bin/dnsquery.pl?fmt=json';
   var request = { Domain: domain, Type: 'TXT' };
   fetch(url, { method: "POST",
         headers:{'Content-Type': 'application/json'},
         body: JSON.stringify(request),
         mode: 'cors'
         })
   .then ( resp => {
         if (resp.status >= 200 && resp.status < 300) {
           return Promise.resolve(resp)
         }
         return Promise.reject(new Error(resp.statusText))
         } )
   .then ( resp => {
         console.log(resp);
         return resp.json() }
         )
   .then ( json => {
            var map = []
            console.log(json)
            var rr = json.rr
            let tics = json.tics
            for(let i=0; i<rr.length; i++) {
            if ( json['type'] == 'TXT' ) {
            txt = decode(rr[i]['txtdata'])
            console.log('txt['+i+']='+txt)
            } else {
            txt = '{"title":"JSon Config Record","name":"JSonCFG","status":"empty", "note":"pass it forward!","framaid":"jsonconf", "qm":"z6cYNbecZSFzLjbSimKuibtdpGt7DAUMMt46aKQNdwfs"}'
            }
            map = JSON.parse(txt)
            if (typeof(json['ip']) != 'undefined') { map['ip'] = json['ip'] }
            if (typeof(json['tics']) != 'undefined') { map['tics'] = json['tics'] }
            callback(map);
            } 
            
            })
   .catch( e => { console.error(e) } )
}

function callback(tag) {
   var substi = function(map) {
   let badges = document.getElementById('badges')
   if (badges) {
      badges.innerHTML = badges.innerHTML.replace(/%ip%/g,map['ip'])
      badges.innerHTML = badges.innerHTML.replace(/%name%/g,map['name'])
   }
   let head = document.getElementsByTagName('head')[0]
   //console.log('tag: '+tag)
   let bod = document.getElementsByTagName(tag)[0]
   if ( typeof(bod) == 'undefined') {
       bod = document.getElementById(tag)
   }
   let url
   let e = bod.getElementsByClassName('url')[0]
   if (typeof(e) != 'undefined') {
     url = e.href
   } else {
     url = 'http://ipfs.blockringtm.ml/'
   }

   let tics
   if ( typeof(map['tics']) == 'undefined') {
     tics = (new Date()).getTime() / 1000
   } else {
     tics = map['tics']
   }
   let date = pDate(tics)


   var buf = bod.innerHTML
       buf = buf.replace(/%tics%/g,tics)
       buf = buf.replace(/%date%/g,date)
       buf = buf.replace(/%url%/g,url)
       buf = buf.replace(/%loc%/g,loc)
       buf = buf.replace(/%domain%/g,domain)
       buf = buf.replace(/%hostname%/g,hostname)
       buf = buf.replace(/%origin%/g,document.location.origin)
       buf = buf.replace(/%fragmetn%/g,fragment)

   for (let key in map) {
      let rex = RegExp('%'+key+'%','g')
      buf = buf.replace(rex,map[key])
      head.innerHTML = head.innerHTML.replace(rex,map[key])
   }

   bod.innerHTML = buf; // rewrite the body !
   }
   return substi;
}

function pDate(tics) {
  let date = new Date(tics*1000)
  let year = date.getFullYear()
  let month = date.getMonth() + 1
  let day = date.getDate()
  let hours = date.getHours()
  let minutes = "0" + date.getMinutes()
  var dateTime = month+'/'+day+'/'+year+' '+hours + ':' + minutes.substr(-2)
  return dateTime
}

function decode(str) {
  return str.replace(/\\(\d{3})/g, function(match, dec) {
				return String.fromCharCode(dec)
	})
}
