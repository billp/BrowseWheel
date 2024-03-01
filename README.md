
# BrowseWheel

An interactive, SwiftUI-based Carousel View designed for seamless browsing of dynamic content, featuring customizable item spacing, padding, and scale effects.

## Features

- **Dynamic Content Support**: Easily display any array of data.
- **Customizable Appearance**: Adjust item spacing, padding, and minimum scale factor for non-central items.
- **Swipe Gestures**: Intuitive navigation through swipe gestures.
- **Responsive Design**: Adapts smoothly to various device sizes and orientations.
- **State-Bound Page Index**: Programmatically control the carousel's current page.

https://github.com/billp/BrowseWheel/assets/1566052/72f7eab8-e434-4f09-a4f0-0b3a5306e222

## Installation

### Swift Package Manager

Go to **File** > **Swift Packages** > **Add Package Dependency** and add the following URL :
```
https://github.com/billp/BrowseWheel
```

## Usage

Here's a quick start guide to integrate the BrowseWheel into your SwiftUI app:

```swift
import SwiftUI

struct ContentView: View {
    let items: [YourItemType] = [...]

    @State private var page = 0

    var body: some View {
        CarouselView(
          items: items,
          page: $page,
          spacing: .constant(-80),
          padding: .constant(50),
          minScale: .constant(0.6),
          itemsOffset: .constant(-50)) { item in
              YourItemView(item: item)
          }
    }
}
```

## Customization

- `spacing`: The gap between items.
- `padding`: The padding around each item.
- `minScale`: Scale of items on the sides.

## Contributing

Contributions are welcome! Please fork this repository and submit a pull request with your enhancements.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

