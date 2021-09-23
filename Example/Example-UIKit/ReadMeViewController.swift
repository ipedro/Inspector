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

        view.insertSubview(activityIndicatorView, aboveSubview: markdownView)

        [
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ].forEach {
            $0.isActive = true
        }

        return activityIndicatorView
    }()

    private lazy var markdownView: DownView = {
        guard let markdownView = try? DownView(frame: .zero, markdownString: "") else { fatalError() }
        markdownView.translatesAutoresizingMaskIntoConstraints = false
        markdownView.alpha = 0
        markdownView.navigationDelegate = self
        markdownView.pageZoom = 1.5
        markdownView.backgroundColor = .clear
        markdownView.scrollView.backgroundColor = .clear

        view.addSubview(markdownView)

        [markdownView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
         markdownView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
         markdownView.topAnchor.constraint(equalTo: view.topAnchor),
         markdownView.trailingAnchor.constraint(equalTo: view.trailingAnchor)].forEach {
            $0.priority = .defaultHigh
            $0.isActive = true
        }

        return markdownView
    }()

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

        activityIndicatorView.startAnimating()
    }

    private var isFirstAppear = true

    private func doOnFirstAppear(closure: () -> Void) {
        guard isFirstAppear else { return }
        isFirstAppear = false

        closure()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        doOnFirstAppear { [weak self] in
            self?.loadData()
        }
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
            guard
                let markdownString = String(data: data!, encoding: String.Encoding.utf8)?.replacingOccurrences(of: "# 🕵🏽‍♂️ Inspector\n", with: "")
            else { return }

            DispatchQueue.main.async {
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

        case ("file", .linkActivated):
            decisionHandler(.cancel)
            guard let anchor = url.fragment?.replacingOccurrences(of: "-", with: " ") else { return }

            let javascript = """
                var h2 = document.getElementsByTagName('h2');
                var h3 = document.getElementsByTagName('h3');
                var h4 = document.getElementsByTagName('h4');

                var success = false

                for (var idx = h2.length -1; idx >= 0; idx--) {
                    if (typeof h2.item(idx).text === 'string', h2.item(idx).text.toLowerCase().includes('\(anchor)'.toLowerCase())) {
                        h2.item(idx).offsetTop;
                        success = true;
                        break;
                    }
                }

                if (!success) {
                    for (var idx = h3.length -1; idx >= 0; idx--) {
                        if (typeof h3.item(idx).text === 'string', h3.item(idx).text.toLowerCase().includes('\(anchor)'.toLowerCase())) {
                            h3.item(idx).offsetTop;
                            success = true;
                            break;
                        }
                    }
                }

                if (!success) {
                    for (var idx = h4.length -1; idx >= 0; idx--) {
                        if (typeof h4.item(idx).text === 'string', h4.item(idx).text.toLowerCase().includes('\(anchor)'.toLowerCase())) {
                            h4.item(idx).offsetTop;
                            success = true;
                            break;
                        }
                    }
                }
            """

            webView.evaluateJavaScript(javascript) { result, _ in
                if let offset = result as? CGFloat {
                    webView.scrollView.scrollRectToVisible(CGRect(x: 0, y: -offset, width: webView.frame.width, height: webView.frame.height / 2), animated: true)
                }
            }

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

    func updateNavigationBarSize() {
        navigationController?.navigationBar.sizeToFit()
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        updateNavigationBarSize()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicatorView.stopAnimating()

        UIView.animate(.quickly) {
            self.updateNavigationBarSize()
            webView.alpha = 1
        }
    }
}
