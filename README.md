# Wavefront Homebrew Formulas

These formulas allow installing supported wavefront integrations on MacOS using Homebrew.

## Installation (via install script)

Wavefront proxy:  
```curl -sL https://raw.githubusercontent.com/wavefrontHQ/homebrew-wavefront/master/sh/install.sh | bash -s -- -p -t API_TOKEN -u WAVEFRONT_URL/api```

Wavefront Telegraf agent:  
```curl -sL https://raw.githubusercontent.com/wavefrontHQ/homebrew-wavefront/master/sh/install.sh | bash -s -- -a -h PROXY_HOST_ADDRESS```

Proxy and Telegraf agent:  
```curl -sL https://raw.githubusercontent.com/wavefrontHQ/homebrew-wavefront/master/sh/install.sh | bash -s -- -p -t API_TOKEN -u WAVEFRONT_URL/api -a```


## Installation (via Homebrew)

Note: This option requires manually configuring the proxy and the telegraf agent (see Miscellaneous).

Install [Homebrew](https://brew.sh/) and then install the wavefront Tap:

```brew tap wavefrontHQ/wavefront```

Wavefront proxy: ```brew install wfproxy```  
Wavefront Telegraf agent: ```brew install wftelegraf```  
Proxy and Telegraf agent: ```brew install wfproxy --with-wftelegraf```


## Miscellaneous
Start the proxy: ```brew services start wfproxy```  
Stop the proxy: ```brew services stop wfproxy```  
Start the telegraf agent: ```brew services start wftelegraf```  
Stop the telegraf agent: ```brew services stop wftelegraf```  

Proxy configuration file: ```/usr/local/etc/wfproxy.conf```  
Telegraf configuration file: ```/usr/local/etc/telegraf.conf``` & ```/usr/local/etc/telegraf.d```

Proxy log file: ```/usr/local/var/log/wfproxy.log ```   
Telegraf log file: ```/usr/local/var/log/telegraf.log```

## Uninstall
```curl -sL https://raw.githubusercontent.com/wavefrontHQ/homebrew-wavefront/master/sh/uninstall.sh | bash -s```
