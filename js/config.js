/* this js script that the _json.%domain% DNSi TXT record 
   and use it as a map to substitute keywords ...

 usage :

<script src=https://cdn.jsdelivr.net/gh/iglake/js@1.6/dist/dns.js></script>
<script src=https://cdn.jsdelivr.net/gh/iglake/js@1.6/dist/config.js ></script>
DNS.Query('_json.'+domain,'TXT', callback('body'))

*/

 */

var hostname = document.location.hostname;
var domain = hostname.replace(/www./,'');
var loc = document.location.toString();
    loc = loc.replace(/#.*/,'');
var fragment = window.location.hash.substring(1);


let e = document.getElementsByClassName('url')[0];
if (typeof(e) != 'undefined') {
  url = e.href;
} else {
  url = 'http://ipfs.blockringtm.ml';
}

function callback(tag) {
   var display = function(json) {
   var map = [];
   console.log(json);
   var rr = json.rr
   for(let i=0; i<rr.length; i++) {
    if ( json['type'] == 'TXT' ) {
      txt = decode(rr[i]['txtdata']);
      console.log('txt['+i+']='+txt);
    } else {
      txt = '{"name":"json config record","status":"empty","note":"pass it forward!","framaid":"jsonconf","qm":"z6cYNbecZSFzLjbSimKuibtdpGt7DAUMMt46aKQNdwfs"}'
    }
      map = JSON.parse(txt);
      console.log(map);
   }
   console.log('tag: '+tag);
   let head = document.getElementsByTagName('head')[0];
   let bod = document.getElementsByTagName(tag)[0];
   if ( typeof(bod) == 'undefined') {
       bod = document.getElementById(tag);
   }

   var buf = bod.innerHTML;
       buf = buf.replace(/%url%/g,url);
       buf = buf.replace(/%loc%/g,loc);
       buf = buf.replace(/%domain%/g,domain);
       buf = buf.replace(/%hostname%/g,hostname);
       buf = buf.replace(/%origin%/g,document.location.origin);
       buf = buf.replace(/%fragmetn%/g,fragment);
       buf = buf.replace(/%rr%/g,txt);

   for (let key in map) {
      let rex = RegExp('%'+key+'%','g');
      buf = buf.replace(rex,map[key]);
      head.innerHTML = head.innerHTML.replace(rex,map[key]);
   }

   bod.innerHTML = buf; // rewrite the body !
   }
   return display
}

function decode(str) {
  return str.replace(/\\(\d{3})/g, function(match, dec) {
				return String.fromCharCode(dec);
	});
}
