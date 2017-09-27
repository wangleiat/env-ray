#!/bin/bash
userName=""
passWord=""
ipAddr=""

expect -c "
spawn ssh $userName@$ipAddr
expect {
	\"*password:\"  { send -- \"$passWord\r\"; interact}
	\"*yes/no\" {send \"yes\r\"; exp_continue }
}
"
