![version](https://img.shields.io/badge/version-15%2B-D74635)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20win-64&color=blue)
![deprecated](https://img.shields.io/badge/-deprecated-inactive)

# 4d-utility-restarter
Command line program to restart 4D

### Example

```
$path:=LEP_Escape_path (Get 4D folder(Database folder)+"restarter")
$path:=$path+" -a "+LEP_Escape (Application file)
$path:=$path+" -s "+LEP_Escape (Structure file(*))
$path:=$path+" -d "+LEP_Escape (Data file)

SET ENVIRONMENT VARIABLE("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS";"false")

LAUNCH EXTERNAL PROCESS($path)

If (Application type=4D Server)
QUIT 4D(0)
End if 
```

* For macOS 10.8 or later.

* By default, the timeout is ``180`` seconds. Pass the optional ``-t`` option for alternative settings.

* The application, structure and data paths should all be exprtessed in HFS format, not POSIX.

* Sample implementation for ``LEP_Escape`` 

```
C_TEXT($1;$0;$param)

If (Count parameters#0)

$param:=$1

C_LONGINT($platform;$i;$len)
PLATFORM PROPERTIES($platform)

If ($platform=Windows)

  //argument escape for cmd.exe; other commands (curl, ruby, etc.) may be incompatible

$shoudQuote:=False

$metacharacters:="&|<>()%^\" "

$len:=Length($metacharacters)

For ($i;1;$len)
$metacharacter:=Substring($metacharacters;$i;1)
$shoudQuote:=$shoudQuote | (Position($metacharacter;$param;*)#0)
If ($shoudQuote)
$i:=$len
End if 
End for 

If ($shoudQuote)
If (Substring($param;Length($param))="\\")
$param:="\""+$param+"\\\""
Else 
$param:="\""+$param+"\""
End if 
End if 

Else 

$metacharacters:="\\!\"#$%&'()=~|<>?;*`[] "

For ($i;1;Length($metacharacters))
$metacharacter:=Substring($metacharacters;$i;1)
$param:=Replace string($param;$metacharacter;"\\"+$metacharacter;*)
End for 

End if 

End if 

$0:=$param
```
