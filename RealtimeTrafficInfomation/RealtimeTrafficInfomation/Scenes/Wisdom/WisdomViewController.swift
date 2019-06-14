//
//  WisdomViewController.swift
//  RealtimeTrafficInfomation
//
//  Created by justin on 2019/6/6.
//  Copyright (c) 2019 jlai. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import SDWebImage

protocol WisdomDisplayLogic: class {
    func displayOldQuote(viewModel:Wisdom.WisdomEvent.cachequote)
    func displayQuoteSuccess(viewModel: Wisdom.WisdomEvent.ViewModel)
    func displayQuoteFailed(viewMode: Wisdom.WisdomEvent.ViewModel)
}

class WisdomViewController: UIViewController {
    var interactor: WisdomBusinessLogic?
    var router: (NSObjectProtocol & WisdomRoutingLogic & WisdomDataPassing)?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var otherLabel: UILabel!
    
    // MARK: Object lifecycle
  
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
  
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
  
    // MARK: Setup

    private func setup() {
        let viewController = self
        let interactor = WisdomInteractor()
        let presenter = WisdomPresenter()
        let router = WisdomRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
  
  // MARK: Routing
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
  
    // MARK: View lifecycle
  
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        interactor?.show()
    }
    
    func showView(quote: Quote) {
        titleLabel.text = quote.title
        quoteLabel.text = quote.text
        otherLabel.text = "Author: \(quote.author)\nDate: \(quote.date)\nCopyright: \(quote.copyright)"
        imageView.sd_setImage(with: URL(string: quote.image), placeholderImage: UIImage(named: "defaultWisdom"))
    }
    
    func showFailedView(msg: String) {
        quoteLabel.text = msg
    }

}

extension WisdomViewController: WisdomDisplayLogic {
    func displayOldQuote(viewModel: Wisdom.WisdomEvent.cachequote) {
        if let quote = viewModel.quote {
            showView(quote: quote)
        }
    }
    
    func displayQuoteSuccess(viewModel: Wisdom.WisdomEvent.ViewModel) {
        if let quote = viewModel.quote {
            showView(quote: quote)
        } else {
            showFailedView(msg: "can't find quote")
        }
    }
    
    func displayQuoteFailed(viewMode: Wisdom.WisdomEvent.ViewModel) {
        showFailedView(msg: viewMode.errorMsg ?? "can't fetch quote from server")
    }
}
