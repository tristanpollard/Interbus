//
// Created by Tristan Pollard on 2017-10-04.
// Copyright (c) 2017 Sumo. All rights reserved.
//

import Eureka

class SendMailViewController: FormViewController {

    var mail: EveMail!
    var mailItem: EveMailItem?

    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Send Mail"

        if let reply = self.mailItem {
            self.title = "Re: \(reply.subject!)"
        }

        form +++

                MultivaluedSection(multivaluedOptions: [.Insert, .Delete]) {
                    $0.tag = "recipMultiTag"


                    $0.addButtonProvider = { section in
                        return ButtonRow() {
                            $0.title = "New Recipient"
                        }.onChange() { row in
                            self.evaluateSend()
                        }
                    }

                    $0.multivaluedRowToInsertAt = { index in
                        return MailRecipientRow("recipientTag_\(index)") {
                            $0.add(rule: RuleRequired())
                        }.onChange() { row in
                            self.evaluateSend()
                        }.cellSetup() { cell, row in
                            self.evaluateSend()
                        }
                    }
//
//            //reply all, add all recipients as well
                    if let recipentsArray = mailItem?.recipients {
                        for (nameIndex, recip) in recipentsArray.enumerated() {
                            if recip.id != self.mail.character.id {
                                $0 <<< MailRecipientRow("recipientFromTag_\(nameIndex)") { row in
                                    let result = EveSearchResult(recip.id, category: EveSearchCategory(rawValue: recip.recipient_type)!)
                                    let name = EveName(recip.id, name: recip.name!.name, category: EveNameCategory(rawValue: recip.recipient_type)!)
                                    result.name = name
                                    row.value = result
                                }.onChange() { row in
                                    self.evaluateSend()
                                }.cellSetup() { cell, row in
                                    self.evaluateSend()
                                }
                            }
                        }
                    }

//            //add reply to sender
                    if let sender = mailItem?.sender {
                        if sender.id != self.mail.character.id {
                            $0 <<< MailRecipientRow("recipientFromTag") { row in
                                let result = EveSearchResult(sender.id, category: .character)
                                let name = EveName(sender.id, name: sender.name!.name, category: .character)
                                result.name = name
                                row.value = result
                            }.onChange() { row in
                                self.evaluateSend()
                            }.cellSetup() { cell, row in
                                self.evaluateSend()
                            }
                        }
                    }

                    if self.mailItem == nil {
                        $0 <<< MailRecipientRow("recipientTag_\(index)") {
                            $0.add(rule: RuleRequired())
                        }.onChange() { row in
                            self.evaluateSend()
                        }.cellSetup() { cell, row in
                            self.evaluateSend()
                        }
                    }
                }
                +++ TextRow("subjectTag") {
            $0.title = "Subject:"
            $0.add(rule: RuleRequired())
            if let mail = self.mailItem {
                $0.value = "Re: \(mail.subject!)"
            }
        }.cellSetup { (cell, row) in
            cell.textField.autocorrectionType = .no
        }
                +++ TextAreaRow("bodyTag") {
            $0.textAreaHeight = .dynamic(initialTextViewHeight: 120)
            $0.add(rule: RuleRequired())
            if let mail = self.mailItem {
                if let body = mail.getBodyString() {
                    $0.value = "\n\n------------------------------\n\(body)"
                }
            }
        }.cellSetup { (cell, row) in
            cell.textView.autocorrectionType = .no
        }
                +++ ButtonRow("sendTag") {
            $0.title = "Send"
            $0.disabled = Condition.function(self.getAllKeys()) { form in
                return form.validate().count != 0
            }
        }
                .onCellSelection() { cell, row in
                    if !row.isDisabled {
                        self.sendMail()
                    }
                }

    }

    func sendMail() {
        let recips: MultivaluedSection = self.form.sectionBy(tag: "recipMultiTag") as! MultivaluedSection

        if let vals = recips.values() as? [EveSearchResult] {
            let body: TextAreaRow = self.form.rowBy(tag: "bodyTag")!
            let subject: TextRow = self.form.rowBy(tag: "subjectTag")!

            self.mail.sendMail(subject.value!, body: NSString(string: body.value!).replacingOccurrences(of: "\n", with: "<br />"), recipients: vals)
            self.navigationController?.popViewController(animated: true)
        }

    }

    func evaluateSend() {
        let submit = self.form.rowBy(tag: "sendTag") as! ButtonRow
        submit.evaluateDisabled()
    }

    func getAllKeys() -> [String] {
        var keys = [String]()
        let values = self.form.values()
        for (key, _) in values {
            keys.append(key)
        }
        return keys
    }

}
