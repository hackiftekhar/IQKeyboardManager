//
//  NonScrollTextView1979ViewController.swift
//  DemoSwift
//
//  Created by Iftekhar on 10/15/23.
//  Copyright © 2023 Iftekhar. All rights reserved.
//

import UIKit

class NonScrollTextView1979ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        setupForStackView(in: scrollView)
//        setupForView(in: scrollView)
    }

    private func setupForStackView(in scrollView: UIScrollView) {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.axis = .vertical
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
        ])

        for index in 1...8 {
            let textView = UITextView()
            textView.text = "\(index)"
            textView.backgroundColor = .lightGray
            textView.textColor = UIColor.black
            textView.isEditable = true
            // if set isScrollEnabled to true, it works fine
            textView.isScrollEnabled = false
            stackView.addArrangedSubview(textView)
            textView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textView.heightAnchor.constraint(equalToConstant: 500)
            ])
        }
    }

    private func setupForView(in scrollView: UIScrollView) {
        let eachHeight: CGFloat = 600
        let gap: CGFloat = 10
        let stackView = UIView()
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: (eachHeight + gap) * 8),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
        ])

        for index in 1...8 {
            let textView = UITextView()
            textView.text = "\(index)"
            textView.backgroundColor = .lightGray
            textView.textColor = UIColor.black
            textView.isEditable = true
            // if set isScrollEnabled to true, it works fine
            textView.isScrollEnabled = false
            stackView.addSubview(textView)
            textView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: (eachHeight + gap) * CGFloat(index-1)),
                textView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
                textView.heightAnchor.constraint(equalToConstant: eachHeight)
            ])
        }
    }
}
