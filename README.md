NOTE: Made in mind for Dynamic
# DynamicToasts
## Usage
Example:
```luau
local DynamicToasts = loadstring("https://raw.githubusercontent.com/Reb0rnEnder/DynamicToasts/refs/heads/main/module.luau")()

DynamicToasts:NewToast(DynamicToasts.ToastType.Info, "Example Title", "Example Description", 5)
```
Usage:
```luau
function NewToast(self, ToastType: number?, ToastTitle: string?, ToastDescription: string?, Duration: number?)
```
