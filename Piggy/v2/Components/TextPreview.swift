//
//  TextPreview.swift
//  Piggy
//
//  Created by Jerico Villaraza on 1/3/26.
//

import SwiftUI

struct TextStylePreview: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Group {
                    Text("largeTitle")
                        .font(.largeTitle)

                    Text("title")
                        .font(.title)

                    Text("title2")
                        .font(.title2)

                    Text("title3")
                        .font(.title3)
                }

                Divider()

                Group {
                    Text("headline")
                        .font(.headline)

                    Text("subheadline")
                        .font(.subheadline)
                }

                Divider()

                Group {
                    Text("body")
                        .font(.body)

                    Text("callout")
                        .font(.callout)
                }

                Divider()

                Group {
                    Text("footnote")
                        .font(.footnote)

                    Text("caption")
                        .font(.caption)

                    Text("caption2")
                        .font(.caption2)
                }
            }
            .padding()
        }
    }
}

#Preview {
    TextStylePreview()
}
