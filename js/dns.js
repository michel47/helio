// DNS-JS.com - Make DNS queries from Javascript
// Copyright 2019 Infinite Loop Development Ltd - InfiniteLoop.ie
// Do not remove this notice.

DNS = {
    Query: function (domain, type, callback) {
        //console.log("domain: "+domain+", type: "+type);
        DNS.dnsapi({
            Action: "Query",
            Domain: domain,
            Type: type
        },
        callback);
    },
    //dnsapi: callapi,
    //dnsapi: echo
    dnsapi: dnscall
};

const status = resp => {
  if (resp.status >= 200 && resp.status < 300) {
    return Promise.resolve(resp)
  }
  return Promise.reject(new Error(resp.statusText))
}

function dnscall(request,callback) {
        var url = "../cgi-bin/dnsquery.pl?fmt=json";
        console.log(request);
        fetch(url, { method: "POST", body: JSON.stringify(request) })
        .then( status )
        .then( resp => {
         console.log(resp);
         return resp.json()
        })
        .then( obj => {
            callback(obj);
        } )
        .catch( e => { console.error(e) } )
}

function echo(request,callback) {
        var url = "../cgi-bin/echo.pl";
        fetch(url, { method: "POST", body: JSON.stringify(request) })
        .then( status )
        .then( resp => {
         console.log(resp);
         return resp.json()
        })
        .then( obj => {
            callback(obj);
        } )
        .catch( e => { console.error(e) } )
}

function callapi(request,callback) {
     var url = 'https://www.dns-js.com/api.aspx';
     var xhr = new XMLHttpRequest();
        xhr.open("POST", url);
        xhr.onreadystatechange = function () {
            if (this.readyState === XMLHttpRequest.DONE && this.status === 200) {
                callback(JSON.parse(xhr.response));
            }
        }
        xhr.send(JSON.stringify(request));
}

/* 0 	UNSENT 	Client has been created. open() not called yet.
   1 	OPENED 	open() has been called.
   2 	HEADERS_RECEIVED 	send() has been called, and headers and status are available.
   3 	LOADING 	Downloading; responseText holds partial data.
   4 	DONE 	The operation is complete.
*/
