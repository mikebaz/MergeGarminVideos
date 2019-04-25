# MergeGarminVideos
A PowerShell script to merge Garmin GPS dashcam videos from a microSD card or folder into collected videos.

Right now, the locations are hard-coded instead of parameters.  I'll probably fix that at some point.  

This script uses [`mp4box`](https://gpac.wp.imt.fr/mp4box/), downloadable at https://gpac.wp.imt.fr/downloads/gpac-nightly-builds/.

There's nothing particularly Windows-specific in here per se - with some effort, it could probably made cross-platform, although realistically changing it to run on PowerShell Core on MacOS or Linux would probably involve enough changes to command execution that it's probably not reasonable to do it all in one version of the script.  The logic for determining files to combine would be consistent, though.
