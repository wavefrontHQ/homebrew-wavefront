# Wavefront Homebrew Formulas

These formulas allow installing supported wavefront integrations on MacOS using Homebrew.

## Installation (via install script)

Install wavefront proxy:  
```curl -sL https://raw.githubusercontent.com/wavefrontHQ/homebrew-wavefront/master/sh/install.sh | bash -s -- -p -t API_TOKEN -u WAVEFRONT_URL/api```

Install wavefront telegraf agent:  
```curl -sL https://raw.githubusercontent.com/wavefrontHQ/homebrew-wavefront/master/sh/install.sh | bash -s -- -a -h PROXY_HOST_ADDRESS```

Install both the proxy and telegraf agent:  
```curl -sL https://raw.githubusercontent.com/wavefrontHQ/homebrew-wavefront/master/sh/install.sh | bash -s -- -p -t API_TOKEN -u WAVEFRONT_URL/api -a -h PROXY_HOST_ADDRESS```


## Installation (via Homebrew)

Note: This option requires manually configuring the proxy and the telegraf agent (see Miscellaneous).

Install [Homebrew](https://brew.sh/) and then install the wavefront Tap:

```brew tap wavefrontHQ/wavefront```

Wavefront proxy: ```brew install wfproxy```  
Wavefront telegraf agent: ```brew install wftelegraf```  
Proxy and telegraf agent: ```brew install wfproxy --with-wftelegraf```


## Miscellaneous
Start the proxy: ```brew services start wfproxy```  
Stop the proxy: ```brew services stop wfproxy```  
Start the telegraf agent: ```brew services start wftelegraf```  
Stop the telegraf agent: ```brew services stop wftelegraf```  

Proxy configuration file: ```/usr/local/etc/wfproxy.conf```  
Agent configuration file: ```/usr/local/etc/telegraf.conf``` & ```/usr/local/etc/telegraf.d```

Proxy log file: ```/usr/local/var/log/wfproxy.log ```   
Agent log file: ```/usr/local/var/log/telegraf.log```
