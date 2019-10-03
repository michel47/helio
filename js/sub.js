
var url = document.location.href;
var host = document.location.host;
var loc = document.location.toString();
    loc = loc.replace(/#.*/,'');
var fragment = window.location.hash.substring(1);

var body = document.getElementsByTagName('body')[0];
//console.log('body: '+body.innerHTML);
var buf = body.innerHTML.replace('%url%',url);
    buf = buf.replace(/%domain%/g,document.location.hostname);
    buf = buf.replace(/%origin%/g,document.location.origin);

    buf = buf.replace('%host%',host);
    buf = buf.replace('%loc%',loc);
    buf = buf.replace('%fragment%',fragment);
console.log('buf: '+buf);
document.body.innerHTML = buf;
