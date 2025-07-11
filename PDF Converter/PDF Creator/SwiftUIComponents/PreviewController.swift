import SwiftUI
import QuickLook

struct PreviewController: UIViewControllerRepresentable {
    let url: URL
    @Binding var isPresented: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator

        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: context.coordinator,
            action: #selector(Coordinator.dismiss)
        )

        let navController = UINavigationController(rootViewController: controller)
        return navController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}

    class Coordinator: NSObject, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
        let parent: PreviewController

        init(parent: PreviewController) {
            self.parent = parent
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return parent.url as NSURL
        }

        @objc func dismiss() {
            parent.isPresented = false
        }
    }
}
