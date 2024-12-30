//
//  WidgetVPNLiveActivity.swift
//  WidgetVPN
//
//  Created by Nikita Molodorya on 30.12.2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct WidgetVPNAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct WidgetVPNLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WidgetVPNAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension WidgetVPNAttributes {
    fileprivate static var preview: WidgetVPNAttributes {
        WidgetVPNAttributes(name: "World")
    }
}

extension WidgetVPNAttributes.ContentState {
    fileprivate static var smiley: WidgetVPNAttributes.ContentState {
        WidgetVPNAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: WidgetVPNAttributes.ContentState {
         WidgetVPNAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: WidgetVPNAttributes.preview) {
   WidgetVPNLiveActivity()
} contentStates: {
    WidgetVPNAttributes.ContentState.smiley
    WidgetVPNAttributes.ContentState.starEyes
}
