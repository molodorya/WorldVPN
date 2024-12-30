//
//  WidgetVPNBundle.swift
//  WidgetVPN
//
//  Created by Nikita Molodorya on 30.12.2024.
//

import WidgetKit
import SwiftUI

@main
struct WidgetVPNBundle: WidgetBundle {
    var body: some Widget {
        WidgetVPN()
        WidgetVPNControl()
        WidgetVPNLiveActivity()
    }
}
