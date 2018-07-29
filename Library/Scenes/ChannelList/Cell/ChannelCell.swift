//
//  Zap
//
//  Created by Otto Suess on 05.04.18.
//  Copyright © 2018 Zap. All rights reserved.
//

import UIKit

class ChannelCell: BondCollectionViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var onlineIndicatorView: UIView!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var remotePubKeyTitleLabel: UILabel!
    @IBOutlet private weak var remotePubKeyLabel: UILabel!
    @IBOutlet private weak var balanceView: BalanceView!
    @IBOutlet private weak var sendLimitCircleView: GradientView!
    @IBOutlet private weak var sendLimitTitleLabel: UILabel!
    @IBOutlet private weak var sendLimitAmountLabel: UILabel!
    @IBOutlet private weak var receiveLimitCircleView: GradientView!
    @IBOutlet private weak var receiveLimitTitleLabel: UILabel!
    @IBOutlet private weak var receiveLimitAmountLabel: UILabel!
    @IBOutlet private weak var fundingTransactionTitleLabel: UILabel!
    @IBOutlet private weak var fundingTransactionTxIdButton: UIButton!
    @IBOutlet private weak var closeChannelButton: UIButton!
    
    private var gradientLayer: CAGradientLayer?

    var allLabels: [UILabel] {
        return [amountLabel, nameLabel, remotePubKeyTitleLabel, remotePubKeyLabel, sendLimitTitleLabel, sendLimitAmountLabel, receiveLimitTitleLabel, receiveLimitAmountLabel, fundingTransactionTitleLabel]
    }
    
    var isLightBackgound = true {
        didSet {
            allLabels.forEach { $0.textColor = isLightBackgound ? UIColor.zap.black : UIColor.white }
        }
    }
    
    var channelViewModel: ChannelViewModel? {
        didSet {
            guard let channel = channelViewModel?.channel else { return }
            
            channelViewModel?.state
                .map { $0 == .active ? UIColor.zap.nastyGreen : UIColor.zap.tomato }
                .bind(to: onlineIndicatorView.reactive.backgroundColor)
                .dispose(in: onReuseBag)
            
            channelViewModel?.name
                .bind(to: nameLabel.reactive.text)
                .dispose(in: onReuseBag)

            channelViewModel?.color
                .observeNext { [weak self] in
                    self?.updateGradient(color: $0)
                }
                .dispose(in: onReuseBag)

            remotePubKeyLabel.text = channel.remotePubKey
            
            if let sendLimitAmount = Settings.shared.primaryCurrency.value.format(satoshis: channel.localBalance) {
                amountLabel.text = sendLimitAmount
                sendLimitAmountLabel.text = sendLimitAmount
            }
            
            if let receiveLimitAmount = Settings.shared.primaryCurrency.value.format(satoshis: channel.remoteBalance) {
                receiveLimitAmountLabel.text = receiveLimitAmount
            }
            
            balanceView.set(localBalance: channel.localBalance, remoteBalance: channel.remoteBalance)

            if !channel.state.isClosing {
                let closeTitle = channel.state == .active ? "scene.channel_detail.close_button".localized : "scene.channel_detail.force_close_button".localized
                closeChannelButton.setTitle(closeTitle, for: .normal)
            }
            
            fundingTransactionTxIdButton.setTitle(channel.channelPoint.fundingTxid, for: .normal)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        gradientLayer?.removeFromSuperlayer()
    }
    
    private func updateGradient(color: UIColor) {
        
        self.gradientLayer?.removeFromSuperlayer()
        
        let verifiedColor = color.verified
        
        isLightBackgound = verifiedColor.isLight
        
        layer.borderColor = verifiedColor.darker.cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [verifiedColor.cgColor, verifiedColor.darker.cgColor]
        layer.insertSublayer(gradientLayer, at: 0)
        self.gradientLayer = gradientLayer
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        layer.cornerRadius = 11
        layer.borderWidth = 1
        layer.masksToBounds = true
        
        onlineIndicatorView.layer.cornerRadius = 5
        
        Style.label.apply(to: allLabels)
        Style.button.apply(to: fundingTransactionTxIdButton, closeChannelButton)
        
        remotePubKeyTitleLabel.text = "scene.channel_detail.remote_pub_key_label".localized
        fundingTransactionTitleLabel.text = "scene.channel_detail.funding_transaction_label".localized
        sendLimitTitleLabel.text = "scene.channel_detail.local_balance_label".localized
        sendLimitCircleView.layer.cornerRadius = 5
        sendLimitCircleView.gradient = [UIColor.zap.lightMustard, UIColor.zap.peach]
        receiveLimitTitleLabel.text = "scene.channel_detail.remote_balance_label".localized
        receiveLimitCircleView.layer.cornerRadius = 5
        receiveLimitCircleView.gradient = [UIColor.zap.lightGrey, UIColor.zap.lightGrey]
    }
}