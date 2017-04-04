# 4d-utility-restarter
Command line program to restart 4D

| carbon | cocoa | win32 | win64 |
|:------:|:-----:|:---------:|:---------:|
|<img src="https://cloud.githubusercontent.com/assets/1725068/22371562/1b091f0a-e4db-11e6-8458-8653954a7cce.png" width="24" height="24" />|<img src="https://cloud.githubusercontent.com/assets/1725068/22371562/1b091f0a-e4db-11e6-8458-8653954a7cce.png" width="24" height="24" />|||

### Version

<img src="https://cloud.githubusercontent.com/assets/1725068/18940649/21945000-8645-11e6-86ed-4a0f800e5a73.png" width="32" height="32" /> <img src="https://cloud.githubusercontent.com/assets/1725068/18940648/2192ddba-8645-11e6-864d-6d5692d55717.png" width="32" height="32" />


### Example

```
$path:="restarter"
$path:=$path+" -a "+LEP_Escape (Application file)
$path:=$path+" -s "+LEP_Escape (Structure file(*))
$path:=$path+" -d "+LEP_Escape (Data file)

SET ENVIRONMENT VARIABLE("_4D_OPTION_CURRENT_DIRECTORY";Get 4D folder(Database folder))
SET ENVIRONMENT VARIABLE("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS";"false")

LAUNCH EXTERNAL PROCESS($path)
```

* For macOS 10.10 or later.

* By default, the timeout is ``180`` seconds. Pass the optional ``-t`` option for alternative settings.

* The application, structure and data paths should all be exprtessed in HFS format, not POSIX.
