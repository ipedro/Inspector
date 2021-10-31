//  Copyright (c) 2021 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Down
import Inspector
import SafariServices
import UIKit
import WebKit

final class ReadMeViewController: UIViewController {
    // MARK: - Components

    @IBOutlet var inspectBarButton: CustomButton!

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.color = view.tintColor
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(activityIndicatorView)

        [
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ].forEach {
            $0.isActive = true
        }

        return activityIndicatorView
    }()

    private lazy var markdownView: DownView = try! DownView(
        frame: view.bounds,
        markdownString: markdown?.markdownString ?? "",
        openLinksInBrowser: false,
        templateBundle: nil,
        writableBundle: false,
        configuration: nil,
        options: .smart,
        didLoadSuccessfully: { [weak self] in
            guard let self = self else { return }
            self.activityIndicatorView.stopAnimating()

            self.markdownView.translatesAutoresizingMaskIntoConstraints = false
            self.markdownView.alpha = 0
            self.markdownView.pageZoom = 1.5
            self.markdownView.navigationDelegate = self
            self.markdownView.backgroundColor = .clear
            self.markdownView.scrollView.backgroundColor = .clear

            self.view.insertSubview(self.markdownView, at: 0)

            [self.markdownView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
             self.markdownView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
             self.markdownView.topAnchor.constraint(equalTo: self.view.topAnchor),
             self.markdownView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
             self.markdownView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)].forEach {
                $0.isActive = true
            }

            UIView.animate(withDuration: 0.5) {
                self.markdownView.alpha = 1
            }
        }
    )

    private var markdown: Down? {
        didSet {
            guard let markdownString = markdown?.markdownString else { return }

            try? self.markdownView.update(markdownString: markdownString, options: .smart)
        }
    }

    override var keyCommands: [UIKeyCommand]? { Inspector.keyCommands }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true

        loadData()
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        parent?.overrideUserInterfaceStyle = .light
    }

    @objc func loadData() {
        activityIndicatorView.startAnimating()

        let session = URLSession(configuration: .default)

        let url = URL(string: "https://raw.githubusercontent.com/ipedro/Inspector/develop/README.md")!

        let task = session.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self else { return }

            guard
                let data = data,
                let markdownString = String(data: data, encoding: String.Encoding.utf8)?.replacingOccurrences(of: "# 🕵🏽‍♂️ Inspector\n", with: "")
            else {
                self.activityIndicatorView.stopAnimating()
                return
            }

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                self.markdown = Down(markdownString: markdownString)
            }
        }

        task.resume()
    }
}

extension ReadMeViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView,
                        decidePolicyFor navigationAction: WKNavigationAction,
                        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        guard let url = navigationAction.request.url else { return decisionHandler(.allow) }

        switch (url.scheme, navigationAction.navigationType) {
        case ("https", .linkActivated):
            decisionHandler(.cancel)
            openInSafariViewController(url)

        default:
            decisionHandler(.allow)
        }
    }

    private func openInSafariViewController(_ url: URL?) {
        guard let url = url else { return }

        let configuration = SFSafariViewController.Configuration()
        configuration.barCollapsingEnabled = false

        let safariController = SFSafariViewController(url: url, configuration: configuration)
        safariController.preferredControlTintColor = view.tintColor

        present(safariController, animated: true, completion: nil)
    }
}
