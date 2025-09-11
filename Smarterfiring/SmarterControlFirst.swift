import Foundation

import SwiftUI

@available(iOS 17.0, *)
class MagichostingmanageGG: UIHostingController<TinyGameView> {

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder, rootView: TinyGameView())
    }
}

