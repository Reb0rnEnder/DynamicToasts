NOTE: Made in mind for Dynamic
# DynamicToasts
## Usage
Example:
```luau
local DynamicToasts = loadstring(game:HttpGet("https://raw.githubusercontent.com/Reb0rnEnder/DynamicToasts/main/module.luau"))()()

DynamicToasts:NewToast(DynamicToasts.ToastType.Info, "Example Title", "Example Description", 5)
```
Usage:
```luau
function NewToast(self, ToastType: number?, ToastTitle: string?, ToastDescription: string?, Duration: number?)
```
