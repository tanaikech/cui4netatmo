@echo off
setlocal
set accountfile="account.json"
for /f "usebackq tokens=*" %%a in (`jq -r ".client_id" %accountfile%`) do @set client_id=%%a
for /f "usebackq tokens=*" %%a in (`jq -r ".client_secret" %accountfile%`) do @set client_secret=%%a
for /f "usebackq tokens=*" %%a in (`jq -r ".username" %accountfile%`) do @set username=%%a
for /f "usebackq tokens=*" %%a in (`jq -r ".password" %accountfile%`) do @set password=%%a
for /f "usebackq tokens=*" %%a in (`jq -r ".device_id" %accountfile%`) do @set device_id=%%a
set authurl="https://api.netatmo.net/oauth2/token"
set tokenfile="token.json"
set datafile="data.json"

if not exist %tokenfile% (
    echo Get new access token
    curl -s -d "grant_type=password&client_id=%client_id%&client_secret=%client_secret%&username=%username%&password=%password%&scope=read_station" "%authurl%" > %tokenfile%
)
for /f "usebackq tokens=*" %%a in (`jq -r ".access_token" %tokenfile%`) do @set atoken=%%a
for /f "usebackq tokens=*" %%a in (`jq -r ".refresh_token" %tokenfile%`) do @set rtoken=%%a
for /f "usebackq tokens=*" %%a in (`jq -r ".expires_in" %tokenfile%`) do @set expiration=%%a

for %%i in (%tokenfile%) do @set tokent=%%~ti
set y1=%tokent:~0,4%
set /a m1=1%tokent:~5,2%-100
set /a d1=1%tokent:~8,2%-100
set /a j1=1%tokent:~11,2%-100
set /a f1=1%tokent:~14,2%-100
set b1=0
call :ConvUnixTime %y1% %m1% %d1% %j1% %f1% %b1%
set /a limittime=%UT%+%expiration%
set y2=%date:~0,4%
set /a m2=1%date:~5,2%-100
set /a d2=1%date:~8,2%-100
set /a j2=1%time:~0,2%-100
set /a f2=1%time:~3,2%-100
set b2=0
call :ConvUnixTime %y2% %m2% %d2% %j2% %f2% %b2%
set currenttime=%UT%

if %limittime% lss %currenttime% (
    echo Using refresh token
    curl -s -d "grant_type=refresh_token&refresh_token=%rtoken%&client_id=%client_id%&client_secret=%client_secret%" "%authurl%" > %tokenfile%
    for /f "usebackq tokens=*" %%a in (`jq -r ".access_token" %tokenfile%`) do @set atoken=%%a
)

curl -s -d "access_token=%atoken%&device_id=%device_id%" "https://api.netatmo.net/api/getstationsdata" > %datafile%
for /f "usebackq tokens=*" %%a in (`jq -r ".body.devices[0].dashboard_data.Temperature" %datafile%`) do @set intemp=%%a
for /f "usebackq tokens=*" %%a in (`jq -r ".body.devices[0].dashboard_data.Humidity" %datafile%`) do @set inhumi=%%a
for /f "usebackq tokens=*" %%a in (`jq -r ".body.devices[0].dashboard_data.Pressure" %datafile%`) do @set pres=%%a
echo Indoor: Temperature %intemp% [degree C], Humidity %inhumi% [%%], Pressure %pres% [hPa]
for /f "usebackq tokens=*" %%a in (`jq -r ".body.devices[0].modules[0].dashboard_data.Temperature" %datafile%`) do @set extemp=%%a
for /f "usebackq tokens=*" %%a in (`jq -r ".body.devices[0].modules[0].dashboard_data.Humidity" %datafile%`) do @set exhumi=%%a
echo Outdoor: Temperature %extemp% [degree C], Humidity %exhumi% [%%]
goto :EOF

:ConvUnixTime
set y=%1
set m=%2
set d=%3
set j=%4
set f=%5
set b=%6
set /a utime=86400*(365*%y%+(%y%/4)-(%y%/100)+(%y%/400)+(306*(%m%+1)/10)-428+%d%-719161)+3600*%j%+60*%f%+%b%-(9*3600)
set "UT=%utime%"
goto :EOF
