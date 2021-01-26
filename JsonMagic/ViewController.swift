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
    
    fileprivate func updateTextViewAttrs(tv: NSTextView) {
        tv.textColor = NSColor.textColor
        tv.font = NSFont.init(name: "Monaco", size: 13)
    }
}

class ViewController: NSViewController {
    enum TransferType {
        case jsonToSwift, jsonToKotlin, jsonToJava, kotlinToSwift
    }
    
    @IBOutlet var inputTv: NSTextView!
    @IBOutlet var outputTv: NSTextView!
    @IBOutlet weak var resultLb: NSTextField!
    @IBOutlet weak var modelSuffixTf: NSTextField!
    @IBOutlet weak var nameTf: NSTextField!
    @IBOutlet weak var kotlinToSwiftBtn: NSButton!
    @IBOutlet weak var jsonToSwiftBtn: NSButton!
    @IBOutlet weak var jsonToKotlinBtn: NSButton!
    @IBOutlet weak var jsonToJavaBtn: NSButton!
    @IBOutlet weak var serializedBtn: NSButton!
    @IBOutlet weak var jsonPropertyBtn: NSButton!
    
    private var jsonic: Jsonic!
    private var transferType = TransferType.jsonToSwift
    private var outputType: OutputType {
        switch transferType {
        case .jsonToKotlin:
            return .kotlin(config: outputKotlinConfig)
        case .jsonToJava:
            return .java
        default:
            return .swift
        }
    }
    private var outputKotlinConfig: OutputType.KotlinConfig {
        return OutputType.KotlinConfig(isSerializedNameEnable: serializedBtn.state == .on,
                                       isJsonPropertyEnable: jsonPropertyBtn.state == .on)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jsonic = Jsonic.init(delegate: self)
        inputTv.delegate = self
        outputTv.delegate = self
        inputTv.isAutomaticQuoteSubstitutionEnabled = false
        outputTv.isAutomaticQuoteSubstitutionEnabled = false
        updateTransferType()
    }

    @IBAction func run(_ sender: NSButton) {
        switch transferType {
        case .jsonToSwift, .jsonToKotlin, .jsonToJava:
            doJsonic()
        case .kotlinToSwift:
            doSwifty()
        }
    }
    
    @IBAction func radioClicked(_ sender: NSObject) {
        if kotlinToSwiftBtn == sender {
            transferType = TransferType.kotlinToSwift
        } else if jsonToSwiftBtn == sender {
            transferType = TransferType.jsonToSwift
        } else if jsonToJavaBtn == sender {
            transferType = TransferType.jsonToJava
        } else if jsonToKotlinBtn == sender {
            transferType = TransferType.jsonToKotlin
        }
        updateTransferType()
    }
    
    @IBAction func logClicked(_ sender: Any) {
        showOkAlert(title: "Log", message: jsonic.logInfo)
    }
    
    @IBAction func copyClicked(_ sender: Any) {
        let content = jsonic.modelText(outputType: outputType)
        guard content.count > 0 else {
            showOkAlert(title: "Copy Fail", message: "No result")
            return
        }
        let pboard = NSPasteboard.general
        pboard.declareTypes([.string], owner: nil)
        pboard.setString(content, forType: .string)
        showOkAlert(title: "Copy Success")
    }
    
    private func showOkAlert(title: String, message: String = "") {
        let alert = NSAlert()
        alert.informativeText = message
        alert.messageText = title
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func updateTransferType() {
        [jsonToKotlinBtn, jsonToSwiftBtn, kotlinToSwiftBtn].forEach({ $0?.state = .off })
        switch transferType {
        case .jsonToSwift:
            jsonToSwiftBtn.state = .on
        case .jsonToKotlin:
            jsonToKotlinBtn.state = .on
        case .jsonToJava:
            jsonToJavaBtn.state = .on
        case .kotlinToSwift:
            kotlinToSwiftBtn.state = .on
        }
        
        [serializedBtn, jsonPropertyBtn].forEach( { $0?.isEnabled = jsonToKotlinBtn.state == .on } )
    }
    
    private func updateOutputText(text: String) {
        outputTv.string = text
        updateTextViewAttrs(tv: outputTv)
    }
    
    @discardableResult
    private func doSwifty() -> Bool {
        guard let text = inputTv.textStorage?.string, text.count > 0 else {
            showResult(success: false, info: "Hey man, input your Kotlin model text~")
            return false
        }
        let result = Swifty.modelFromKotlin(text: text)
        updateOutputText(text: result)
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
        jsonic.beginParse(text: text, modelName: nameTf.stringValue, modelSuffix: modelSuffixTf.stringValue)
    }
    
    @IBAction func exportModel(_ sender: Any) {
        if kotlinToSwiftBtn.state == .on {
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
        resultLb.textColor = success ? .systemGreen : .red
        resultLb.stringValue = success ? "Congratulations~ Transfer Success ^_^  \(info)" : "Error: \(info)"
    }
}

extension ViewController: JsonicDelegate {
    func jsonicDidFinished(success: Bool, error: Jsonic.JsonicError) {
        print(success, error)
        if success {
            updateOutputText(text: jsonic.modelText(outputType: outputType))
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

