#! /bin/sh
set +x
accountfile="account.json"
client_id=`jq -r ".client_id" $accountfile`
client_secret=`jq -r ".client_secret" $accountfile`
username=`jq -r ".username" $accountfile`
password=`jq -r ".password" $accountfile`
device_id=`jq -r ".device_id" $accountfile`
authurl="https://api.netatmo.net/oauth2/token"
tokenfile="token.json"
datafile="data.json"

if [ ! -f $tokenfile ]; then
    echo "Get new access token"
    curl -s -d "grant_type=password&client_id=${client_id}&client_secret=${client_secret}&username=${username}&password=${password}&scope=read_station" "${authurl}" > ${tokenfile}
fi
atoken=`jq -r ".access_token" $tokenfile`
rtoken=`jq -r ".refresh_token" $tokenfile`
expiration=`jq -r ".expires_in" $tokenfile`

filedate=`date +%Y-%m-%d_%H:%M:%S -r $tokenfile`
filedate=${filedate/_/ }
filedate=`date -d "$filedate" +%s`
limittime=`expr $filedate + $expiration`
currenttime=`date +%s`

if [ $limittime -lt $currenttime ]; then
    echo "Using refresh token"
    curl -s -d "grant_type=refresh_token&refresh_token=${rtoken}&client_id=${client_id}&client_secret=${client_secret}" "${authurl}" > $tokenfile
    atoken=`jq -r ".access_token" $tokenfile`
fi

curl -s -d "access_token=${atoken}&device_id=${device_id}" "https://api.netatmo.net/api/getstationsdata" > $datafile
intemp=`jq -r ".body.devices[0].dashboard_data.Temperature" $datafile`
inhumi=`jq -r ".body.devices[0].dashboard_data.Humidity" $datafile`
pres=`jq -r ".body.devices[0].dashboard_data.Pressure" $datafile`
echo "Indoor: Temperature $intemp [degree C], Humidity $inhumi [%], Pressure $pres [hPa]"
extemp=`jq -r ".body.devices[0].modules[0].dashboard_data.Temperature" $datafile`
exhumi=`jq -r ".body.devices[0].modules[0].dashboard_data.Humidity" $datafile`
echo "Outdoor: Temperature $extemp [degree C], Humidity $exhumi [%]"
