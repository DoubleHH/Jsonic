//
//  ViewController.swift
//  JsonMagic
//
//  Created by DoubleHH on 2019/12/5.
//  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet var inputTv: NSTextView!
    @IBOutlet var outputTv: NSTextView!
    @IBOutlet weak var resultLb: NSTextField!
    @IBOutlet weak var nameTf: NSTextField!
    private var jsonic: Jsonic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jsonic = Jsonic.init(delegate: self)
        Swifty.findResult()
    }

    @IBAction func run(_ sender: NSButton) {
        guard nameTf.stringValue.count > 0 else {
            showResult(success: false, errorInfo: "Hey man, input your model name~")
            return
        }
        guard let text = inputTv.textStorage?.string, text.count > 0 else {
            showResult(success: false, errorInfo: "Hey man, input your json text~")
            return
        }
        jsonic.beginParse(text: text, modelName: nameTf.stringValue)
    }
    
    @IBAction func exportModel(_ sender: Any) {
        guard let content = jsonic.fullModelContext, let fileName = jsonic.swiftFileName() else {
            showResult(success: false, errorInfo: "Hey man, file content is nil~")
            return
        }
        FileUtil.saveToDisk(fileName: fileName, content: content)
    }
    
    private func showResult(success: Bool, errorInfo: String = "") {
        resultLb.textColor = success ? .cyan : .red
        resultLb.stringValue = success ? "Success ^_^" : "Error: \(errorInfo)"
    }
}

extension ViewController: JsonicDelegate {
    func jsonicDidFinished(success: Bool, error: Jsonic.JsonicError) {
        print(success, error)
        if success {
            outputTv.string = jsonic.modelText
        }
        showResult(success: success, errorInfo: "Error: \(error.description)")
    }
    
    func jsonicPreprocessJson(json: [String : Any]) -> [String : Any] {
        guard let errno = json["errno"], let errmsg = json["errmsg"] else { return json }
        let maybeDataKeys: [String] = ["data", "result"]
        for key in maybeDataKeys {
            if let jsonData = json[key] as? [String: Any] { return jsonData }
        }
        return json
    }
}

