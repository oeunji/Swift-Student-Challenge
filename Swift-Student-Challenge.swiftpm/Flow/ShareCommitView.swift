//
//  ShareCommitView.swift
//  Swift-Student-Challenge
//
//  Created by 이은지 on 2/23/26.
//

import SwiftUI
import UIKit

struct ShareCommitView: View {

    let normalBefore: UIImage
    let normalAfter: UIImage
    let simulatedBefore: UIImage
    let simulatedAfter: UIImage

    let visionModeName: String
    let patternName: String
    let intensity: CGFloat
    let contrastRatio: Double

    @State private var exportBundle: ExportBundle?
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []

    private let exportService = ExportService()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text("Share / Commit")
                    .font(.system(size: 28, weight: .bold, design: .rounded))

                Text("Export a summary image and an accessibility report.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let exportBundle {
                    VStack(spacing: 12) {
                        Text("Summary")
                            .font(.headline)
                        Image(uiImage: exportBundle.summaryImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                        Text("Report")
                            .font(.headline)
                        Image(uiImage: exportBundle.reportImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .padding(12)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                } else {
                    Text("Generating exports…")
                        .foregroundStyle(.secondary)
                }

                Button {
                    guard let bundle = exportBundle else { return }
                    shareItems = [bundle.summaryImage, bundle.reportImage]
                    showShareSheet = true
                } label: {
                    Text("Share Summary + Report")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity, minHeight: 54)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(16)
        }
        .navigationTitle("Share / Commit")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet) {
            ActivityView(items: shareItems)
        }
        .onAppear {
            let summary = exportService.makeSummaryGrid(
                normalBefore: normalBefore,
                normalAfter: normalAfter,
                simulatedBefore: simulatedBefore,
                simulatedAfter: simulatedAfter
            )

            let report = exportService.makeReportCard(
                visionModeName: visionModeName,
                patternName: patternName,
                intensity: intensity,
                contrastRatio: contrastRatio
            )

            exportBundle = ExportBundle(summaryImage: summary, reportImage: report)
        }
    }
}
