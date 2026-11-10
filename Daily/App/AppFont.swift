import SwiftUI

enum AppFont {
    static let largeTitle = Font.custom("EBGaramond-Bold", size: 38,
                                       relativeTo: .largeTitle)
    static let heading = Font.custom("EBGaramond-Bold", size: 28,
                                    relativeTo: .title2)
    static let title = Font.custom("EBGaramond-Regular", size: 26,
                                  relativeTo: .title2)
    static let primary = Font.custom("EBGaramond-Regular", size: 24,
                                    relativeTo: .title3)
    static let body = Font.custom("EBGaramond-Regular", size: 22,
                                 relativeTo: .body)
    static let secondary = Font.custom("EBGaramond-Regular", size: 19,
                                      relativeTo: .subheadline)
    static let caption = Font.custom("EBGaramond-Regular", size: 16,
                                    relativeTo: .caption)
    static let captionBold = Font.custom("EBGaramond-Bold", size: 16,
                                        relativeTo: .caption)
}
