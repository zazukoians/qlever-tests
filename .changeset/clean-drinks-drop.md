---
"qlever": minor
---

Permissions were updated to make sure that the server and the UI can run without any issue with any user ID.
The persistent data is now stored in the `/data` directory.
Make sure to update your deployments/stacks to use the new path.
The default user is now `nobody` (UID: 65534).
