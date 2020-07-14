//
//  CustomAnnotationView.swift
//  MapAndLocationManager
//
//  Created by Shawn Li on 7/6/20.
//

import UIKit

class CustomAnnotationView: UIView {

    @IBOutlet var callOutView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var displayLabel: UILabel!
    var displayCoordinateHandler: (()->())?
    var displayAddressHandler:(()->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }
    
    private func customInit() {
        Bundle.main.loadNibNamed("CustomAnnotationView", owner: self, options: nil)
        addSubview(callOutView)
        callOutView.frame = self.bounds
        callOutView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    @IBAction func displayCoordinateClicked(_ sender: UIButton) {
        self.displayCoordinateHandler?()
    }
    
    @IBAction func displayAddressClicked(_ sender: UIButton) {
        self.displayAddressHandler?()
    }
    
}
