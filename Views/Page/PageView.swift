/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view for bridging a UIPageViewController.
*/

import SwiftUI

struct PageView<Page: View>: View {
    var pages: [Page]
    @Binding var currentPage: Int

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            PageViewController(pages: pages, currentPage: $currentPage)
            PageControl(numberOfPages: pages.count, currentPage: $currentPage)
                .frame(width: CGFloat(pages.count * 18))
                .padding(.trailing)
        }
    }
}

struct PageView_Previews: PreviewProvider {
    @State static var current_page: Int = 0
    static var previews: some View {
        PageView(pages: [ExpenditureView()], currentPage: $current_page)
            .aspectRatio(3 / 2, contentMode: .fit)
    }
}
