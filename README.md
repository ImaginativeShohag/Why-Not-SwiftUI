# Why Not SwiftUI!

A collection of Swift, SwiftUI and iOS goodies.

Feel free to request features or suggestions for improvements.

[![Developer](https://img.shields.io/badge/Maintainer-ImaginativeShohag-green)](https://github.com/ImaginativeShohag)

## What we have hare!

### Jailbroken checker

Check for device is jail-broken status.

<p style="text-align:center">
<img src="images/jailbroken-checker.png" width=250/>
</p>

### Notification

Example for showing local notifications.

<p style="text-align:center">
<img src="images/sample-notification.png" width=250>
</p>

### Accessibility Example

Example of common accessibility modifiers.

### Bottom Nav vs Side Bar

A simple example to demonstrate separate views for iPhone and iPad. Users will see the bottom nav on iPhone and Sidebar on iPad.

| <img src="images/bottom-nav.png" width=165/> | <img src="images/side-bar.png" width=250/> |
| :-: | :-: |

### Component: `CoolProgress`

<p style="text-align:center">
<img src="images/cool-progress.gif" width=250/>
</p>

### Component: `CoolToast`

A cool "Android Toast" like implementation for SwiftUI.

<p style="text-align:center">
<img src="images/cool-toast.gif" width=250/>
</p>

### Component: `ImageViewCapturer`: Media Capture & Select Example

Example for capturing image, recording video and selecting media from library.

<p style="text-align:center">
<img src="images/media-capture-select.gif" width=250/>
</p>

### Component: `LabelToggle`

A custom Toggle like component with inside label support.

<p style="text-align:center">
<img src="images/label-toggle.gif" width=250/>
</p>

### MetricKit crash report example

On going...

### Component: `NativeAlert`

SwiftUI modifier for `UIAlertController`. This is created to be able to change the Alert button colors.

<p style="text-align:center">
<img src="images/native-alert.gif" width=250/>
</p>

### Component: `RingChart`

<p style="text-align:center">
<img src="images/ring-chart.gif" width=250/>
</p>

### Component: `CustomTextFieldView` with validation example

<p style="text-align:center">
<img src="images/custom-text-field.gif" width=250/>
</p>

### Typography: Custom Font

Add fonts to the [project](https://github.com/ImaginativeShohag/Why-Not-SwiftUI/tree/main/Why%20Not%20SwiftUI/Resources/Fonts), add the fonts name to the [plist](https://github.com/ImaginativeShohag/Why-Not-SwiftUI/blob/main/Why-Not-SwiftUI-Info.plist) file. Finally, use [`fontStyle(size:weight:)`](https://github.com/ImaginativeShohag/Why-Not-SwiftUI/blob/main/Why%20Not%20SwiftUI/Utils/Typography.swift) to set fonts.

<p style="text-align:center">
<img src="images/typography.png" width=250/>
</p>

## Others

- Example to create preview with mock Models and ViewModels (`ObservableObject`). (See **Media Capture & Select** Example)

## TODO

- [ ] MetricKit crash report example (WIP)
- [ ] Full app custom font
- [ ] Custom Sidebar: Finalize it (WIP)
- [ ] Custom Build variant
- [ ] Add documentation to the extensions
- [ ] Moya finalize
- [ ] Home list multiple accent color

## Extensions

### `String` (`String+.swift`)

- `md5()`
- `fileName()`
- `fileExtension()`
- `isValidEmail()`
- `isBlank()`

### `Array` (`Array+.swift`)

- `commaSeparatedString(emptyValue:) -> String` : Combine string array separated by a comma.

### `UIImage` (`UIImage+.swift`)

- `fileSize() -> Int` : The file size in KB.

### `URL` (`URL+.swift`)

- `fileSize() -> Int` : The file size in KB.

## Licence

```
Copyright 2021 Md. Mahmudul Hasan Shohagm

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```