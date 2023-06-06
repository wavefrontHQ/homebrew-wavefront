# Wavefront Homebrew Formulas

These formulas allow installing supported wavefront integrations on MacOS using Homebrew.

## Installation (via install script)

Wavefront proxy:
# Wavefront authentication can be configured in three different ways: Customers that have been
# onboarded by CSP can set up CSP api tokens or CSP OAuth apps (CSP_APP_ID, CSP_APP_SECRET, CSP_ORG_ID).
# Customers of Wavefront can use Wavefront api token. Here are the ways to install proxy.
```
curl -sL https://raw.githubusercontent.com/wavefrontHQ/homebrew-wavefront/master/sh/install.sh | bash -s -- -p -t WAVEFRONT_API_TOKEN -u WAVEFRONT_URL/api

curl -sL https://raw.githubusercontent.com/wavefrontHQ/homebrew-wavefront/master/sh/install.sh | bash -s -- -p -cspAPIToken CSP_API_TOKEN -u WAVEFRONT_URL/api

curl -sL https://raw.githubusercontent.com/wavefrontHQ/homebrew-wavefront/master/sh/install.sh | bash -s -- -p -cspAppId CSP_APP_ID -cspAppSecret CSP_APP_SECRET -cspOrgId CSP_ORG_ID -u WAVEFRONT_URL/api

```

Telegraf agent:  
```
curl -sL https://raw.githubusercontent.com/wavefrontHQ/homebrew-wavefront/master/sh/install.sh | bash -s -- -a -h PROXY_HOST_ADDRESS
```

Proxy and Telegraf agent:  
```
curl -sL https://raw.githubusercontent.com/wavefrontHQ/homebrew-wavefront/master/sh/install.sh | bash -s -- -p -t WAVEFRONT_API_TOKEN -u WAVEFRONT_URL/api -a

curl -sL https://raw.githubusercontent.com/wavefrontHQ/homebrew-wavefront/master/sh/install.sh | bash -s -- -p -cspAPIToken CSP_API_TOKEN -u WAVEFRONT_URL/api -a

curl -sL https://raw.githubusercontent.com/wavefrontHQ/homebrew-wavefront/master/sh/install.sh | bash -s -- -p -cspAppId CSP_APP_ID -cspAppSecret CSP_APP_SECRET -cspOrgId CSP_ORG_ID -u WAVEFRONT_URL/api -a

```


## Installation (via Homebrew)

Note: This option requires manually configuring the proxy and the telegraf agent (see Miscellaneous).

Install [Homebrew](https://brew.sh/) and then install the wavefront Tap:

```brew tap wavefrontHQ/wavefront```

Wavefront proxy: ```brew install wfproxy```  
Telegraf agent: ```brew install telegraf```  
Proxy and Telegraf agent: ```brew install wfproxy --with-telegraf```


## Miscellaneous
Start the proxy: ```brew services start wfproxy```  
Stop the proxy: ```brew services stop wfproxy```  
Start the telegraf agent: ```brew services start telegraf```  
Stop the telegraf agent: ```brew services stop telegraf```  

Proxy configuration file: ```/usr/local/etc/wavefront/wavefront-proxy/wavefront.conf```  
Telegraf configuration file: ```/usr/local/etc/telegraf.conf``` & ```/usr/local/etc/telegraf.d```

Proxy log file: ```/usr/local/var/log/wavefront/wavefront.log```   
Telegraf log file: ```/usr/local/var/log/telegraf.log```

## Uninstall
```
bash -c "$(curl -s https://raw.githubusercontent.com/wavefrontHQ/homebrew-wavefront/master/sh/uninstall.sh)"
```
