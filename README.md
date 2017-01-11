# DOS batch file and UNIX shell script for Netatmo

## Description

Here, I would like to introduce Windows DOS batch file and UNIX shell script to retrieve data using Netatmo API.

## Requirement

- Netatmo and account

Please retrieve client id and client secret from "CREATE YOUR APP" of [https://dev.netatmo.com/](https://dev.netatmo.com/).

- curl : You can download from [https://curl.haxx.se/download.html](https://curl.haxx.se/download.html)

- jq : You can download from [https://stedolan.github.io/jq/download/](https://stedolan.github.io/jq/download/)

If you are a windows user, after download, put EXE file to a directory included in PATH.

## Usage

At first, please replace "#####" of "account.json" file to yours. "account.json" is as follows. Put "account.json" to the directory with bat and sh script.

```
{
    "client_id"    : "#####",
    "client_secret": "#####",
    "username"     : "#####",
    "password"     : "#####",
    "device_id"    : "#####"
}
```

client_id and client_secret can be got from Netatmo. username and password are for login to Netatmo. deviceID is MAC address of your Netatmo. It can be confirmed at setup page on Netatmo site after login. "account.json" can be used by both bat4netatmo.bat and sh4netatmo.sh.

**In the case of windows dos,**

```
> bat4netatmo.bat
```

**In the case of unix bash,**

```
$ sh sh4netatmo.sh
```

Both scripts display following results.

```
Indoor: Temperature 12 [degree C], Humidity 56 [%], Pressure 1000.2 [hPa]
Outdoor: Temperature 12.3 [degree C], Humidity 56 [%]
```

## Appendix

If you want to use One Liner Code, you can use following code. Please replace "#####" to yours.

### windows dos

```
> setlocal & curl -s -d "grant_type=password&client_id='#####'&client_secret='#####'&username='#####'&password='#####'&scope=read_station" "https://api.netatmo.net/oauth2/token" | for /f "usebackq tokens=*" %a in (`jq -r ".access_token"`) do @set a="%a" | curl -s -d "access_token=%a&device_id='#####'" "https://api.netatmo.net/api/getstationsdata" > dat.txt & for /f "usebackq tokens=*" %b in (`jq -r ".body.devices[0].dashboard_data.Temperature" dat.txt`) do @set b="%b" | echo: & set /p nb=Indoor: Temperature %b [degree C],<nul & for /f "usebackq tokens=*" %b in (`jq -r ".body.devices[0].dashboard_data.Humidity" dat.txt`) do @set b="%b" | set /p nb=Humidity %b [%],<nul & for /f "usebackq tokens=*" %b in (`jq -r ".body.devices[0].dashboard_data.Pressure" dat.txt`) do @set b="%b" | set /p nb=Pressure %b [hPa]<nul & for /f "usebackq tokens=*" %b in (`jq -r ".body.devices[0].modules[0].dashboard_data.Temperature" dat.txt`) do @set b="%b" | echo: & set /p nb=Outdoor: Temperature %b [degree C],<nul & for /f "usebackq tokens=*" %b in (`jq -r ".body.devices[0].modules[0].dashboard_data.Humidity" dat.txt`) do @set b="%b" | set /p nb=Humidity %b [%]<nul & del dat.txt

Indoor: Temperature 12 [degree C],  Humidity 56 [%],  Pressure 1000.2 [hPa]
Outdoor: Temperature 12.3 [degree C],  Humidity 56 [%]
```

### unix bash

```
$ curl -s -d "grant_type=password&client_id='#####'&client_secret='#####'&username='#####'&password='#####'&scope=read_station" "https://api.netatmo.net/oauth2/token"|curl -s -d "access_token=`jq -r '.access_token'`&device_id='#####'" "https://api.netatmo.net/api/getstationsdata"|jq -r '"\nIndoor: Temperature "+(.body.devices[0].dashboard_data.Temperature|tostring)+" [degree C], Humidity "+(.body.devices[0].dashboard_data.Humidity|tostring)+" [%], Pressure "+(.body.devices[0].dashboard_data.Pressure|tostring)+" [hPa]\nOutdoor: Temperature "+(.body.devices[0].modules[0].dashboard_data.Temperature|tostring)+" [degree C], Humidity "+(.body.devices[0].modules[0].dashboard_data.Humidity|tostring)+" [%]"'

Indoor: Temperature 12 [degree C], Humidity 56 [%], Pressure 1000.2 [hPa]
Outdoor: Temperature 12.3 [degree C], Humidity 56 [%]
```


## Licence

[MIT](LICENCE)

## Author

[TANAIKE](https://github.com/tanaikech)

If this article is useful for you, I'm glad.
