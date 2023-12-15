//
//  CurrencyConversionViewController.swift
//  Wirebarley_seonghun
//
//  Created by 전성훈 on 2023/12/12.
//

import UIKit

class CurrencyConversionViewController: UIViewController {
    
    private var viewModel: CurrencyConversionViewModel!
    private let disposeBag = DisposeBag()
        
    private lazy var mainLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.text = NSLocalizedString("CurrenyConversionMain", comment: "")
        lbl.textColor = .black
        lbl.font = .systemFont(ofSize: 38, weight: .semibold)
        lbl.numberOfLines = 2
        
        return lbl
    }()
    
    private lazy var horizontalLabelStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.alignment = .leading
        stackView.spacing = 16
        stackView.distribution = .fillProportionally
        
        return stackView
    }()
    
    private lazy var itemLabelStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.alignment = .trailing
        stackView.spacing = 10
        
        return stackView
    }()
    
    private lazy var senderLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.text = NSLocalizedString("SenderLabel", comment: "")
        lbl.textColor = .black
        lbl.font = .systemFont(ofSize: 18, weight: .regular)
        
        return lbl
    }()
    
    private lazy var recipientLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.text = NSLocalizedString("RecipientLabel", comment: "")
        lbl.textColor = .black
        lbl.font = .systemFont(ofSize: 18, weight: .regular)
        
        return lbl
    }()
    
    private lazy var exchangeRateLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.text = NSLocalizedString("ExchangeRateLabel", comment: "")
        lbl.textColor = .black
        lbl.font = .systemFont(ofSize: 18, weight: .regular)
        
        return lbl
    }()
    
    private lazy var timeLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.text = NSLocalizedString("TimeLabel", comment: "")
        lbl.textColor = .black
        lbl.font = .systemFont(ofSize: 18, weight: .regular)
        
        return lbl
    }()
    
    private lazy var transferAmountLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.text = NSLocalizedString("TransferAmountLabel", comment: "")
        lbl.textColor = .black
        lbl.font = .systemFont(ofSize: 18, weight: .regular)
        
        return lbl
    }()
    
    private lazy var valueLabelStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10
        
        return stackView
    }()
    
    private lazy var senderValueLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.text = NSLocalizedString("SenderValue", comment: "")
        lbl.textColor = .black
        lbl.font = .systemFont(ofSize: 18, weight: .regular)
        
        return lbl
    }()
    
    private lazy var recipientValuelabel: UILabel = {
        let lbl = UILabel()
        
        lbl.text = NSLocalizedString("KRW", comment: "")
        lbl.textColor = .black
        lbl.font = .systemFont(ofSize: 18, weight: .regular)
        
        return lbl
    }()
    
    private lazy var exchangeRateValueLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.text = "0.00 / USD"
        lbl.textColor = .black
        lbl.font = .systemFont(ofSize: 18, weight: .regular)
    
        return lbl
    }()
    
    private lazy var timeValueLabel: UILabel = {
        let lbl = UILabel()

        lbl.text = Date.nowTime
        lbl.textColor = .black
        lbl.font = .systemFont(ofSize: 18, weight: .regular)
        
        return lbl
    }()
    
    private lazy var transferStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fill
        
        return stackView
    }()
    
    private lazy var transferAmountValueTextField: UITextField = {
        let textField = UITextField()
        
        textField.accessibilityIdentifier = "amountTextField"
        textField.delegate = self
        
        textField.placeholder = "0"
        textField.attributedPlaceholder = NSAttributedString(
            string: "0",
            attributes: [.foregroundColor: UIColor.darkGray]
        )
        textField.textColor = .black
        textField.font = .systemFont(ofSize: 18, weight: .regular)
        textField.textAlignment = .right
        
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.black.cgColor
        textField.keyboardType = .numberPad
        
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let doneBarButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(self.dismissKeyboard)
        )
        keyboardToolbar.items =  [doneBarButton]
        
        textField.inputAccessoryView = keyboardToolbar
            
        return textField
    }()
    
    private lazy var transferAmountValueLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.text = "USD"
        lbl.textColor = .black
        lbl.font = .systemFont(ofSize: 18, weight: .regular)
        
        return lbl
    }()
    
    private lazy var resultLabel: UILabel = {
        let lbl = UILabel()
        
        lbl.accessibilityIdentifier = "Result"
        lbl.text = NSLocalizedString("BeforeReceivedAmount", comment: "")
        lbl.textColor = .black
        lbl.font = .systemFont(ofSize: 20, weight: .bold)
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        
        return lbl
    }()
    
    private lazy var countryPickerView: UIPickerView = {
        let picker = UIPickerView()
        
        picker.accessibilityIdentifier = "Picker"
        picker.backgroundColor = .white
        picker.tintColor = .black
        picker.delegate = self
        picker.dataSource = self
        picker.selectRow(0, inComponent: 0, animated: false)
        
        return picker
    }()
    
    static func create(with viewModel: CurrencyConversionViewModel) -> CurrencyConversionViewController {
        let vc = CurrencyConversionViewController()
        vc.viewModel = viewModel
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        dataBindng()
    }
    
    private func setLayout() {
        view.backgroundColor = .white
        
        [
            senderLabel,
            recipientLabel,
            exchangeRateLabel,
            timeLabel,
            transferAmountLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            itemLabelStackView.addArrangedSubview($0)
        }
        
        [
            transferAmountValueTextField,
            transferAmountValueLabel
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            transferStackView.addArrangedSubview($0)
        }
        
        [
            senderValueLabel,
            recipientValuelabel,
            exchangeRateValueLabel,
            timeValueLabel,
            transferStackView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            valueLabelStackView.addArrangedSubview($0)
        }
        
        [
            itemLabelStackView,
            valueLabelStackView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            horizontalLabelStackView.addArrangedSubview($0)
        }
        
        [
            mainLabel,
            horizontalLabelStackView,
            resultLabel,
            countryPickerView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            mainLabel.topAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.topAnchor,
                constant: 32),
            mainLabel.centerXAnchor.constraint(
                equalTo: self.view.centerXAnchor),
            
            horizontalLabelStackView.topAnchor.constraint(
                equalTo: mainLabel.bottomAnchor,
                constant: 32),
            horizontalLabelStackView.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor,
                constant: 16),
            
            resultLabel.topAnchor.constraint(
                equalTo: horizontalLabelStackView.bottomAnchor,
                constant: 64),
            resultLabel.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor,
                constant: 16),
            resultLabel.trailingAnchor.constraint(
                equalTo: self.view.trailingAnchor,
                constant: -16),
            
            timeValueLabel.trailingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.trailingAnchor,
                constant: -16),
            
            transferAmountValueTextField.widthAnchor.constraint(
                equalToConstant: 120),
            
            countryPickerView.bottomAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,
                constant: -32),
            countryPickerView.widthAnchor.constraint(
                equalTo: self.view.widthAnchor)
        ])
    }
    
    // MARK: - DataBinding / Output
    
    private func dataBindng() {
        viewModel.fetchCurrenciesFromUSD()
        
        viewModel.selectedRecipientInfo
            .subscribe(on: self, disposeBag: disposeBag)
            .onNext { [weak self] recipient in
                self?.recipientValuelabel.text = recipient.country
                self?.exchangeRateValueLabel.text = recipient.exchangedRate()
            }
        
        viewModel.receivedAmount
            .subscribe(on: self, disposeBag: disposeBag)
            .onNext { [weak self] result in
                self?.resultLabel.text = result
            }
        
        viewModel.error
            .subscribe(on: self, disposeBag: disposeBag)
            .onNext { [weak self] error in
                if !error.isEmpty {
                    self?.showAlert(message: error)
                }
            }
    }
    
    @objc private func dismissKeyboard() {
        transferAmountValueTextField.resignFirstResponder()
    }
}

// MARK: - Input

extension CurrencyConversionViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text,
              let amount = Int(text),
              amount > 0 else {
            viewModel.transferAmount = 0
            textField.text = ""
            return
        }
        
        switch amount {
        case ...10000:
            viewModel.transferAmount = amount
        default:
            viewModel.error.value = NSLocalizedString("InvalidTransferAmount", comment: "")
            viewModel.transferAmount = 0
            textField.text = ""
        }
    }
}

extension CurrencyConversionViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int {
        viewModel.currencies.count
    }
}

extension CurrencyConversionViewController: UIPickerViewDelegate {
    func pickerView(
        _ pickerView: UIPickerView,
        attributedTitleForRow row: Int,
        forComponent component: Int
    ) -> NSAttributedString? {
        return NSAttributedString(
            string: NSLocalizedString("\(viewModel.currencies[row])", comment: ""),
            attributes: [.foregroundColor: UIColor.black]
        )
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int
    ) {
        viewModel.selectedIndex = row
    }
}
