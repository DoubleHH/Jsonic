//
//  ViewController.swift
//  JsonMagic
//
//  Created by DoubleHH on 2019/12/5.
//  Copyright © 2019 Beijing SF Intra-city Technology Co., Ltd. All rights reserved.
//

import Cocoa

extension ViewController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        [inputTv, outputTv].forEach { tv in
            updateTextViewAttrs(tv: tv)
        }
    }
    
    private func updateTextViewAttrs(tv: NSTextView) {
        tv.textColor = NSColor.textColor
        tv.font = NSFont.init(name: "Monaco", size: 13)
    }
}

class ViewController: NSViewController {
    enum TransferType {
        case jsonToSwift, jsonToKotlin, kotlinToSwift
    }
    
    @IBOutlet var inputTv: NSTextView!
    @IBOutlet var outputTv: NSTextView!
    @IBOutlet weak var resultLb: NSTextField!
    @IBOutlet weak var nameTf: NSTextField!
    @IBOutlet weak var kotlinBtn: NSButton!
    @IBOutlet weak var jsonToSwiftBtn: NSButton!
    @IBOutlet weak var jsonToKotlinBtn: NSButton!
    private var jsonic: Jsonic!
    private var transferType = TransferType.jsonToSwift
    private var outputType: Jsonic.OutputType {
        switch transferType {
        case .jsonToKotlin:
            return .kotlin
        default:
            return .swift
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jsonic = Jsonic.init(delegate: self)
        inputTv.delegate = self
        outputTv.delegate = self
        updateTransferType()
    }

    @IBAction func run(_ sender: NSButton) {
        if kotlinBtn.state == .on {
            doSwifty()
        } else {
            doJsonic()
        }
        switch transferType {
        case .jsonToSwift:
            doJsonic()
        case .jsonToKotlin:
            print("")
        case .kotlinToSwift:
            doSwifty()
        }
    }
    
    @IBAction func radioClicked(_ sender: NSObject) {
        if kotlinBtn == sender {
            transferType = TransferType.kotlinToSwift
        } else if jsonToSwiftBtn == sender {
            transferType = TransferType.jsonToSwift
        } else if jsonToKotlinBtn == sender {
            transferType = TransferType.jsonToKotlin
        }
        updateTransferType()
    }
    
    private func updateTransferType() {
        [jsonToKotlinBtn, jsonToSwiftBtn, kotlinBtn].forEach({ $0?.state = .off })
        switch transferType {
        case .jsonToSwift:
            jsonToSwiftBtn.state = .on
        case .jsonToKotlin:
            jsonToKotlinBtn.state = .on
        case .kotlinToSwift:
            kotlinBtn.state = .on
        }
    }
    
    @discardableResult
    private func doSwifty() -> Bool {
        guard let text = inputTv.textStorage?.string, text.count > 0 else {
            showResult(success: false, info: "Hey man, input your Kotlin model text~")
            return false
        }
        let result = Swifty.modelFromKotlin(text: text)
        outputTv.string = result
        if result.isEmpty {
            showResult(success: false, info: "Error: transfer to swift failed")
            return false
        } else {
            showResult(success: true)
            return true
        }
    }
    
    private func doJsonic() {
        guard nameTf.stringValue.count > 0 else {
            showResult(success: false, info: "Hey man, input your model name~")
            return
        }
        guard let text = inputTv.textStorage?.string, text.count > 0 else {
            showResult(success: false, info: "Hey man, input your json text~")
            return
        }
        jsonic.beginParse(text: text, modelName: nameTf.stringValue)
    }
    
    @IBAction func exportModel(_ sender: Any) {
        if kotlinBtn.state == .on {
            if doSwifty() {
                FileUtil.saveToDisk(fileName: "export.swift", content: outputTv.string)
                showResult(success: true, info: " Swift file is exported into the folder which path is Desktop/models/ ")
            }
        } else {
            guard let content = jsonic.fullModelContext(outputType: outputType), let fileName = jsonic.fileName(outputType: outputType) else {
                showResult(success: false, info: "Hey man, file content is nil~")
                return
            }
            FileUtil.saveToDisk(fileName: fileName, content: content)
            showResult(success: true, info: " Swift file is exported into the folder which path is Desktop/models/ ")
        }
    }
    
    private func showResult(success: Bool, info: String = "") {
        resultLb.textColor = success ? .cyan : .red
        resultLb.stringValue = success ? "Success ^_^  \(info)" : "Error: \(info)"
    }
}

extension ViewController: JsonicDelegate {
    func jsonicDidFinished(success: Bool, error: Jsonic.JsonicError) {
        print(success, error)
        if success {
            outputTv.string = jsonic.modelText(outputType: outputType)
        }
        showResult(success: success, info: "Error: \(error.description)")
    }
    
    func jsonicPreprocessJsonBeforeTransfer(json: [String : Any]) -> [String : Any] {
        guard let _ = json["errno"], let _ = json["errmsg"] else { return json }
        let maybeDataKeys: [String] = ["data", "result"]
        for key in maybeDataKeys {
            if let jsonData = json[key] as? [String: Any] { return jsonData }
        }
        return json
    }
}

